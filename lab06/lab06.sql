CREATE TABLE changes_history (
    id VARCHAR(255),
    old_value VARCHAR(255),
    new_value VARCHAR(255)
);


CREATE OR REPLACE FUNCTION log_employee_salary()
RETURNS TRIGGER AS $$
BEGIN
    -- Перевіряємо, чи дійсно змінилася зарплата
    IF OLD.salary IS DISTINCT FROM NEW.salary THEN
        INSERT INTO changes_history (id, old_value, new_value)
        VALUES ('employees_salary_' || OLD.id, OLD.salary::VARCHAR, NEW.salary::VARCHAR);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION log_city_name()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.name IS DISTINCT FROM NEW.name THEN
        INSERT INTO changes_history (id, old_value, new_value)
        VALUES ('cities_name_' || OLD.id, OLD.name::VARCHAR, NEW.name::VARCHAR);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_employee_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_salary();

CREATE TRIGGER trg_city_name_update
AFTER UPDATE ON cities
FOR EACH ROW
EXECUTE FUNCTION log_city_name();


UPDATE employees SET salary = salary + 500 WHERE id = 1;

UPDATE cities SET name = name || ' (Updated)' WHERE id = 1;

SELECT * FROM changes_history;
