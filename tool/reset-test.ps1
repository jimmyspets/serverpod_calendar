. "$PSScriptRoot/common.ps1"
# Only the dedicated Compose test database is reset. Never use the dev service.
Invoke-Compose @('--profile', 'test', 'up', '-d', '--wait', 'postgres_test', 'redis_test')
Invoke-Compose @('exec', '-T', 'postgres_test', 'psql', '-U', 'postgres', '-d', 'postgres', '--set', 'ON_ERROR_STOP=1', '-c', 'DROP DATABASE IF EXISTS calendar_example_test WITH (FORCE);')
Invoke-Compose @('exec', '-T', 'postgres_test', 'psql', '-U', 'postgres', '-d', 'postgres', '--set', 'ON_ERROR_STOP=1', '-c', 'CREATE DATABASE calendar_example_test;')
