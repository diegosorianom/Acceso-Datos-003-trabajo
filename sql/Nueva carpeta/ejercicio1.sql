CREATE OR REPLACE PROCEDURE
    SUMAR(v_numero1 IN NUMBER, v_numero2 IN NUMBER)
AS
    v_suma NUMBER;
BEGIN
    v_suma := v_numero1 + v_numero2;
    DBMS_OUTPUT.PUT_LINE('La suma es: ' || v_suma);
END;
/

EXEC SUMAR(10, 5);