--EMPLOYEE PAYROLL MANAGEMENT SYSTEM
--created employee table
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(50),
    dept_id NUMBER,
    basic_salary NUMBER
);
--created table department
CREATE TABLE departments (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(50)
);
--cretaed table salary details
CREATE TABLE salary_details (
    emp_id NUMBER,
    basic NUMBER,
    hra NUMBER,
    bonus NUMBER,
    tax NUMBER,
    net_salary NUMBER,
    salary_month VARCHAR2(20)
);


--insert data into employees
INSERT INTO employees VALUES (101, 'Amit', 1, 30000);
INSERT INTO employees VALUES (102, 'Neha', 2, 40000);
INSERT INTO employees VALUES (103, 'Rahul', 3, 50000);

--insert data into departments
INSERT INTO departments VALUES (1, 'HR');
INSERT INTO departments VALUES (2, 'IT');


--created function 
CREATE OR REPLACE FUNCTION calc_tax(p_basic NUMBER)
RETURN NUMBER
IS
BEGIN
    IF p_basic < 30000 THEN
        RETURN p_basic * 0.05;
    ELSIF p_basic < 50000 THEN
        RETURN p_basic * 0.10;
    ELSE
        RETURN p_basic * 0.15;
    END IF;
END;
/

--cretaed package
CREATE OR REPLACE PACKAGE payroll_pkg AS
    PROCEDURE calculate_salary(p_emp_id NUMBER, p_month VARCHAR2);
END payroll_pkg;
/

--created package body
CREATE OR REPLACE PACKAGE BODY payroll_pkg AS
PROCEDURE calculate_salary(p_emp_id NUMBER, p_month VARCHAR2) IS
    v_basic NUMBER;
    v_hra NUMBER;
    v_bonus NUMBER := 2000;
    v_tax NUMBER;
    v_net NUMBER;
BEGIN
    SELECT basic_salary INTO v_basic
    FROM employees
    WHERE emp_id = p_emp_id;

    v_hra := v_basic * 0.20;
    v_tax := calc_tax(v_basic);
    v_net := v_basic + v_hra + v_bonus - v_tax;

    INSERT INTO salary_details
    VALUES (p_emp_id, v_basic, v_hra, v_bonus, v_tax, v_net, p_month);

    DBMS_OUTPUT.PUT_LINE('Salary Calculated Successfully');
END;
END payroll_pkg;
/


--created cursor
DECLARE
    CURSOR c_salary IS
        SELECT e.emp_name, s.net_salary
        FROM employees e
        JOIN salary_details s ON e.emp_id = s.emp_id
        WHERE s.salary_month = 'JAN';

    v_name employees.emp_name%TYPE;
    v_salary salary_details.net_salary%TYPE;
BEGIN
    OPEN c_salary;
    LOOP
        FETCH c_salary INTO v_name, v_salary;
        EXIT WHEN c_salary%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' → ' || v_salary);
    END LOOP;
    CLOSE c_salary;n   
END;
/

--created salary audit
CREATE TABLE salary_audit (
    emp_id NUMBER,
    old_salary NUMBER,
    new_salary NUMBER,
    changed_on DATE
);

--created trigger
CREATE OR REPLACE TRIGGER trg_salary_audit
AFTER UPDATE OF net_salary ON salary_details
FOR EACH ROW
BEGIN
    INSERT INTO salary_audit
    VALUES (:OLD.emp_id, :OLD.net_salary, :NEW.net_salary, SYSDATE);
END;
/


BEGIN
    payroll_pkg.calculate_salary(101, 'JAN');
    payroll_pkg.calculate_salary(102, 'JAN');
END;
/
select * from salary_details;
