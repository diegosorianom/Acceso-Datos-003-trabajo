-- ----------------------------------
-- ESQUEMA PARTE 2 - SOCIO Y PRESTAMO
-- ----------------------------------

-- Crear tabla socio
CREATE TABLE socio (
    id CHAR(5),
    nombre VARCHAR(30),
    apellidos VARCHAR(60),
    fecha_nacimiento DATE,
    fecha_alta DATE DEFAULT SYSDATE,
    telefono VARCHAR(15),
    email VARCHAR(100),
    CONSTRAINT PK_socio PRIMARY KEY (id),
    CONSTRAINT NN_nombre_socio CHECK (nombre IS NOT NULL),
    CONSTRAINT NN_apellidos_socio CHECK (apellidos IS NOT NULL),
    CONSTRAINT UQ_email_socio UNIQUE (email)
);

-- Crear tabla histórico de socio
CREATE TABLE socio_historico (
    id CHAR(5),
    nombre VARCHAR(30),
    apellidos VARCHAR(60),
    fecha_nacimiento DATE,
    fecha_alta DATE,
    telefono VARCHAR(15),
    email VARCHAR(100),
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Crear tabla prestamos
CREATE TABLE prestamo_bibliotk (
    id CHAR(6),
    id_socio CHAR(5),
    id_edicion CHAR(6),
    numero INTEGER,
    fecha_prestamo DATE DEFAULT SYSDATE,
    fecha_devolucion DATE,
    CONSTRAINT PK_prestamo_bibliotk PRIMARY KEY (id),
    CONSTRAINT FK_prestamo_socio FOREIGN KEY (id_socio) REFERENCES socio(id),
    CONSTRAINT FK_prestamo_ejemplar FOREIGN KEY (id_edicion, numero) REFERENCES ejemplar (id_edicion, numero),
    CONSTRAINT CK_fecha_devolucion CHECK (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_prestamo)
);

-- Crear tabla historico de prestamos
CREATE TABLE prestamo_historico (
    id CHAR(6),
    id_socio CHAR(5),
    id_edicion CHAR(6),
    numero INTEGER,
    fecha_prestamo DATE,
    fecha_devolucion DATE, 
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- ----------------------------------------------------
-- ESQUEMA PARTE 2 - TRIGGERS PARA AUDITORÍA DE BORRADO
-- ----------------------------------------------------

-- Trigger para auditar el borrado de autores
CREATE OR REPLACE TRIGGER auditar_borrado_autor
BEFORE DELETE ON autor
FOR EACH ROW
BEGIN
    INSERT INTO autor_historico (id, nombre, apellidos, nacimiento, fecha_borrado)
    VALUES (:OLD.id, :OLD.nombre, :OLD.apellidos, :OLD.nacimiento, SYSTIMESTAMP);
END;
/

-- Trigger para auditar el borrado de la relacion
CREATE OR REPLACE TRIGGER auditar_borrado_autor_obra
BEFORE DELETE ON autor_obra
FOR EACH ROW
BEGIN
    INSERT INTO autor_obra_historico (id_autor, id_obra, fecha_borrado)
    VALUES (:OLD.id_autor, :OLD.id_obra, SYSTIMESTAMP);
END;
/

-- Trigger para auditar el borrado de ediciones
CREATE OR REPLACE TRIGGER auditar_borrado_edicion
BEFORE DELETE ON edicion
FOR EACH ROW
BEGIN
    INSERT INTO edicion_historico (id, id_obra, isbn, anyo, fecha_borrado)
    VALUES (:OLD.id, :OLD.id_obra, :OLD.isbn, :OLD.anyo, SYSTIMESTAMP);
END;
/

-- Trigger para auditar el borrado de ejemplares
CREATE OR REPLACE TRIGGER auditar_borrado_ejemplar
BEFORE DELETE ON ejemplar
FOR EACH ROW
BEGIN
    INSERT INTO ejemplar_historico (id_edicion, numero, alta, baja, fecha_borrado)
    VALUES (:OLD.id_edicion, :OLD.numero, :OLD.alta, :OLD.baja, SYSTIMESTAMP);
END;
/

-- Trigger para auditar el borrado de socios
CREATE OR REPLACE TRIGGER auditar_borrado_socio
BEFORE DELETE ON socio
FOR EACH ROW
BEGIN 
    INSERT INTO socio_historico (id, nombre, apellidos, fecha_nacimiento, fecha_alta, telefono, email, fecha_borrado)
    VALUES (:OLD.id, :OLD.nombre, :OLD.apellidos, :OLD.fecha_nacimiento, :OLD.fecha_alta, :OLD.telefono, :OLD.email, SYSTIMESTAMP);
END;
/

-- Trigger para auditar el borrado de préstamos
CREATE OR REPLACE TRIGGER auditar_borrado_prestamo
BEFORE DELETE ON prestamo_bibliotk
FOR EACH ROW
BEGIN
    INSERT INTO prestamo_historico (id, id_socio, id_edicion, numero, fecha_prestamo, fecha_devolucion, fecha_borrado)
    VALUES (:OLD.id, :OLD.id_socio, :OLD.id_edicion, :OLD.numero, :OLD.fecha_prestamo, :OLD.fecha_devolucion, SYSTIMESTAMP);
END;
/

-- -------------------------------------------------
-- ESQUEMA PARTE 2 - PRUEBAS PARA SOCIOS Y PRÉSTAMOS
-- -------------------------------------------------

SET SERVEROUTPUT ON;

-- Definir IDs estáticos para la prueba
DECLARE
    v_socio_id VARCHAR2(5) := 'TEST1';
    v_prestamo_id VARCHAR2(6) := 'PRES01';
    v_resultado INTEGER;

BEGIN
    -- 1. PRUEBA: Insertar un socio con ID estático
    DBMS_OUTPUT.PUT_LINE('PRUEBA 1: Creación de un nuevo socio con ID estático');
    INSERT INTO socio (id, nombre, apellidos, fecha_nacimiento, fecha_alta, telefono, email)
    VALUES (v_socio_id, 'Juan', 'Pérez Gómez', TO_DATE('1990-06-15', 'YYYY-MM-DD'), SYSDATE, '600111222', 'juan.perez@email.com');
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Socio creado con éxito, ID: ' || v_socio_id);

    -- 2. PRUEBA: Intentar registrar un socio con el mismo email
    DBMS_OUTPUT.PUT_LINE('PRUEBA 2: Intentar registrar un socio con el mismo email');
    v_resultado := alta_socio('Carlos', 'Martínez López', TO_DATE('1987-04-10', 'YYYY-MM-DD'), '600333444', 'juan.perez@email.com');
    IF v_resultado = '-2' THEN
        DBMS_OUTPUT.PUT_LINE('Correcto: No se puede registrar el socio con email duplicado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: Se permitió registrar un socio con email duplicado.');
    END IF;

    -- 3. PRUEBA: Creación de un préstamo con ID estático
    DBMS_OUTPUT.PUT_LINE('PRUEBA 3: Creación de un préstamo con ID estático');
    INSERT INTO prestamo_bibliotk (id, id_socio, id_edicion, numero, fecha_prestamo, fecha_devolucion)
    VALUES (v_prestamo_id, v_socio_id, 'ZHEKI4', 1, SYSDATE, NULL);
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Préstamo realizado con éxito, ID: ' || v_prestamo_id);

    -- 4. PRUEBA: Intentar prestar el mismo ejemplar dos veces
    DBMS_OUTPUT.PUT_LINE('PRUEBA 4: Intentar prestar un ejemplar ya prestado');
    v_resultado := apertura_prestamo(v_socio_id, 'ZHEKI4', 1);
    IF v_resultado = -3 THEN
        DBMS_OUTPUT.PUT_LINE('Correcto: No se puede prestar un ejemplar ya prestado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: Se permitió prestar un ejemplar ya prestado.');
    END IF;

    -- 5. PRUEBA: Cerrar el préstamo
    DBMS_OUTPUT.PUT_LINE('PRUEBA 5: Cerrar un préstamo');
    v_resultado := cierre_prestamo(v_prestamo_id);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Préstamo cerrado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al cerrar el préstamo.');
    END IF;

    -- 6. PRUEBA: Eliminación del socio y verificación en el histórico
    DBMS_OUTPUT.PUT_LINE('PRUEBA 6: Eliminación del socio');
    DELETE FROM socio WHERE id = v_socio_id;
    COMMIT;

    DECLARE
        v_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM socio_historico WHERE id = v_socio_id;
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('El socio fue almacenado en el histórico correctamente.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error: El socio no está en el histórico.');
        END IF;
    END;

    -- 7. PRUEBA: Eliminación del préstamo y verificación en el histórico
    DBMS_OUTPUT.PUT_LINE('PRUEBA 7: Eliminación del préstamo');
    DELETE FROM prestamo_bibliotk WHERE id = v_prestamo_id;
    COMMIT;

    DECLARE
        v_count_prestamo INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_count_prestamo FROM prestamo_historico WHERE id = v_prestamo_id;
        IF v_count_prestamo > 0 THEN
            DBMS_OUTPUT.PUT_LINE('El préstamo fue almacenado en el histórico correctamente.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error: El préstamo no está en el histórico.');
        END IF;
    END;
END;
/

-- ---------------------
-- ESQUEMA PARTE 2 - Fin
-- ---------------------