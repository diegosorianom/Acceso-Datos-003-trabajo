CREATE OR REPLACE PROCEDURE
    MODIFICAR_LOCALIDAD_DEPARTAMENTO(v_numeroDepartamento IN NUMBER, v_nuevaLocalidad IN VARCHAR2)
AS
BEGIN
    UPDATE DEPART SET LOC = v_nuevaLocalidad WHERE DEPT_NO = v_numeroDepartamento;
    DBMS_OUTPUT.PUT_LINE('Localidad del departamento ' || v_numeroDepartamento || ' modificada a ''' || v_nuevaLocalidad || '''' );
END;
/

EXEC MODIFICAR_LOCALIDAD_DEPARTAMENTO(10, 'Huelva');