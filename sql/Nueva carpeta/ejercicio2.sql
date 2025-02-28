CREATE OR REPLACE PROCEDURE
    CODIFICAR_CADENA(v_cadena IN VARCHAR2)
AS
    v_cadenaCodificada VARCHAR2(200);
BEGIN
    FOR i IN REVERSE 1..LENGTH(v_cadena) LOOP
        v_cadenaCodificada := v_cadenaCodificada || SUBSTR(v_cadena, i, 1);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' Cadena codificada: ' || v_cadenaCodificada);
END;
/

EXEC CODIFICAR_CADENA('hola');