CREATE OR REPLACE PROCEDURE
    SUMA_5_NUMEROS(
        numero1 IN NUMBER,
        numero2 IN NUMBER,
        numero3 IN NUMBER,
        numero4 IN NUMBER,
        numero5 IN NUMBER
    )
AS
    v_suma NUMBER(10);
BEGIN
    v_suma := numero1 + numero2 + numero3 + numero4 + numero5;
    DBMS_OUTPUT.PUT_LINE('La suma es: ' || v_suma);
END;
/

EXEC SUMA_5_NUMEROS(1,2,3,4,5);