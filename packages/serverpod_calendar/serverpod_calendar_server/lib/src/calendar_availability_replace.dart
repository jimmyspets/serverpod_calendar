part of 'calendar_module.dart';

extension CalendarAvailabilityReplacementOperations on CalendarService {
  Future<CalendarAvailabilityReplaceResult> replaceAvailabilityFromImport(
    CalendarAvailabilityReplaceRequest input,
  ) async {
    if (input.bytes.lengthInBytes > const IcalendarSyntaxLimits().maxBytes ||
        input.selection.isEmpty ||
        input.selection.length > availabilityMaxDefinitions) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final selection = List<CalendarAvailabilityExportSelection>.unmodifiable(
      input.selection,
    );
    if (selection.map((s) => s.availabilityId).toSet().length !=
            selection.length ||
        [
          input.expectedRevision,
          ...selection.map((s) => s.expectedRevision),
        ].any((r) => r < 1 || r > CalendarService._maxRevision)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final bytes = Uint8List.fromList(
      input.bytes.buffer.asUint8List(
        input.bytes.offsetInBytes,
        input.bytes.lengthInBytes,
      ),
    );
    final c = await _context();
    await _transaction(c, (tx, _) async {
      final parent = await _active(c, input.calendarId, tx);
      await _decide(
        c,
        [
          _ar(parent, CalendarPermission.importAvailability),
          _ar(parent, CalendarPermission.replaceAvailabilityFromImport),
        ],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (parent.identity.revision != input.expectedRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
    });
    late final IcalendarAvailabilityCalendar parsed;
    try {
      parsed = parseIcalendarAvailabilityCalendar(
        bytes,
        extensions: IcalendarAvailabilityExtensionRegistry([
          for (final r in _runtime.availabilityExtensions.values)
            IcalendarAvailabilityExtensionRegistration(
              name: r.name,
              contexts: r.contexts.map(
                (v) => switch (v) {
                  CalendarAvailabilityExtensionContext.definition =>
                    IcalendarAvailabilityExtensionContext.definition,
                  CalendarAvailabilityExtensionContext.opening =>
                    IcalendarAvailabilityExtensionContext.opening,
                },
              ),
              validateText: (_) => true,
            ),
        ]),
      );
    } on IcalendarSyntaxException catch (e) {
      throw _failure(
        e.kind == IcalendarSyntaxError.limitExceeded
            ? CalendarFailureCode.limitExceeded
            : CalendarFailureCode.validation,
      );
    } on IcalendarComponentException catch (e) {
      throw _failure(
        e.kind == IcalendarComponentError.limitExceeded
            ? CalendarFailureCode.limitExceeded
            : CalendarFailureCode.validation,
      );
    }
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final rules = <_Availability>[];
      for (final target in selection) {
        final rule = await _availability(c, target.availabilityId, tx);
        if (rule.identity.calendarId != input.calendarId) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        rules.add(rule);
      }
      // Authorize current reads/replacement before equality/conflict information.
      Future<Map<String, CalendarAuthorizationDecision>> authorize(
        List<CalendarAuthorizationRequest> requests,
        CalendarAuthorizationPhase phase,
      ) async {
        final result = <String, CalendarAuthorizationDecision>{};
        for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
          final chunk = requests.sublist(
            i,
            min(i + _options.policyBatchSize, requests.length),
          );
          result.addAll(
            phase == CalendarAuthorizationPhase.finalWrite
                ? await _final(c, chunk, tx)
                : await _decide(c, chunk, tx, phase),
          );
        }
        await _verifyContext(c);
        return result;
      }

      await authorize([
        _ar(parent, CalendarPermission.importAvailability),
        _ar(parent, CalendarPermission.replaceAvailabilityFromImport),
        for (final rule in rules) ...[
          _ar(parent, CalendarPermission.readAvailability, rule: rule),
          _ar(
            parent,
            CalendarPermission.replaceAvailabilityFromImport,
            rule: rule,
          ),
        ],
      ], CalendarAuthorizationPhase.preliminaryWrite);
      if (parent.identity.revision != input.expectedRevision ||
          rules.any(
            (r) =>
                r.identity.revision !=
                selection
                    .singleWhere((s) => s.availabilityId == r.identity.id)
                    .expectedRevision,
          )) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (parsed.definitions.length != rules.length ||
          parsed.definitions.any(
            (d) => !rules.any((r) => r.data.protocolUid == d.uid),
          )) {
        throw _failure(CalendarFailureCode.validation);
      }
      final proposals = <CalendarAvailabilityImportMember>[];
      for (final rule in rules) {
        final source = parsed.definitions.singleWhere(
          (d) => d.uid == rule.data.protocolUid,
        );
        final existing = {
          for (final o in rule.data.content.openings) o.protocolUid!: o.uid!,
        };
        var index = 0;
        final proposal = _availabilityValue(
          () => availabilityStorageProposal(
            source,
            newOpeningId: () =>
                existing[source.openings[index++].master.uid] ??
                const Uuid().v4obj(),
          ),
        );
        proposals.add(
          CalendarAvailabilityImportMember(
            availabilityId: rule.identity.id!,
            protocolUid: proposal.protocolUid,
            content: proposal.content,
            protocolState: proposal.protocolState,
            timingOverrides: proposal.edits,
          ),
        );
      }
      CalendarAvailabilityReplacementIntent intent(
        List<bool>? changed,
        List<bool>? local,
      ) => CalendarAvailabilityReplacementIntent([
        for (var i = 0; i < rules.length; i++)
          CalendarAvailabilityReplacementMember(
            current: rules[i].snapshot,
            proposed: proposals[i],
            baselineProfile: rules[i].data.importBaseline?.profile,
            baselineSequence: rules[i].data.importBaseline?.sourceSequence,
            changed: changed?[i],
            localChanges: local?[i],
          ),
      ]);
      final changed = <bool>[], local = <bool>[];
      final baselines = <CalendarAvailabilityImportBaseline>[];
      // All future native identity mappings are visible before classification.
      List<CalendarAuthorizationRequest> requests(
        CalendarAvailabilityReplacementIntent batch, {
        bool editGates = false,
      }) {
        CalendarAuthorizationRequest request(
          CalendarPermission op, [
          _Availability? rule,
          CalendarAvailabilityImportMember? proposal,
        ]) => CalendarAuthorizationRequest(
          key: '${op.name}:${rule?.identity.id ?? parent.identity.id}',
          operation: op,
          calendarId: input.calendarId,
          current: parent.snapshot,
          availabilityId: rule?.identity.id,
          currentAvailability: rule?.snapshot,
          availabilityReplacement: batch,
          proposedAvailability: proposal?.content,
          proposedAvailabilityEdits: proposal?.timingOverrides,
          proposedAvailabilityProtocolState: proposal?.protocolState,
        );
        return [
          request(CalendarPermission.importAvailability),
          request(CalendarPermission.replaceAvailabilityFromImport),
          for (var i = 0; i < rules.length; i++) ...[
            request(
              CalendarPermission.readAvailability,
              rules[i],
              proposals[i],
            ),
            request(
              CalendarPermission.replaceAvailabilityFromImport,
              rules[i],
              proposals[i],
            ),
            if (editGates && changed[i]) ...[
              if (jsonEncode(availabilityStructure(rules[i].data.content)) !=
                  jsonEncode(availabilityStructure(proposals[i].content)))
                request(
                  CalendarPermission.updateAvailability,
                  rules[i],
                  proposals[i],
                ),
              if (jsonEncode(availabilityMetadata(rules[i].data.content)) !=
                      jsonEncode(availabilityMetadata(proposals[i].content)) ||
                  jsonEncode(rules[i].data.protocolState!.toJson()) !=
                      jsonEncode(proposals[i].protocolState.toJson()))
                request(
                  CalendarPermission.updateAvailabilityMetadata,
                  rules[i],
                  proposals[i],
                ),
              if (jsonEncode(
                    rules[i].data.timingOverrides
                        ?.map((e) => e.toJson())
                        .toList(),
                  ) !=
                  jsonEncode(
                    proposals[i].timingOverrides
                        ?.map((e) => e.toJson())
                        .toList(),
                  ))
                request(
                  CalendarPermission.changeAvailabilityOccurrence,
                  rules[i],
                  proposals[i],
                ),
            ],
          ],
        ];
      }

      await authorize(
        requests(intent(null, null)),
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      for (var i = 0; i < rules.length; i++) {
        final rule = rules[i], proposal = proposals[i];
        final baseline = rule.data.importBaseline;
        if (baseline == null) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        try {
          validateAvailabilityImportBaseline(baseline, rule.data.protocolUid);
        } catch (_) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if ((proposal.protocolState.sequence ?? 0) <
            (baseline.sourceSequence ?? 0)) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        final current = _availabilityValue(
          () => canonicalAvailabilitySource(
            rule.data.protocolUid,
            rule.data.content,
            rule.data.timingOverrides,
            rule.data.protocolState!,
          ),
        );
        final next = _availabilityValue(
          () => availabilityImportBaseline(
            proposal.protocolUid,
            proposal.content,
            proposal.timingOverrides,
            proposal.protocolState,
          ),
        );
        final isChanged = current != next.canonicalValue;
        final isLocal = current != baseline.canonicalValue;
        if (isChanged && isLocal) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        if (isChanged &&
            rule.identity.revision == CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        changed.add(isChanged);
        local.add(isLocal);
        baselines.add(next);
      }
      final finalRequests = requests(intent(changed, local), editGates: true);
      await authorize(
        finalRequests,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      Future<void> metadata(CalendarAuthorizationPhase phase) async {
        for (final request in finalRequests.where(
          (r) =>
              r.operation == CalendarPermission.replaceAvailabilityFromImport &&
              r.availabilityId != null,
        )) {
          await _approveAvailabilityMetadata(c, request, tx, phase);
        }
      }

      await metadata(CalendarAuthorizationPhase.preliminaryWrite);
      final decisions = await authorize(
        finalRequests,
        CalendarAuthorizationPhase.finalWrite,
      );
      await metadata(CalendarAuthorizationPhase.finalWrite);
      DateTime? now;
      if (changed.any((v) => v)) now = await _revisionTime(tx);
      final receipts = <CalendarAvailabilityReplaceReceipt>[];
      for (var i = 0; i < rules.length; i++) {
        final rule = rules[i], proposal = proposals[i];
        if (changed[i]) {
          rule.data.content = proposal.content;
          rule.data.timingOverrides = proposal.timingOverrides;
          rule.data.protocolState = proposal.protocolState;
          rule.data.importBaseline = baselines[i];
          rule.data.updatedAt = now!.isBefore(rule.data.updatedAt)
              ? rule.data.updatedAt
              : now;
          rule.identity.revision++;
          await CalendarAvailabilityDataRecord.db.updateRow(
            _session,
            rule.data,
            transaction: tx,
          );
          await CalendarAvailabilityRecord.db.updateRow(
            _session,
            rule.identity,
            transaction: tx,
          );
        }
        final receipt = _availabilityReceipt(rule, [
          for (final request in finalRequests.where(
            (r) =>
                r.operation != CalendarPermission.readAvailability &&
                (r.availabilityId == null ||
                    r.availabilityId == rule.identity.id),
          ))
            decisions[request.key]!,
        ]);
        if (receipt != null) {
          receipts.add(
            CalendarAvailabilityReplaceReceipt(
              receipt: receipt,
              changed: changed[i],
            ),
          );
        }
      }
      if (changed.any((v) => v)) await _bump(scope, tx);
      return CalendarAvailabilityReplaceResult(
        receipts: List.unmodifiable(receipts),
      );
    });
  }
}
