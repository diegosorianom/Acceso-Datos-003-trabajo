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

-- --------------------------
-- INSERTS DE DATOS DE PRUEBA
-- --------------------------

-- INSERTAR OBRAS
INSERT INTO obra (id, titulo, anyo) VALUES ('TEST1', 'El Camino de los Reyes', 2010);
INSERT INTO obra (id, titulo, anyo) VALUES ('TEST2', 'Palabras Radiantes', 2014);
INSERT INTO obra (id, titulo, anyo) VALUES ('TEST3', 'Juramentada', 2017);
INSERT INTO obra (id, titulo, anyo) VALUES ('TEST4', 'El Ritmo de la Guerra', 2020);

-- INSERTAR AUTORES
INSERT INTO autor (id, nombre, apellidos, nacimiento) 
VALUES ('AUT1', 'Brandon', 'Sanderson', TO_DATE('1975-12-19', 'YYYY-MM-DD'));
INSERT INTO autor (id, nombre, apellidos, nacimiento) 
VALUES ('AUT2', 'Patrick', 'Rothfuss', TO_DATE('1973-06-06', 'YYYY-MM-DD'));
INSERT INTO autor (id, nombre, apellidos, nacimiento) 
VALUES ('AUT3', 'J.R.R.', 'Tolkien', TO_DATE('1892-01-03', 'YYYY-MM-DD'));
INSERT INTO autor (id, nombre, apellidos, nacimiento) 
VALUES ('AUT4', 'George R.R.', 'Martin', TO_DATE('1948-09-20', 'YYYY-MM-DD'));

-- INSERTAR RELACIÓN AUTOR-OBRA
INSERT INTO autor_obra (id_autor, id_obra) VALUES ('AUT1', 'TEST1');
INSERT INTO autor_obra (id_autor, id_obra) VALUES ('AUT1', 'TEST2');
INSERT INTO autor_obra (id_autor, id_obra) VALUES ('AUT1', 'TEST3');
INSERT INTO autor_obra (id_autor, id_obra) VALUES ('AUT1', 'TEST4');
INSERT INTO autor_obra (id_autor, id_obra) VALUES ('AUT2', 'TEST2');

-- INSERTAR EDICIONES
INSERT INTO edicion (id, id_obra, isbn, anyo) VALUES ('EDIT01', 'TEST1', '978-1234567890', 2015);
INSERT INTO edicion (id, id_obra, isbn, anyo) VALUES ('EDIT02', 'TEST2', '978-9876543210', 2016);
INSERT INTO edicion (id, id_obra, isbn, anyo) VALUES ('EDIT03', 'TEST3', '978-1111111111', 2018);
INSERT INTO edicion (id, id_obra, isbn, anyo) VALUES ('EDIT04', 'TEST4', '978-2222222222', 2021);

-- INSERTAR EJEMPLARES
INSERT INTO ejemplar (id_edicion, numero, alta, baja) VALUES ('EDIT01', 1, SYSDATE, NULL);
INSERT INTO ejemplar (id_edicion, numero, alta, baja) VALUES ('EDIT01', 2, SYSDATE, NULL);
INSERT INTO ejemplar (id_edicion, numero, alta, baja) VALUES ('EDIT02', 1, SYSDATE, NULL);
INSERT INTO ejemplar (id_edicion, numero, alta, baja) VALUES ('EDIT02', 2, SYSDATE, NULL);
INSERT INTO ejemplar (id_edicion, numero, alta, baja) VALUES ('EDIT03', 1, SYSDATE, NULL);

-- INSERTAR SOCIOS
INSERT INTO socio (id, nombre, apellidos, fecha_nacimiento, fecha_alta, telefono, email) 
VALUES ('SOC01', 'Carlos', 'López Fernández', TO_DATE('1985-07-21', 'YYYY-MM-DD'), SYSDATE, '699123456', 'carlos@email.com');
INSERT INTO socio (id, nombre, apellidos, fecha_nacimiento, fecha_alta, telefono, email) 
VALUES ('SOC02', 'Laura', 'Martínez Rodríguez', TO_DATE('1992-03-15', 'YYYY-MM-DD'), SYSDATE, '600222333', 'laura@email.com');
INSERT INTO socio (id, nombre, apellidos, fecha_nacimiento, fecha_alta, telefono, email) 
VALUES ('SOC03', 'Pablo', 'Gómez Sánchez', TO_DATE('2000-08-05', 'YYYY-MM-DD'), SYSDATE, '612345678', 'pablo@email.com');

-- INSERTAR PRÉSTAMOS
INSERT INTO prestamo_bibliotk (id, id_socio, id_edicion, numero, fecha_prestamo, fecha_devolucion) 
VALUES ('PRES01', 'SOC01', 'EDIT01', 1, SYSDATE, NULL);
INSERT INTO prestamo_bibliotk (id, id_socio, id_edicion, numero, fecha_prestamo, fecha_devolucion) 
VALUES ('PRES02', 'SOC02', 'EDIT02', 1, SYSDATE, NULL);
INSERT INTO prestamo_bibliotk (id, id_socio, id_edicion, numero, fecha_prestamo, fecha_devolucion) 
VALUES ('PRES03', 'SOC03', 'EDIT03', 1, SYSDATE, NULL);

COMMIT;

-- --------------
-- FIN DE INSERTS
-- --------------

-- -------------------------------------------
-- PRUEBAS PARA FUNCIONES DEL PAQUETE BiblioTK
-- -------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
    v_id_obra VARCHAR2(5);
    v_id_autor VARCHAR2(4);
    v_id_edicion VARCHAR2(6);
    v_id_ejemplar INTEGER;
    v_resultado INTEGER;
    v_id_generado VARCHAR2(6);
BEGIN
    -- 1. PRUEBA: Alta de una obra
    DBMS_OUTPUT.PUT_LINE('PRUEBA 1: Creación de una nueva obra');
    v_id_obra := BiblioTK.alta_obra('El Archivo de las Tormentas', 2025);
    IF v_id_obra = '-1' THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado al crear la obra.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Obra creada con ID: ' || v_id_obra);
    END IF;

    -- 2. PRUEBA: Eliminación de la obra
    DBMS_OUTPUT.PUT_LINE('PRUEBA 2: Eliminación de una obra');
    v_resultado := BiblioTK.borrado_obra(v_id_obra);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Obra eliminada correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al eliminar la obra.');
    END IF;

    -- 3. PRUEBA: Alta de un autor
    DBMS_OUTPUT.PUT_LINE('PRUEBA 3: Creación de un nuevo autor');
    v_id_autor := BiblioTK.alta_autor('Patrick', 'Rothfuss', TO_DATE('1973-06-06', 'YYYY-MM-DD'));
    IF v_id_autor = '-1' THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado al crear el autor.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Autor creado con ID: ' || v_id_autor);
    END IF;

    -- 4. PRUEBA: Eliminación de un autor
    DBMS_OUTPUT.PUT_LINE('PRUEBA 4: Eliminación de un autor');
    v_resultado := BiblioTK.borrado_autor(v_id_autor);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor eliminado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al eliminar el autor.');
    END IF;

    -- 5. PRUEBA: Vincular un autor con una obra
    DBMS_OUTPUT.PUT_LINE('PRUEBA 5: Vinculación de un autor con una obra');
    v_resultado := BiblioTK.vincular('AUT1', 'TEST1');
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor vinculado correctamente con la obra.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al vincular el autor con la obra.');
    END IF;

    -- 6. PRUEBA: Desvincular un autor de una obra
    DBMS_OUTPUT.PUT_LINE('PRUEBA 6: Desvinculación de un autor de una obra');
    v_resultado := BiblioTK.desvincular('AUT1', 'TEST1');
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor desvinculado correctamente de la obra.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al desvincular el autor de la obra.');
    END IF;

    -- 7. PRUEBA: Alta de una edición
    DBMS_OUTPUT.PUT_LINE('PRUEBA 7: Creación de una nueva edición');
    v_id_edicion := BiblioTK.alta_edicion('TEST1', '978-1234567890', 2025);
    IF v_id_edicion = '-1' THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado al crear la edición.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Edición creada con ID: ' || v_id_edicion);
    END IF;

    -- 8. PRUEBA: Eliminación de una edición
    DBMS_OUTPUT.PUT_LINE('PRUEBA 8: Eliminación de una edición');
    v_resultado := BiblioTK.borrado_edicion(v_id_edicion);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Edición eliminada correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al eliminar la edición.');
    END IF;

    -- 9. PRUEBA: Alta de un ejemplar
    DBMS_OUTPUT.PUT_LINE('PRUEBA 9: Creación de un nuevo ejemplar');
    v_resultado := BiblioTK.alta_ejemplar('EDIT01');
    IF v_resultado = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error: La edición no existe.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ejemplar creado con número: ' || v_resultado);
    END IF;

    -- 10. PRUEBA: Eliminación de un ejemplar
    DBMS_OUTPUT.PUT_LINE('PRUEBA 10: Eliminación de un ejemplar');
    v_resultado := BiblioTK.borrado_ejemplar('EDIT01', v_resultado);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Ejemplar eliminado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al eliminar el ejemplar.');
    END IF;

    -- 11. PRUEBA: Baja de un ejemplar
    DBMS_OUTPUT.PUT_LINE('PRUEBA 11: Baja de un ejemplar');
    v_resultado := BiblioTK.baja_ejemplar('EDIT01', 1);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Baja del ejemplar registrada correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al dar de baja el ejemplar.');
    END IF;

END;
/

-- -----------
-- Fin Pruebas
-- -----------