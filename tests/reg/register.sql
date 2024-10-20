-- Start transaction and run dummy test
BEGIN;

SELECT plan(2);

-- Run the tests
SELECT has_schema('reg'::name);
SELECT has_table('reg'::name, 'register'::name);

-- Finish the tests and clean up
SELECT * FROM finish();
ROLLBACK;
