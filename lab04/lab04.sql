EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 10000;

SET enable_seqscan = off;

SET random_page_cost = 1.0;
SET seq_page_cost = 10.0;


CREATE EXTENSION IF NOT EXISTS pg_hint_plan;
LOAD 'pg_hint_plan';
SET pg_hint_plan.enable_hint TO on;
SET pg_hint_plan.enable_hint_table TO ON;
SET pg_hint_plan.debug_print = on;

CREATE INDEX idx_employees_salary ON employees (salary);

EXPLAIN ANALYZE
SELECT /*+ IndexScan(employees idx_employees_salary) */ * FROM employees
WHERE salary > 10000;

CREATE INDEX idx_employees_dept_id ON employees (department_id);
CREATE INDEX idx_cities_id ON cities(id);

EXPLAIN ANALYZE
SELECT *
FROM employees e
JOIN cities c ON c.id = e.department_id
WHERE e.salary > 10000;

EXPLAIN ANALYZE
SELECT /*+ HashJoin(e c) */ *
FROM employees e
JOIN cities c ON c.id = e.department_id
WHERE e.salary > 10000;

EXPLAIN ANALYZE
SELECT /*+ NestLoop(e c) */ *
FROM employees e
JOIN cities c ON c.id = e.department_id
WHERE e.salary > 10000;


SELECT * FROM pg_stat_user_indexes WHERE relname = 'employees';

EXPLAIN ANALYZE
SELECT /*+ IndexOnlyScan(employees idx_employees_salary) */ * FROM employees ORDER BY salary;



EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 95000 OR department_id = 10;

EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 95000
UNION ALL
SELECT * FROM employees WHERE department_id = 10;


EXPLAIN ANALYZE
SELECT /*+ Leading((c e)) */ *
FROM employees e
JOIN cities c ON c.id = e.department_id
WHERE e.salary > 10000;


EXPLAIN ANALYZE
SELECT /*+ Rows(e c #1) */ *
FROM employees e
JOIN cities c ON c.id = e.department_id;


SET work_mem = '64kB';

EXPLAIN ANALYZE
SELECT /*+ SeqScan(employees) */ * FROM employees ORDER BY salary;

RESET work_mem;