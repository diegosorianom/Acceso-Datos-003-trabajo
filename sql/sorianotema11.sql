-- Ejercicio 1
-- Escribe un procedimiento que reciba dos numeros y visualice su suma

CREATE OR REPLACE PROCEDURE SUMAR(n1 IN NUMBER, n2 IN NUMBER)
AS 
    resultado_suma NUMBER;
BEGIN 
    -- Calcular la suma de los dos números
    resultado_suma := n1 + n2;

    -- Mostrar el resultado
    DBMS_OUTPUT.PUT_LINE('La suma es: ' || resultado_suma);
END;
/

EXEC P_SUMAR(10, 5);

-- Ejercicio 2
-- Codifica un procedimiento que reciba una cadena y la visualice al revés

CREATE OR REPLACE PROCEDURE INVERTIR_CADENA(cadena_normal IN VARCHAR2)
AS
    cadena_invertida VARCHAR2(200);
BEGIN
    FOR i IN REVERSE 1..LENGTH(cadena_normal) LOOP
        cadena_invertida := cadena_invertida || SUBSTR(cadena_normal, i, 1);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' Cadena codificada: ' || cadena_invertida);
END;
/

EXEC INVERTIR_CADENA('hola');

-- Ejercicio 3
-- Reescribe el código de los dos ejercicios anteriores para convertirlos en funciones que retornen los valores que mostraban los procedimientos

CREATE OR REPLACE FUNCTION SUMAR(n1 IN NUMBER, n2 IN NUMBER)
RETURN VARCHAR2
IS 
    resultado_suma NUMBER;
BEGIN 
    resultado_suma := n1 + n2;
    RETURN resultado_suma;
END;
/

SELECT SUMAR(11, 43) FROM dual;
    

CREATE OR REPLACE FUNCTION INVERTIR_CADENA(cadena_normal IN VARCHAR2)
RETURN VARCHAR2
IS
cadena_invertida VARCHAR2(200);
BEGIN    
    FOR i in REVERSE 1..LENGTH(cadena_normal) LOOP
        cadena_invertida := cadena_invertida || SUBSTR(cadena_normal, i, 1);
    END LOOP;
    RETURN cadena_invertida;
END;
/

SELECT INVERTIR_CADENA('sql') FROM dual;


-- Ejercicio 4
-- Escribe una función que reciba una fecha y devuelva el año, en número, correspondiente a esa fecha
CREATE OR REPLACE FUNCTION VER_FECHA(fecha IN DATE)
RETURN NUMBER
IS 
    anio NUMBER(4);
BEGIN
    anio := SUBSTR(TO_CHAR(fecha, 'YYYY-MM-DD'), 1, 4);
    RETURN anio;
END;
/

SELECT VER_FECHA(SYSDATE) FROM dual;
SELECT VER_FECHA(TO_DATE('2025-10-01', 'YYYY-MM-DD')) FROM dual;


-- Ejercicio 5
-- Escribe un bloque PL/SQL que haga uso de la función anterior
DECLARE
    fecha DATE := TO_DATE('2025-10-01', 'YYYY-MM-DD');
    anio NUMBER;
BEGIN
    anio := VER_FECHA(fecha);
    DBMS_OUTPUT.PUT_LINE('Año: ' || anio);
END;
/


-- Ejercicio 6
-- Desarrolla una fucnión que devuelva el número de años completos que hay entre dos fechas que se pasan como parametros
CREATE OR REPLACE FUNCTION ENTRE_FECHAS(fecha1 IN DATE, fecha2 IN DATE)
RETURN NUMBER
IS
    anio1 NUMBER(4);
    anio2 NUMBER(4);
    aniosEntreFechas NUMBER(4);
BEGIN
    anio1 := SUBSTR(TO_CHAR(fecha1, 'YYYY-MM-DD'), 1, 4);
    anio2 := SUBSTR(TO_CHAR(fecha2, 'YYYY-MM-DD'), 1, 4);
    aniosEntreFechas := anio2 - anio1;
    RETURN aniosEntreFechas;
END;
/

SELECT ENTRE_FECHAS(TO_DATE('1990-10-01', 'YYYY-MM-DD'), TO_DATE('2025-10-01', 'YYYY-MM-DD')) FROM dual;


-- Ejercicio 7
-- Escribe una función que, haciendo uso de la función anterior, devuelva los trienios que hay entre dos fechas (un trienio son tres años).
CREATE OR REPLACE FUNCTION TRIENIOS_ENTRE_FECHAS(fecha1 IN DATE, fecha2 IN DATE)
RETURN NUMBER
IS
    trienios NUMBER(4);
BEGIN
    trienios := FLOOR(ENTRE_FECHAS(fecha1, fecha2) / 3);
    RETURN trienios;
END;
/

SELECT TRIENIOS_ENTRE_FECHAS(TO_DATE('1990-10-01', 'YYYY-MM-DD'), TO_DATE('2025-10-01', 'YYYY-MM-DD')) FROM dual;


-- Ejercicio 8
-- Codifica un procedimiento que reciba una lista de hasta cinco números y visualice su suma
CREATE OR REPLACE PROCEDURE SUMA_5_NUMEROS(
    n1 IN NUMBER,
    n2 IN NUMBER,
    n3 IN NUMBER,
    n4 IN NUMBER,
    n5 IN NUMBER
)
AS 
    suma NUMBER(10);
BEGIN
    suma := n1 + n2 + n3 + n4 + n5;
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || suma);
END;
/

EXEC SUMA_5_NUMEROS(1,2,3,4,5);


-- Ejercicio 9
-- Escribe una función que devuelva solamente caracteres alfabéticos sustituyendo cualquier otro carácter por blancos a partir de una cadena que se pasará en la llamada
CREATE OR REPLACE FUNCTION CARACTERES_ALFABETICOS(cadena IN VARCHAR2)
RETURN VARCHAR2
IS
    cadenaAlfabetica VARCHAR2(200);
BEGIN   
    cadenaAlfabetica := REGEXP_REPLACE(cadena, '[^A-Za-z]', '');
    RETURN cadenaAlfabetica;
END;
/

SELECT CARACTERES_ALFABETICOS('hola123454') FROM DUAL;


-- Ejercicio 10
-- Codifica un procedimiento que permita borrar un empleado cuyo número se pasará en la llmada
CREATE OR REPLACE PROCEDURE  ELIMINAR_EMPLEADO(numeroEmpleado IN NUMBER)
AS
BEGIN
    DELETE FROM EMPLE WHERE EMP_NO = numeroEmpleado;
END;
/

EXEC ELIMINAR_EMPLEADO(7844);


-- Ejercicio 11
-- Escribe un procedimiento que modifique la localidad de un departamento. El procedimiento recibirá como parámetros el número del departamento y la nueva localidad
CREATE OR REPLACE PROCEDURE MODIFICAR_LOCALIDAD(numeroDepartamento IN NUMBER, nuevaLocalidad IN VARCHAR2)
AS
BEGIN
    UPDATE DEPART SET LOC = nuevaLocalidad WHERE DEPT_NO = numeroDepartamento;
    DBMS_OUTPUT.PUT_LINE('Localidad del departamento: ' || numeroDepartamento || ' modificada a: ' || nuevaLocalidad || '');
END;
/

EXEC MODIFICAR_LOCALIDAD(30, 'Valencia');


-- Ejercicio 12
-- Visualiza todos los procedimientos y funciones del usuario almacenados en la base de datos y su situación (valid o invalid)
SELECT OBJECT_NAME AS PROCEDURE_NAME, STATUS
FROM USER_OBJECTS WHERE OBJECT_TYPE = 'PROCEDURE' OR OBJECT_TYPE = 'FUNCTION' ORDER BY OBJECT_NAME;