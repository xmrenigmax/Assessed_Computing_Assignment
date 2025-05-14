SELECT 'Running tests for database schema and data integrity';

-- Execute tests defined in test_schema.sql
\i Database/tests/test_schema.sql;