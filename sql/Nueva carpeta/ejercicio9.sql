CREATE OR REPLACE FUNCTION
    SOLO_ALFABETICOS(v_cadena IN VARCHAR2)
RETURN VARCHAR2
IS
    v_cadenaSoloAlfabeticos VARCHAR2(200);
BEGIN
v_cadenaSoloAlfabeticos := REGEXP_REPLACE(v_cadena, '[^A-Za-z]', '');
    RETURN v_cadenaSoloAlfabeticos;
END;
/

SELECT SOLO_ALFABETICOS('holañ*Ç') FROM dual;