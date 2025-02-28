-- 1. Desarrolla un procedimiento que visualice el apellido y la fecha de alta de todos los empleados ordenado por apellido

CREATE OR REPLACE PROCEDURE ver_empleados_ordenados IS
    -- Definir el cursor
    CURSOR emp_cursor IS
        SELECT APELLIDO, FECHA_ALT
        FROM EMPLE
        ORDER BY APELLIDO;

    -- Variables para almacenar los datos obtenidos del cursor
    v_apellido EMPLE.APELLIDO%TYPE;
    v_fecha_alt EMPLE.FECHA_ALT%TYPE;

BEGIN
    -- Abrir el cursor
    OPEN emp_cursor;

    -- Recorrer los resultados del cursor
    LOOP
        FETCH emp_cursor INTO v_apellido, v_fecha_alt;
        EXIT WHEN emp_cursor%NOTFOUND;

        -- Mostrar los resultados
        DBMS_OUTPUT.PUT_LINE('Apellido: ' || v_apellido || ', Fecha de alta: ' || TO_CHAR(v_fecha_alt, 'DD/MM/YYYY'));
    END LOOP;

    -- Cerrar el cursor
END ver_empleados_ordenados;
/

-- Ejecutar el procedimiento
BEGIN
    ver_empleados_ordenados;
END;
/

-- 2. Codifica un procedimiento que muestre el nombre de cada departamento y el número de empleados que tiene

CREATE OR REPLACE PROCEDURE ver_departamentos_con_empleados IS
    -- Definir el cursor para obtener el nombre del departamento y su número de empleados
    CURSOR dept_cursor IS
        SELECT D.DNOMBRE, COUNT(E.EMP_NO) AS NUM_EMPLEADOS
        FROM DEPART D
        LEFT JOIN EMPLE E ON D.DEPT_NO = E.DEPT_NO
        GROUP BY D.DNOMBRE;
    
    -- Variables para almacenar los datos obtenidos del cursor
    v_dnombre DEPART.DNOMBRE%TYPE;
    v_num_empleados NUMBER;
BEGIN
    -- Abrir el cursor
    OPEN dept_cursor;
    
    -- Recorrer los resultados del cursor
    LOOP
        FETCH dept_cursor INTO v_dnombre, v_num_empleados;
        EXIT WHEN dept_cursor%NOTFOUND;
        
        -- Mostrar los resultados
        DBMS_OUTPUT.PUT_LINE('Departamento: ' || v_dnombre || ', Número de Empleados: ' || v_num_empleados);
    END LOOP;
    
    -- Cerrar el cursor
    CLOSE dept_cursor;
END ver_departamentos_con_empleados;
/


BEGIN
    ver_departamentos_con_empleados;
END;
/

-- 3. Escribe un programa que visualice el apellido y el salario de los cinco empleados que tienen el salario más alto

CREATE OR REPLACE PROCEDURE ver_top_5_salarios IS
    -- Definir el cursor para obtener los cinco empleados con el salario más alto
    CURSOR salario_cursor IS
        SELECT APELLIDO, SALARIO
        FROM EMPLE
        ORDER BY SALARIO DESC
        FETCH FIRST 5 ROWS ONLY;

    -- Variables para almacenar los datos obtenidos del cursor
    v_apellido EMPLE.APELLIDO%TYPE;
    v_salario EMPLE.SALARIO%TYPE;
BEGIN
    -- Abrir el cursor
    OPEN salario_cursor;

    -- Recorrer los resultados del cursor
    LOOP
        FETCH salario_cursor INTO v_apellido, v_salario;
        EXIT WHEN salario_cursor%NOTFOUND;

        -- Mostrar los resultados
        DBMS_OUTPUT.PUT_LINE('Apellido: ' || v_apellido || ', Salario: ' || v_salario);
    END LOOP;

    -- Cerrar el cursor
    CLOSE salario_cursor;
END ver_top_5_salarios;
/

BEGIN
    ver_top_5_salarios;
END;
/

-- 4. Codifica un programa que visualice los dos empleados que ganan menos de cada oficio

