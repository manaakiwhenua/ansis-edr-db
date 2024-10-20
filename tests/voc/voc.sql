-- Start transaction and run dummy test
BEGIN;

SELECT plan(2);

-- Run the tests
SELECT has_schema('voc'::name);
SELECT has_table('voc'::name, 'concept'::name);

-- Finish the tests and clean up
SELECT * FROM finish();
ROLLBACK;
