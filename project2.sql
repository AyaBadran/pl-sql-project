
CREATE OR REPLACE FUNCTION calculate_city_quota(p_city_id NUMBER, p_branch_count NUMBER)
  RETURN NUMBER IS
  v_city_bonus NUMBER;
BEGIN
  SELECT city_bonus
    INTO v_city_bonus
  FROM cities
  WHERE CITY_ID = p_city_id;
  
  RETURN v_city_bonus / p_branch_count;
END;

---------------
CREATE OR REPLACE PROCEDURE distribute_city_bonus IS
  CURSOR branches_cursor IS
    SELECT city_id, COUNT(*) AS branch_count
    FROM branches
    GROUP BY city_id;
  v_quota NUMBER;
BEGIN
  FOR branches_record IN branches_cursor LOOP
    v_quota := calculate_city_quota(branches_record.city_id, branches_record.branch_count);
    UPDATE branches
    SET branch_bonus = v_quota
    WHERE city_id = branches_record.city_id;
  END LOOP;
END;
--------------------------------------------

CREATE OR REPLACE FUNCTION EMPS_bonus(p_branch_id NUMBER, p_branch_EMPSS_count NUMBER) 
  RETURN NUMBER IS
  p_branch_EMPS_bonus NUMBER;
  v_branch_bonus NUMBER;
BEGIN
  SELECT branch_bonus
    INTO v_branch_bonus
  FROM branches
  WHERE branch_id = p_branch_id;
  
  p_branch_EMPS_bonus := v_branch_bonus * 0.5 / p_branch_EMPSS_count;
  RETURN p_branch_EMPS_bonus;
END;
-------------------------
CREATE OR REPLACE PROCEDURE distribute_bonus_mgr IS
  CURSOR managers_cursor IS
    SELECT branch_id, COUNT(*) AS mgr_count
    FROM branch_employees
    WHERE employee_position = 'MGR'
    GROUP BY branch_id;
  v_mgr_bonus NUMBER;
BEGIN
  FOR manager_record IN managers_cursor LOOP
    v_mgr_bonus := EMPS_bonus(manager_record.branch_id, manager_record.mgr_count);
    UPDATE branch_employees
    SET employee_bonus = v_mgr_bonus
    WHERE branch_id = manager_record.branch_id
    and  employee_position = 'MGR';
  END LOOP;
END;
--------------------------
CREATE OR REPLACE PROCEDURE distribute_bonus_emp IS
  CURSOR employee_cursor IS
    SELECT branch_id, COUNT(*) AS emp_count
    FROM branch_employees
    WHERE employee_position = 'EMP'
    GROUP BY branch_id;
  v_emp_bonus NUMBER;
BEGIN
  FOR employee_record IN employee_cursor LOOP
    v_emp_bonus := EMPS_bonus(employee_record.branch_id, employee_record.emp_count);
    UPDATE branch_employees
    SET employee_bonus = v_emp_bonus
    WHERE branch_id = employee_record.branch_id 
    and  employee_position = 'EMP';
  END LOOP;
END;
-----------------
DECLARE
BEGIN
  distribute_city_bonus;
  distribute_bonus_mgr;
  distribute_bonus_emp;
END;

/*
select * from cities;
select * from branches;
select * from branch_employees;
UPDATE branches SET BRANCH_BONUS=0;
UPDATE branch_employees SET EMPLOYEE_BONUS=0;
*/
