import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Exact master-category search; labels never imply availability or authority.
class ItemCategoryFilter extends StatefulWidget {
  const ItemCategoryFilter({
    super.key,
    required this.prefix,
    required this.busy,
    required this.onApply,
  });
  final String prefix;
  final bool busy;
  final ValueChanged<cal.CalendarCategoryFilter?> onApply;
  @override
  State<ItemCategoryFilter> createState() => _ItemCategoryFilterState();
}

class _ItemCategoryFilterState extends State<ItemCategoryFilter> {
  final _value = TextEditingController(), _language = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _value.dispose();
    _language.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Search exact master categories. Only items with authorized category disclosure qualify; empty results do not describe hidden items or free time.',
      ),
      TextField(
        key: Key('${widget.prefix}-category-value'),
        controller: _value,
        enabled: !widget.busy,
        decoration: const InputDecoration(labelText: 'Exact category text'),
      ),
      TextField(
        key: Key('${widget.prefix}-category-language'),
        controller: _language,
        enabled: !widget.busy,
        decoration: const InputDecoration(
          labelText: 'Language tag (optional; omitted matches any)',
        ),
      ),
      if (_error != null)
        Text(_error!, key: Key('${widget.prefix}-category-error')),
      Wrap(
        children: [
          TextButton(
            key: Key('${widget.prefix}-category-apply'),
            onPressed: widget.busy
                ? null
                : () {
                    if (_value.text.trim().isEmpty) {
                      setState(
                        () => _error = 'Enter category text or use Clear.',
                      );
                      return;
                    }
                    setState(() => _error = null);
                    widget.onApply(
                      cal.CalendarCategoryFilter(
                        value: _value.text,
                        language: _language.text.isEmpty
                            ? null
                            : _language.text,
                      ),
                    );
                  },
            child: const Text('Apply category'),
          ),
          TextButton(
            key: Key('${widget.prefix}-category-clear'),
            onPressed: widget.busy
                ? null
                : () {
                    _value.clear();
                    _language.clear();
                    setState(() => _error = null);
                    widget.onApply(null);
                  },
            child: const Text('Clear category'),
          ),
        ],
      ),
    ],
  );
}
