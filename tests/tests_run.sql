-- Start transaction and run dummy test
BEGIN;

SELECT plan(1);

-- Run the tests
SELECT pass('The proof of concept test ran!');

-- Finish the tests and clean up
SELECT * FROM finish();
ROLLBACK;
