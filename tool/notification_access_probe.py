"""Test-only revocation fixture: fixed synthetic service/database, never development."""
import sys
from uuid import UUID
from metadata_upgrade_smoke import sql

if __name__ == "__main__":
    user_id = str(UUID(sys.argv[1]))
    if sys.argv[2] not in ("block", "unblock"):
        raise ValueError("Expected bounded fixture action")
    blocked = "TRUE" if sys.argv[2] == "block" else "FALSE"
    sql("calendar_example_test", f"UPDATE serverpod_auth_core_user SET blocked={blocked} WHERE id='{user_id}'::uuid;")
