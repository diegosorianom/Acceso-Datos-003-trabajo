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

-- Tablas historicos
CREATE SEQUENCE autor_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE autor_historico (
    id_historico NUMBER PRIMARY KEY,
    id CHAR(4),
    nombre VARCHAR(30),
    apellidos VARCHAR(60),
    nacimiento DATE,
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER auditar_borrado_autor
BEFORE DELETE ON autor
FOR EACH ROW
BEGIN
    INSERT INTO autor_historico (id_historico, id, nombre, apellidos, nacimiento, fecha_borrado)
    VALUES (autor_historico_seq.NEXTVAL, :OLD.id, :OLD.nombre, :OLD.apellidos, :OLD.nacimiento, SYSTIMESTAMP);
END;
/

CREATE SEQUENCE autor_obra_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE autor_obra_historico (
    id_historico NUMBER PRIMARY KEY,
    id_autor CHAR(4),
    id_obra CHAR(5),
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER auditar_borrado_autor_obra
BEFORE DELETE ON autor_obra
FOR EACH ROW
BEGIN
    INSERT INTO autor_obra_historico (id_historico, id_autor, id_obra, fecha_borrado)
    VALUES (autor_obra_historico_seq.NEXTVAL, :OLD.id_autor, :OLD.id_obra, SYSTIMESTAMP);
END;
/

CREATE SEQUENCE edicion_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE edicion_historico (
    id_historico NUMBER PRIMARY KEY,
    id CHAR(6),
    id_obra CHAR(5),
    isbn VARCHAR(20),
    anyo INTEGER,
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER auditar_borrado_edicion
BEFORE DELETE ON edicion
FOR EACH ROW
BEGIN
    INSERT INTO edicion_historico (id_historico, id, id_obra, isbn, anyo, fecha_borrado)
    VALUES (edicion_historico_seq.NEXTVAL, :OLD.id, :OLD.id_obra, :OLD.isbn, :OLD.anyo, SYSTIMESTAMP);
END;
/

CREATE SEQUENCE ejemplar_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ejemplar_historico (
    id_historico NUMBER PRIMARY KEY,
    id_edicion CHAR(6),
    numero INTEGER,
    alta DATE NOT NULL,
    baja DATE,
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER auditar_borrado_ejemplar
BEFORE DELETE ON ejemplar
FOR EACH ROW
BEGIN
    INSERT INTO ejemplar_historico (id_historico, id_edicion, numero, alta, baja, fecha_borrado)
    VALUES (ejemplar_historico_seq.NEXTVAL, :OLD.id_edicion, :OLD.numero, :OLD.alta, :OLD.baja, SYSTIMESTAMP);
END;
/

CREATE SEQUENCE socio_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE socio_historico (
    id_historico NUMBER PRIMARY KEY,
    id CHAR(5),
    nombre VARCHAR(30) NOT NULL,
    apellidos VARCHAR(60) NOT NULL,
    fecha_nacimiento DATE,
    fecha_alta DATE DEFAULT SYSDATE,
    telefono VARCHAR(15),
    email VARCHAR(100),
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER auditar_borrado_socio
BEFORE DELETE ON socio
FOR EACH ROW
BEGIN 
    INSERT INTO socio_historico (id_historico, id, nombre, apellidos, fecha_nacimiento, fecha_alta, telefono, email, fecha_borrado)
    VALUES (socio_historico_seq.NEXTVAL, :OLD.id, :OLD.nombre, :OLD.apellidos, :OLD.fecha_nacimiento, :OLD.fecha_alta, :OLD.telefono, :OLD.email, SYSTIMESTAMP);
END;
/

CREATE SEQUENCE prestamo_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE prestamo_historico (
    id_historico NUMBER PRIMARY KEY,
    id CHAR(6),
    id_socio CHAR(5),
    id_edicion CHAR(6),
    numero INTEGER,
    fecha_prestamo DATE DEFAULT SYSDATE,
    fecha_devolucion DATE,
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER auditar_borrado_prestamo
BEFORE DELETE ON prestamo_bibliotk
FOR EACH ROW
BEGIN
    INSERT INTO prestamo_historico (id_historico, id, id_socio, id_edicion, numero, fecha_prestamo, fecha_devolucion, fecha_borrado)
    VALUES (prestamo_historico_seq.NEXTVAL, :OLD.id, :OLD.id_socio, :OLD.id_edicion, :OLD.numero, :OLD.fecha_prestamo, :OLD.fecha_devolucion, SYSTIMESTAMP);
END;
/

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

-- -------------------------
-- ESQUEMA PARTE 2 - Package
-- -------------------------

CREATE OR REPLACE PACKAGE BiblioTK_Opcional AS
    -- Función para registrar un nuevo socio
    FUNCTION alta_socio (
        p_nombre VARCHAR2,
        p_apellidos VARCHAR2,
        p_fecha_nacimiento DATE DEFAULT NULL,
        p_telefono VARCHAR2 DEFAULT NULL,
        p_email VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2;

    -- Función para registrar un préstamo
    FUNCTION apertura_prestamo (
        p_id_socio VARCHAR2,
        p_id_edicion VARCHAR2,
        p_numero INTEGER
    ) RETURN INTEGER;

    -- Función para cerrar un préstamo
    FUNCTION cierre_prestamo (
        p_id_prestamo VARCHAR2
    ) RETURN INTEGER;
END biblioteca_pkg;
/

-- ------------------------------
-- ESQUEMA PARTE 2 - Package Body
-- ------------------------------

CREATE OR REPLACE PACKAGE BODY BiblioTK_Opcional AS

    -- Función para registrar un nuevo socio
    FUNCTION alta_socio (
        p_nombre VARCHAR2,
        p_apellidos VARCHAR2,
        p_fecha_nacimiento DATE DEFAULT NULL,
        p_telefono VARCHAR2 DEFAULT NULL,
        p_email VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS
        v_id CHAR(5);
        v_count_email INTEGER;
    BEGIN
        -- Verificar si el email ya existe en la base de datos
        IF p_email IS NOT NULL THEN
            SELECT COUNT(*) INTO v_count_email FROM socio WHERE email = p_email;
            IF v_count_email > 0 THEN
                RETURN '-2'; -- Error: Email ya existe
            END IF;
        END IF;

        -- Generar un ID aleatorio de 5 caracteres en mayúsculas
        v_id := dbms_random.string('X', 5);

        -- Insertar el nuevo socio en la base de datos
        INSERT INTO socio (id, nombre, apellidos, fecha_nacimiento, fecha_alta, telefono, email)
        VALUES (v_id, p_nombre, p_apellidos, p_fecha_nacimiento, SYSDATE, p_telefono, p_email);

        -- Confirmar la transacción
        COMMIT;

        -- Devolver el ID generado
        RETURN v_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN '-1'; -- Error inesperado
    END alta_socio;


    -- Función para registrar un préstamo
    FUNCTION apertura_prestamo (
        p_id_socio VARCHAR2,
        p_id_edicion VARCHAR2,
        p_numero INTEGER
    ) RETURN INTEGER IS
        v_count_socio INTEGER;
        v_count_ejemplar INTEGER;
        v_count_prestamo INTEGER;
        v_id_prestamo VARCHAR2(6);
    BEGIN
        -- Verificar si el socio existe
        SELECT COUNT(*) INTO v_count_socio FROM socio WHERE id = p_id_socio;
        IF v_count_socio = 0 THEN
            RETURN -1; -- Error: Socio no encontrado
        END IF;

        -- Verificar si el ejemplar existe
        SELECT COUNT(*) INTO v_count_ejemplar
        FROM ejemplar
        WHERE id_edicion = p_id_edicion AND numero = p_numero;

        IF v_count_ejemplar = 0 THEN
            RETURN -2; -- Error: Ejemplar no encontrado
        END IF;

        -- Verificar si el ejemplar ya está prestado
        SELECT COUNT(*) INTO v_count_prestamo
        FROM prestamo_bibliotk
        WHERE id_edicion = p_id_edicion
        AND numero = p_numero
        AND fecha_devolucion IS NULL;

        IF v_count_prestamo > 0 THEN
            RETURN -3; -- Error: Ejemplar ya prestado
        END IF;

        -- Generar un nuevo ID de préstamo
        v_id_prestamo := dbms_random.string('X', 6);

        -- Insertar el nuevo préstamo
        INSERT INTO prestamo_bibliotk (id, id_socio, id_edicion, numero, fecha_prestamo, fecha_devolucion)
        VALUES (v_id_prestamo, p_id_socio, p_id_edicion, p_numero, SYSDATE, NULL);

        -- Confirmar la transacción
        COMMIT;

        RETURN 1; -- Éxito

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN -4; -- Error inesperado
    END apertura_prestamo;


    -- Función para cerrar un préstamo
    FUNCTION cierre_prestamo (
        p_id_prestamo VARCHAR2
    ) RETURN INTEGER IS
        v_count INTEGER;
        v_fecha_devolucion DATE;
    BEGIN   
        -- Verificar si el prestamo existe
        SELECT COUNT(*) INTO v_count
        FROM prestamo_bibliotk
        WHERE id = p_id_prestamo;

        IF v_count = 0 THEN
            RETURN -1; -- Error: Préstamo no encontrado
        END IF;

        -- Verificar si el préstamo ya fue devuelto
        SELECT fecha_devolucion INTO v_fecha_devolucion
        FROM prestamo_bibliotk
        WHERE id = p_id_prestamo;

        IF v_fecha_devolucion IS NOT NULL THEN
            RETURN -2; -- Error: El préstamo ya ha sido devuelto
        END IF;

        -- Registrar la fecha de devolución como la fecha actual
        UPDATE prestamo_bibliotk
        SET fecha_devolucion = SYSDATE
        WHERE id = p_id_prestamo;

        -- Confirmar la transacción
        COMMIT;
        RETURN 1; -- Éxito: Préstamo cerrado correctamente

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN -3; -- Error inesperado
    END cierre_prestamo;

END biblioteca_pkg;
/

-- -------------------------
-- ESQUEMA PARTE 2 - Declare
-- -------------------------

DECLARE
    -- Variables para alta de socio
    v_socio1_id VARCHAR2(5);
    v_socio2_id VARCHAR2(5);
    v_socio3_id VARCHAR2(5);
    v_socio4_id VARCHAR2(5); -- Con email repetido

    -- Variables para apertura de préstamo
    v_prestamo1_result INTEGER;
    v_prestamo2_result INTEGER;
    v_prestamo3_result INTEGER;
    v_prestamo4_result INTEGER; -- Prestamo con ejemplar ya prestado
    v_prestamo5_result INTEGER; -- Prestamo con socio inexistente
    v_prestamo6_result INTEGER; -- Prestamo con ejemplar inexistente

    -- Variables para cierre de préstamo
    v_cierre1_result INTEGER;
    v_cierre2_result INTEGER; -- Prestamo ya cerrado
    v_cierre3_result INTEGER; -- Prestamo inexistente

BEGIN
    -- **PRUEBAS DE CREACIÓN DE SOCIO**
    -- Caso exitoso
    v_socio1_id := biblioteca_pkg.alta_socio('Carlos', 'López Fernández', TO_DATE('1985-07-21', 'YYYY-MM-DD'), '699123456', 'carlos@email.com');
    v_socio2_id := biblioteca_pkg.alta_socio('María', 'González Pérez', TO_DATE('1990-03-15', 'YYYY-MM-DD'), '622456789', 'maria@email.com');
    v_socio3_id := biblioteca_pkg.alta_socio('Luis', 'Martínez Díaz', TO_DATE('1982-09-08', 'YYYY-MM-DD'), '655987654', 'luis@email.com');

    -- Error: Email repetido
    v_socio4_id := biblioteca_pkg.alta_socio('Ana', 'Fernández López', TO_DATE('1995-05-22', 'YYYY-MM-DD'), '677654321', 'carlos@email.com');

    -- Mensajes de prueba
    DBMS_OUTPUT.PUT_LINE('Alta de socio 1: ' || v_socio1_id);
    DBMS_OUTPUT.PUT_LINE('Alta de socio 2: ' || v_socio2_id);
    DBMS_OUTPUT.PUT_LINE('Alta de socio 3: ' || v_socio3_id);
    IF v_socio4_id = '-2' THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Email ya registrado.');
    END IF;

    -- **PRUEBAS DE APERTURA DE PRÉSTAMO**
    -- Creación de datos adicionales
    INSERT INTO edicion (id, id_obra, isbn, anyo) VALUES ('ED001', 'OB001', '978-1234567890', 2022);
    INSERT INTO ejemplar (id_edicion, numero, alta) VALUES ('ED001', 1, SYSDATE);

    -- Caso exitoso
    v_prestamo1_result := biblioteca_pkg.apertura_prestamo(v_socio1_id, 'ED001', 1);
    v_prestamo2_result := biblioteca_pkg.apertura_prestamo(v_socio2_id, 'ED001', 1); -- Prestamo con mismo ejemplar (debe fallar)

    -- Error: Socio no existe
    v_prestamo5_result := biblioteca_pkg.apertura_prestamo('XXXXX', 'ED001', 1);

    -- Error: Ejemplar no existe
    v_prestamo6_result := biblioteca_pkg.apertura_prestamo(v_socio1_id, 'ED001', 99);

    -- Mensajes de prueba
    IF v_prestamo1_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Préstamo 1 registrado correctamente.');
    END IF;

    IF v_prestamo2_result = -3 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Ejemplar ya prestado.');
    END IF;

    IF v_prestamo5_result = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Socio no encontrado.');
    END IF;

    IF v_prestamo6_result = -2 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Ejemplar no encontrado.');
    END IF;

    -- **PRUEBAS DE CIERRE DE PRÉSTAMO**
    -- Caso exitoso
    v_cierre1_result := biblioteca_pkg.cierre_prestamo('DHT13S'); -- ID debe existir en pruebas

    -- Intentar cerrar préstamo ya cerrado
    v_cierre2_result := biblioteca_pkg.cierre_prestamo('DHT13S');

    -- Intentar cerrar préstamo inexistente
    v_cierre3_result := biblioteca_pkg.cierre_prestamo('ZZZZZZ');

    -- Mensajes de prueba
    IF v_cierre1_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Cierre de préstamo exitoso.');
    END IF;

    IF v_cierre2_result = -2 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Préstamo ya cerrado.');
    END IF;

    IF v_cierre3_result = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado: Préstamo no encontrado.');
    END IF;

    COMMIT;
END;
/


-- ---------------------
-- ESQUEMA PARTE 2 - Fin
-- ---------------------