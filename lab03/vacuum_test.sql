SHOW autovacuum;

CREATE TABLE TEST_VACUUM AS SELECT * FROM EMPLOYEES;
SELECT COUNT(*) FROM TEST_VACUUM;

SELECT relname, n_dead_tup, n_live_tup
FROM pg_stat_all_tables
WHERE relname = 'test_vacuum';

UPDATE TEST_VACUUM SET salary = salary + 100;

EXPLAIN ANALYZE SELECT * FROM TEST_VACUUM WHERE salary > 5000;

VACUUM TEST_VACUUM;
VACUUM ANALYZE TEST_VACUUM;

SELECT pg_size_pretty(pg_total_relation_size('test_vacuum'));

VACUUM FULL TEST_VACUUM;

UPDATE TEST_VACUUM SET salary = salary + 500 WHERE department_id = 10;
DELETE FROM TEST_VACUUM WHERE salary > 10000;

SELECT now(), last_autovacuum, last_autoanalyze
FROM pg_stat_all_tables
WHERE relname = 'test_vacuum';


