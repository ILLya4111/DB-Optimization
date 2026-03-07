ALTER TABLE employees
ADD COLUMN full_name VARCHAR(150) GENERATED ALWAYS AS (last_name || ' ' || first_name) STORED;

ALTER TABLE employees
ADD COLUMN email_domain VARCHAR(100) GENERATED ALWAYS AS (SUBSTRING(email FROM POSITION('@' IN email) + 1)) STORED;

SELECT first_name, last_name, full_name, email, email_domain
FROM employees
LIMIT 15;



CREATE OR REPLACE VIEW view_managers_hierarchy AS
WITH RECURSIVE hierarchy_up AS (
    -- Базовий рівень: беремо всіх співробітників і їхніх прямих начальників
    SELECT
        id AS employee_id,
        first_name || ' ' || last_name AS employee_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    -- Рекурсія: йдемо вгору по дереву начальників
    SELECT
        hu.employee_id,
        hu.employee_name,
        e.manager_id,
        hu.level + 1
    FROM hierarchy_up hu
    JOIN employees e ON hu.manager_id = e.id
    WHERE e.manager_id IS NOT NULL
)
SELECT
    hu.employee_id,
    hu.employee_name,
    e.id AS manager_id,
    e.first_name || ' ' || e.last_name AS manager_name,
    hu.level AS manager_level
FROM hierarchy_up hu
JOIN employees e ON hu.manager_id = e.id
ORDER BY hu.employee_id, hu.level;


SELECT * FROM view_managers_hierarchy LIMIT 15;


CREATE OR REPLACE VIEW view_subordinates_hierarchy AS
WITH RECURSIVE hierarchy_down AS (
    -- Базовий рівень: кожен співробітник є початком своєї гілки
    SELECT
        id AS manager_id,
        first_name || ' ' || last_name AS manager_name,
        id AS current_emp_id,
        0 AS level
    FROM employees

    UNION ALL

    -- Рекурсія: шукаємо підлеглих для кожного на наступних рівнях
    SELECT
        hd.manager_id,
        hd.manager_name,
        e.id AS current_emp_id,
        hd.level + 1
    FROM hierarchy_down hd
    JOIN employees e ON e.manager_id = hd.current_emp_id
)
SELECT
    hd.manager_id,
    hd.manager_name,
    e.id AS subordinate_id,
    e.first_name || ' ' || e.last_name AS subordinate_name,
    hd.level AS subordinate_level
FROM hierarchy_down hd
JOIN employees e ON hd.current_emp_id = e.id
WHERE hd.level > 0
ORDER BY hd.manager_id, hd.level;


SELECT * FROM view_subordinates_hierarchy LIMIT 15;



CREATE MATERIALIZED VIEW mview_managers_hierarchy AS
WITH RECURSIVE hierarchy_up AS (
    SELECT
        id AS employee_id,
        first_name || ' ' || last_name AS employee_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT
        hu.employee_id,
        hu.employee_name,
        e.manager_id,
        hu.level + 1
    FROM hierarchy_up hu
    JOIN employees e ON hu.manager_id = e.id
    WHERE e.manager_id IS NOT NULL
)
SELECT
    hu.employee_id,
    hu.employee_name,
    e.id AS manager_id,
    e.first_name || ' ' || e.last_name AS manager_name,
    hu.level AS manager_level
FROM hierarchy_up hu
JOIN employees e ON hu.manager_id = e.id
ORDER BY hu.employee_id, hu.level;


SELECT * FROM mview_managers_hierarchy LIMIT 15;


CREATE MATERIALIZED VIEW mview_subordinates_hierarchy AS
WITH RECURSIVE hierarchy_down AS (
    SELECT
        id AS manager_id,
        first_name || ' ' || last_name AS manager_name,
        id AS current_emp_id,
        0 AS level
    FROM employees

    UNION ALL

    SELECT
        hd.manager_id,
        hd.manager_name,
        e.id AS current_emp_id,
        hd.level + 1
    FROM hierarchy_down hd
    JOIN employees e ON e.manager_id = hd.current_emp_id
)
SELECT
    hd.manager_id,
    hd.manager_name,
    e.id AS subordinate_id,
    e.first_name || ' ' || e.last_name AS subordinate_name,
    hd.level AS subordinate_level
FROM hierarchy_down hd
JOIN employees e ON hd.current_emp_id = e.id
WHERE hd.level > 0
ORDER BY hd.manager_id, hd.level;


SELECT * FROM mview_subordinates_hierarchy LIMIT 15;



INSERT INTO employees (id, first_name, last_name, email, hire_date, job_id, salary, manager_id)
OVERRIDING SYSTEM VALUE
VALUES (999999, 'Test', 'User', 'testuser@gmail.com', CURRENT_DATE, 'IT_PROG', 10000, 1);

EXPLAIN ANALYZE SELECT * FROM view_subordinates_hierarchy;

EXPLAIN ANALYZE SELECT * FROM mview_subordinates_hierarchy;



WITH top_earners AS (
    SELECT first_name, last_name, salary
    FROM employees
    WHERE salary > 15000
)
SELECT * FROM top_earners ORDER BY salary DESC;


CREATE OR REPLACE FUNCTION get_employees_by_salary(min_salary NUMERIC)
RETURNS TABLE(first_name VARCHAR, last_name VARCHAR, salary INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT e.first_name, e.last_name, e.salary
    FROM employees e
    WHERE e.salary > min_salary;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_employees_by_salary(15000) ORDER BY salary DESC;
