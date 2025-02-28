DECLARE
v_dept10 NUMBER(2);
v_dept99 NUMBER(2);
v_num_empleados NUMBER(2);
BEGIN
  SELECT COUNT(*) INTO v_dept99 FROM DEPART WHERE dept_no=99;
  IF(v_dept99=0)
    THEN
      INSERT INTO DEPART VALUES (99, 'PROVISIONAL', NULL);
  END IF;
  SELECT COUNT(*) INTO v_dept10 FROM DEPART WHERE dept_no=10;
  IF(v_dept10=1)
    THEN
      UPDATE EMPLE SET dept_no = 99 WHERE dept_no = 10;
      v_num_empleados := SQL%ROWCOUNT;
      DBMS_OUTPUT.PUT_LINE(v_num_empleados || ' empleados ubicados en TEMPORAL ');
    ELSE
      DBMS_OUTPUT.PUT_LINE(' El departamento 10 no existe, no lo puedo borrar ');
  END IF;
  
DELETE FROM DEPART WHERE dept_no = 10;
  
END;
/