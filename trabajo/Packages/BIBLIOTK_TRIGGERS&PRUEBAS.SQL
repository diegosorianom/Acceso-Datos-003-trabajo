-- ---------------------
-- TRIGGERS OBLIGATORIOS
-- ---------------------

-- 1. Trigger para auditar el borrado de obras
CREATE OR REPLACE TRIGGER auditar_borrado_obra
BEFORE DELETE ON obra
FOR EACH ROW
BEGIN
    INSERT INTO obra_historico(id, titulo, anyo, fecha_borrado)
    VALUES (:OLD.id, :OLD.titulo, :OLD.anyo, SYSTIMESTAMP);
END;
/

-- 2. Trigger para auditar el borrado de autores
CREATE OR REPLACE TRIGGER auditar_borrado_autor
BEFORE DELETE ON autor
FOR EACH ROW
BEGIN
    INSERT INTO autor_historico (id, nombre, apellidos, nacimiento, fecha_borrado)
    VALUES (:OLD.id, :OLD.nombre, :OLD.apellidos, :OLD.nacimiento, SYSTIMESTAMP);
END;
/

-- 3. Trigger para auditar el borrado de ediciones
CREATE OR REPLACE TRIGGER auditar_borrado_edicion
BEFORE DELETE ON edicion
FOR EACH ROW
BEGIN
    INSERT INTO edicion_historico (id, id_obra, isbn, anyo, fecha_borrado)
    VALUES (:OLD.id, :OLD.id_obra, :OLD.isbn, :OLD.anyo, SYSTIMESTAMP);
END;
/

-- 4. Trigger para auditar el borrado de ejemplares
CREATE OR REPLACE TRIGGER auditar_borrado_ejemplar
BEFORE DELETE ON ejemplar
FOR EACH ROW
BEGIN
    INSERT INTO ejemplar_historico (id_edicion, numero, alta, baja, fecha_borrado)
    VALUES (:OLD.id_edicion, :OLD.numero, :OLD.alta, :OLD.baja, SYSTIMESTAMP);
END;
/

-- -----------------------------------
-- PRUEBAS PARA FUNCIONES OBLIGATORIAS
-- -----------------------------------
SET SERVEROUTPUT ON;

DECLARE
    v_resultado INTEGER;
    v_id_obra VARCHAR2(5) := 'TEST1';
    v_id_autor VARCHAR2(4) := 'AUT1';
    v_id_edicion VARCHAR2(6) := 'EDIT01';
    v_id_ejemplar INTEGER := 1;
BEGIN
    -- 1. PRUEBA: Insertar una obra con ID estático
    DBMS_OUTPUT.PUT_LINE('PRUEBA 1: Creación de una obra con ID preestablecido');
    INSERT INTO obra (id, titulo, anyo) VALUES (v_id_obra, 'El Camino de los Reyes', 2010);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Obra creada con ID: ' || v_id_obra);

    -- 2. PRUEBA: Borrar una obra y verificar en el histórico
    DBMS_OUTPUT.PUT_LINE('PRUEBA 2: Eliminación de la obra');
    DELETE FROM obra WHERE id = v_id_obra;
    COMMIT;

    DECLARE
        v_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM obra_historico WHERE id = v_id_obra;
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('La obra fue almacenada en el histórico correctamente.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error: La obra no está en el histórico.');
        END IF;
    END;

    -- 3. PRUEBA: Insertar un autor con ID estático
    DBMS_OUTPUT.PUT_LINE('PRUEBA 3: Creación de un autor con ID preestablecido');
    INSERT INTO autor (id, nombre, apellidos, nacimiento) 
    VALUES (v_id_autor, 'Brandon', 'Sanderson', TO_DATE('1975-12-19', 'YYYY-MM-DD'));
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Autor creado con ID: ' || v_id_autor);

    -- 4. PRUEBA: Borrar un autor y verificar en el histórico
    DBMS_OUTPUT.PUT_LINE('PRUEBA 4: Eliminación del autor');
    DELETE FROM autor WHERE id = v_id_autor;
    COMMIT;

    DECLARE
        v_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM autor_historico WHERE id = v_id_autor;
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('El autor fue almacenado en el histórico correctamente.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error: El autor no está en el histórico.');
        END IF;
    END;

    -- 5. PRUEBA: Insertar una edición con ID preestablecido
    DBMS_OUTPUT.PUT_LINE('PRUEBA 5: Creación de una edición con ID preestablecido');
    INSERT INTO edicion (id, id_obra, isbn, anyo) 
    VALUES (v_id_edicion, 'TEST1', '978-1234567890', 2015);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Edición creada con ID: ' || v_id_edicion);

    -- 6. PRUEBA: Borrar una edición y verificar en el histórico
    DBMS_OUTPUT.PUT_LINE('PRUEBA 6: Eliminación de la edición');
    DELETE FROM edicion WHERE id = v_id_edicion;
    COMMIT;

    DECLARE
        v_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM edicion_historico WHERE id = v_id_edicion;
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('La edición fue almacenada en el histórico correctamente.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error: La edición no está en el histórico.');
        END IF;
    END;

    -- 7. PRUEBA: Insertar un ejemplar con ID preestablecido
    DBMS_OUTPUT.PUT_LINE('PRUEBA 7: Creación de un ejemplar con ID preestablecido');
    INSERT INTO ejemplar (id_edicion, numero, alta, baja)
    VALUES (v_id_edicion, v_id_ejemplar, SYSDATE, NULL);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Ejemplar creado con número: ' || v_id_ejemplar);

    -- 8. PRUEBA: Borrar un ejemplar y verificar en el histórico
    DBMS_OUTPUT.PUT_LINE('PRUEBA 8: Eliminación de un ejemplar');
    DELETE FROM ejemplar WHERE id_edicion = v_id_edicion AND numero = v_id_ejemplar;
    COMMIT;

    DECLARE
        v_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM ejemplar_historico WHERE id_edicion = v_id_edicion AND numero = v_id_ejemplar;
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('El ejemplar fue almacenado en el histórico correctamente.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error: El ejemplar no está en el histórico.');
        END IF;
    END;

END;
/

-- ---------------------
-- Fin
-- ---------------------