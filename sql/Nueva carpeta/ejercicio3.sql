-- #######
-- PARTE 1
-- #######

CREATE OR REPLACE FUNCTION
    SUMAR(v_numero1 IN NUMBER, v_numero2 IN NUMBER)
RETURN VARCHAR2
IS
    v_suma NUMBER;
BEGIN
    v_suma := v_numero1 + v_numero2;
    RETURN v_suma;
END;
/

SELECT SUMAR(10, 5) FROM dual;

-- #######
-- PARTE 2
-- #######

CREATE OR REPLACE FUNCTION
    CODIFICAR_CADENA(v_cadena IN VARCHAR2)
RETURN VARCHAR2 
IS
v_cadenaCodificada VARCHAR2(200);
BEGIN
    FOR i IN REVERSE 1..LENGTH(v_cadena) LOOP
        v_cadenaCodificada := v_cadenaCodificada || SUBSTR(v_cadena, i, 1);
    END LOOP;
    RETURN v_cadenaCodificada;
END;
/

SELECT CODIFICAR_CADENA('hola') FROM dual;