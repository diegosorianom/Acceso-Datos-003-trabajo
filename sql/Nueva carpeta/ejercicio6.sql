CREATE OR REPLACE FUNCTION
    ANOS_ENTRE_FECHAS(v_fecha1 IN DATE, v_fecha2 IN DATE)
RETURN NUMBER
IS
    v_ano1 NUMBER(4);
    v_ano2 NUMBER(4);
    v_anosEntreFechas NUMBER(4);
BEGIN
    v_ano1 := SUBSTR(TO_CHAR(v_fecha1, 'YYYY-MM-DD'), 1, 4);
    v_ano2 := SUBSTR(TO_CHAR(v_fecha2, 'YYYY-MM-DD'), 1, 4);
    v_anosEntreFechas := v_ano2 - v_ano1;
    RETURN v_anosEntreFechas;
END;
/

SELECT ANOS_ENTRE_FECHAS(TO_DATE('2025-10-01', 'YYYY-MM-DD'), TO_DATE('2024-10-01', 'YYYY-MM-DD')) FROM dual;