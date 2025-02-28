Para poder crear el Trigger necesitaré un usuario que no sea el SYSDBA o realizar la siguiente configuración:


ALTER USER HR ACCOUNT UNLOCK;
ALTER USER HR IDENTIFIED BY LOLO;

-- Trigger que controla la modificación de salarios de empleados a la baja
-- cada vez que a un empleado se le baje el sueldo se registrará en 
-- una tabla dde auditoría los datos del empleado y la fecha de la modificación

alter session set "_ORACLE_SCRIPT"=true;

CREATE USER LOLO IDENTIFIED BY LOLO;
GRANT CONNECT TO LOLO;
GRANT RESOURCE TO LOLO;

ALTER USER LOLO ACCOUNT UNLOCK;
ALTER USER LOLO IDENTIFIED BY LOLO;

-- A partir de aquí trabajamos con el usuario HR

CREATE TABLE emple_auditado (emp_no NUMBER(4), apellido VARCHAR2(10), 
      salario_viejo NUMBER(7), salario_nuevo NUMBER(7), fecha DATE);

-- CREATE OR REPLACE TRIGGER mod_emple BEFORE UPDATE ON emple FOR EACH ROW 
-- BEGIN
--   IF (:new.salario <:old.salario) THEN
--      INSERT INTO emple_auditado VALUES (:old.emp_no, :old.apellido, :old.salario, 
--                     :new.salario, SYSDATE);
--   END IF;
-- END;
-- /

CREATE OR REPLACE TRIGGER mod_emple BEFORE UPDATE ON emple 
BEGIN
  IF (:new.salario <:old.salario) THEN
     INSERT INTO emple_auditado VALUES (:old.emp_no, :old.apellido, :old.salario, 
                    :new.salario, SYSDATE);
  END IF;
END;
/

-- RESTRICCIONES

-- NO PUEDE CONTENER:
-- REALIZAR TRANSACCIONES
-- COMMIT
-- ROLLBACK
-- SAVEPOINT

CREATE OR REPLACE TRIGGER mod_emple BEFORE UPDATE ON emple FOR EACH ROW
BEGIN
    IF (:new.salario <:old.salario) THEN
        INSERT INTO emple_auditado VALUES (:old.emp_no, :old.apellido, :old.salario, :new.salario, SYSDATE);
      COMMIT;
    END IF;
  END;
/

UPDATE EMPLE SET SALARIO = SALARIO*0.9
  WHERE EMP_NO = 7654;

ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy HH:MI';

SELECT * FROM emple_auditado;

    EMP_NO APELLIDO   SALARIO_VIEJO SALARIO_NUEVO FECHA
---------- ---------- ------------- ------------- ----------------
      7654 MARTIN              1600          1440 26/02/2024 09:16