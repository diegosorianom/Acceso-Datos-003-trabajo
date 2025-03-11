-- ---------------------
-- TRIGGERS OBLIGATORIOS
-- ---------------------

-- Trigger para auditar el borrado de obras
CREATE OR REPLACE TRIGGER auditar_borrado_obra
BEFORE DELETE ON obra
FOR EACH ROW
BEGIN
    INSERT INTO obra_historico(id, titulo, anyo, fecha_borrado)
    VALUES (:OLD.id, :OLD.titulo, :OLD.anyo, SYSTIMESTAMP);
END;
/

-- ---------------
-- FIN DE TRIGGERS
-- ---------------

-- --------------
-- FIN DE INSERTS
-- --------------

-- -------------------------------------------
-- PRUEBAS PARA FUNCIONES DEL PAQUETE BiblioTK
-- -------------------------------------------
DECLARE
    -- Variables para alta de obra
    v_obra1_id VARCHAR2(5);
    v_obra2_id VARCHAR2(5);
    v_obra3_id VARCHAR2(5);
    v_obra_inexistente VARCHAR2(5) := 'XXXXX'; -- ID falso para pruebas negativas
    
    -- Variables para alta de autor
    v_autor1_id VARCHAR2(4);
    v_autor2_id VARCHAR2(4);
    v_autor_inexistente VARCHAR2(4) := 'ZZZZ'; -- ID falso para pruebas negativas

    -- Variables para ediciones
    v_edicion1_id VARCHAR2(6);
    v_edicion2_id VARCHAR2(6);
    v_edicion_inexistente VARCHAR2(6) := 'YYYYYY'; -- ID falso para pruebas negativas
    
    -- Variables para ejemplares
    v_numero_ejemplar INTEGER;
    v_numero_ejemplar2 INTEGER;
    
    -- Variables de resultados
    v_result INTEGER;

BEGIN
    -- **PRUEBAS DE ALTA DE OBRAS**
    v_obra1_id := BiblioTK.alta_obra('El Quijote', 1605);
    v_obra2_id := BiblioTK.alta_obra('1984', 1949);
    v_obra3_id := BiblioTK.alta_obra('Cien Años de Soledad', 1967);

    DBMS_OUTPUT.PUT_LINE('Obra 1 creada con ID: ' || v_obra1_id);
    DBMS_OUTPUT.PUT_LINE('Obra 2 creada con ID: ' || v_obra2_id);
    DBMS_OUTPUT.PUT_LINE('Obra 3 creada con ID: ' || v_obra3_id);

    -- **PRUEBAS DE ALTA DE AUTORES**
    v_autor1_id := BiblioTK.alta_autor('Miguel', 'de Cervantes', TO_DATE('1547-09-29', 'YYYY-MM-DD'));
    v_autor2_id := BiblioTK.alta_autor('George', 'Orwell', TO_DATE('1903-06-25', 'YYYY-MM-DD'));

    DBMS_OUTPUT.PUT_LINE('Autor 1 creado con ID: ' || v_autor1_id);
    DBMS_OUTPUT.PUT_LINE('Autor 2 creado con ID: ' || v_autor2_id);

    -- **PRUEBAS DE VINCULACIÓN DE AUTOR-OBRA**
    v_result := BiblioTK.vincular(v_autor1_id, v_obra1_id);
    IF v_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor vinculado correctamente a la obra.');
    END IF;

    -- Intentar vincular el mismo autor-obra (debe fallar)
    v_result := BiblioTK.vincular(v_autor1_id, v_obra1_id);
    IF v_result = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: El autor ya estaba vinculado a la obra.');
    END IF;

    -- Intentar vincular autor inexistente
    v_result := BiblioTK.vincular(v_autor_inexistente, v_obra1_id);
    IF v_result = -2 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Autor no encontrado.');
    END IF;

    -- Intentar vincular obra inexistente
    v_result := BiblioTK.vincular(v_autor1_id, v_obra_inexistente);
    IF v_result = -3 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Obra no encontrada.');
    END IF;

    -- **PRUEBAS DE DESVINCULACIÓN DE AUTOR-OBRA**
    v_result := BiblioTK.desvincular(v_autor1_id, v_obra1_id);
    IF v_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Desvinculación exitosa.');
    END IF;

    -- Intentar desvincular relación inexistente
    v_result := BiblioTK.desvincular(v_autor1_id, v_obra1_id);
    IF v_result = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: La relación no existía.');
    END IF;

    -- **PRUEBAS DE ALTA DE EDICIONES**
    v_edicion1_id := BiblioTK.alta_edicion(v_obra1_id, '1234567890123', 2000);
    v_edicion2_id := BiblioTK.alta_edicion(v_obra2_id, '9876543210987', 1990);

    DBMS_OUTPUT.PUT_LINE('Edición creada con ID: ' || v_edicion1_id);
    DBMS_OUTPUT.PUT_LINE('Edición creada con ID: ' || v_edicion2_id);

    -- Intentar crear edición con obra inexistente
    v_edicion_inexistente := BiblioTK.alta_edicion(v_obra_inexistente, '1111111111111', 2020);
    IF v_edicion_inexistente = '0' THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: No se puede crear edición de una obra inexistente.');
    END IF;

    -- **PRUEBAS DE ALTA DE EJEMPLARES**
    v_numero_ejemplar := BiblioTK.alta_ejemplar(v_edicion1_id);
    v_numero_ejemplar2 := BiblioTK.alta_ejemplar(v_edicion1_id);

    DBMS_OUTPUT.PUT_LINE('Ejemplar 1 creado con número: ' || v_numero_ejemplar);
    DBMS_OUTPUT.PUT_LINE('Ejemplar 2 creado con número: ' || v_numero_ejemplar2);

    -- Intentar crear ejemplar con edición inexistente
    v_result := BiblioTK.alta_ejemplar(v_edicion_inexistente);
    IF v_result = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: No se puede crear ejemplar de una edición inexistente.');
    END IF;

    -- **PRUEBAS DE BORRADO DE OBRAS**
    v_result := BiblioTK.borrado_obra(v_obra3_id);
    IF v_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Obra 3 eliminada correctamente.');
    END IF;

    -- Intentar eliminar obra inexistente
    v_result := BiblioTK.borrado_obra(v_obra_inexistente);
    IF v_result = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: No se puede eliminar una obra inexistente.');
    END IF;

    -- **PRUEBAS DE BORRADO DE AUTORES**
    v_result := BiblioTK.borrado_autor(v_autor2_id);
    IF v_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor 2 eliminado correctamente.');
    END IF;

    -- Intentar eliminar autor inexistente
    v_result := BiblioTK.borrado_autor(v_autor_inexistente);
    IF v_result = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: No se puede eliminar un autor inexistente.');
    END IF;

    -- **PRUEBAS DE BAJA DE EJEMPLARES**
    v_result := BiblioTK.baja_ejemplar(v_edicion1_id, v_numero_ejemplar);
    IF v_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Ejemplar dado de baja correctamente.');
    END IF;

    -- Intentar dar de baja un ejemplar inexistente
    v_result := BiblioTK.baja_ejemplar(v_edicion1_id, 99);
    IF v_result = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Ejemplar no encontrado.');
    END IF;

    COMMIT;
END;
/


-- -----------
-- Fin Pruebas
-- -----------