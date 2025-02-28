CREATE OR REPLACE FUNCTION
    VER_ANO(v_fecha IN DATE)
RETURN NUMBER
IS
    v_ano NUMBER(4);
BEGIN
    v_ano := SUBSTR(TO_CHAR(v_fecha, 'YYYY-MM-DD'), 1, 4);
    RETURN v_ano;
END;
/

SELECT VER_ANO(SYSDATE) FROM dual;

SELECT VER_ANO(TO_DATE('2025-10-01', 'YYYY-MM-DD')) FROM dual;





-- Testeo con declare

DECLARE
    v_fecha DATE;
    v_ano NUMBER(4);
BEGIN
    v_fecha := SYSDATE;
    v_ano := SUBSTR(TO_CHAR(v_fecha, 'YYYY-MM-DD'), 1, 4);
    DBMS_OUTPUT.PUT_LINE( v_ano );
    DBMS_OUTPUT.PUT_LINE( TO_CHAR(v_fecha, 'YYYY-MM-DD') );
END;
/

