CREATE TABLE obra (
    id CHAR (5),
    titulo VARCHAR(100),
    anyo INTEGER,
    CONSTRAINT PK_obra PRIMARY KEY (id),
    CONSTRAINT NN_titulo CHECK (titulo IS NOT NULL)
);

CREATE TABLE autor (
    id CHAR(4),
    nombre VARCHAR(30),
    apellidos VARCHAR(60),
    nacimiento DATE,
    CONSTRAINT PK_autor PRIMARY KEY (id),
    CONSTRAINT NN_nombre CHECK (nombre IS NOT NULL),
    CONSTRAINT NN_apellidos CHECK (apellidos IS NOT NULL)
);

CREATE TABLE autor_obra (
    id_autor CHAR(4),
    id_obra CHAR(5),
    CONSTRAINT PK_autor_obra PRIMARY KEY (id_autor, id_obra),
    CONSTRAINT FK_autor_obra_id_autor FOREIGN KEY (id_autor) REFERENCES autor (id),
    CONSTRAINT FK_autor_obra_id_obra FOREIGN KEY (id_obra) REFERENCES obra (id)
);

CREATE TABLE edicion (
    id CHAR(6),
    id_obra CHAR(5),
    isbn VARCHAR(20),
    anyo INTEGER,
    CONSTRAINT PK_edicion PRIMARY KEY (id),
    CONSTRAINT NN_id_obra CHECK (id_obra IS NOT NULL),
    CONSTRAINT NN_isbn CHECK (isbn IS NOT NULL),
    CONSTRAINT FK_edicion FOREIGN KEY (id_obra) REFERENCES obra (id)
);

CREATE TABLE ejemplar (
    id_edicion CHAR(6),
    numero INTEGER,
    alta DATE,
    baja DATE,
    CONSTRAINT PK_ejemplar PRIMARY KEY (id_edicion, numero),
    CONSTRAINT FK_ejemplar FOREIGN KEY (id_edicion) REFERENCES edicion(id),
    CONSTRAINT NN_alta CHECK (alta IS NOT NULL)
);

DECLARE
    -- Se declara una variable id5 de tipo CHAR(5). Almacenará una cadena de 5 carácteres.
    id5 CHAR(5);
    -- Parte ejecutable del código
    BEGIN
    -- Genera una cadena aleatoria de 5 carácteres alfabéticos en mayúsculas y se asigna a id5
    id5 := dbms_random.string('X', 5);
    -- Inserta un nuevo registro en la tabla OBRA con el id5 y el titulo 'El Imperio Final'
    INSERT INTO obra (id, titulo) VALUES (id5, 'El Imperio Final');
END;
/

INSERT INTO edicion (id, id_obra, isbn, anyo)
VALUES ('8OOKY1', '8OOKY', '978-1234567890', 2015);

INSERT INTO ejemplar (id_edicion, numero, alta, baja)
VALUES ('8OOKY1', 1, TO_DATE('2009/07/02', 'YYYY/MM/DD'), TO_DATE('2013/08/05', 'YYYY/MM/DD'));

INSERT INTO ejemplar (id_edicion, numero, alta, baja)
VALUES ('8OOKY1', 2, TO_DATE('2009/07/02', 'YYYY/MM/DD'), NULL);

INSERT INTO ejemplar (id_edicion, numero, alta, baja)
VALUES ('8OOKY1', 3, TO_DATE('2013/08/02', 'YYYY/MM/DD'), NULL);


-- EJERCICIOS
-- 1
CREATE OR REPLACE FUNCTION alta_obra (p_titulo VARCHAR, p_anyo INTEGER DEFAULT NULL)
RETURN VARCHAR IS
    v_id CHAR(5); -- variable para almacenar el ID generado;
BEGIN
    -- Generar un ID aleatorio de 5 carácteres en mayúsculas
    v_id := dbms_random.string('X', 5);

    -- Insertar la nueva obra
    INSERT INTO obra (id, titulo)
    VALUES (v_id, p_titulo);

    -- Devolver el ID generado
    RETURN v_id;

EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, devolver '-1'
        RETURN '-1';
END alta_obra;
/

DECLARE
    -- Declaramos una variable para alamcenar el ID generado por la función alta_obra
    v_nueva_obra_id VARCHAR(5); 
BEGIN  
    -- Llamamos a la función y almacenamos el ID generado. La función inserta la nueva obra
    v_nueva_obra_id := alta_obra('El Imperio Final');
    -- Mostramos el ID asignado en la salida estándar (Visible al activar el buffer)
    DBMS_OUTPUT.PUT_LINE('ID Asignado: ' || v_nueva_obra_id);
END;
/


-- 2
CREATE OR REPLACE FUNCTION borrado_obra (p_id VARCHAR)
RETURN INTEGER IS
    v_count INTEGER; -- Variable para verificar si la obra existe antes de borrar
BEGIN
    -- Verificar si la obra con el ID proporcionado existe
    SELECT COUNT(*) INTO v_count FROM obra WHERE id = p_id;

    -- Si no existe, devolver 0
    IF v_count = 0 THEN
        RETURN 0;
    END IF;

    -- Si existe, eliminar la obra
    DELETE FROM obra WHERE id = p_id;

    -- Devolver 1 indicando que la obra fue eliminada correctamente y guardar cambios
    COMMIT;
    RETURN 1;

EXCEPTION
    WHEN OTHERS THEN
        -- Si ocurre un error devolver -1
        ROLLBACK;
        RETURN -1;
END borrado_obra;
/

DECLARE
    v_result INTEGER; -- Variable para almacenar el resultado de la función borrado_obra
BEGIN
    -- Intentar borrar una obra con ID '8OOKY'
    v_result := borrado_obra('1KH0O');

    -- Mostrar el resultado en la salida estándar
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_result);
END;
/


-- 3
CREATE SEQUENCE obra_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Crear tabla historico obra
CREATE TABLE obra_historico (
    id_historico NUMBER,
    id CHAR(5),
    titulo VARCHAR(100),
    anyo INTEGER,
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT PK_id_historico PRIMARY KEY (id_historico),
);

CREATE OR REPLACE TRIGGER auditar_borrado_obra
BEFORE DELETE ON obra
FOR EACH ROW
BEGIN
    INSERT INTO obra_historico (id_historico, id, titulo, anyo, fecha_borrado)
    VALUES (obra_historico_seq.NEXTVAL, :OLD.id, :OLD.titulo, :OLD.anyo, SYSTIMESTAMP);
END;
/


-- 4 
CREATE OR REPLACE FUNCTION alta_autor (p_nombre VARCHAR, p_apellidos VARCHAR, p_nacimiento DATE DEFAULT NULL)
RETURN VARCHAR IS 
    v_id CHAR(4); -- variable para almacenar el ID generado;
BEGIN
    -- Generar un ID aleatorio de 5 carácteres en mayúsculas
    v_id := dbms_random.string('X', 4);

    -- Insertar el nuevo autor
    INSERT INTO autor(id, nombre, apellidos, nacimiento)
    VALUES (v_id, p_nombre, p_apellidos, p_nacimiento);

    -- Devolver el ID generado
    return v_id;

EXCEPTION 
    WHEN OTHERS THEN 
    -- En caso de error, devolver '-1'
    RETURN '-1';
END alta_autor;
/

DECLARE 
    -- Declaramos una variable para alamcenar el ID
    v_nuevo_autor_id VARCHAR(4);
BEGIN
    -- Llamamos a la funcion y creamos el nuevo autor
    v_nuevo_autor_id := alta_autor('Brandon', 'Sanderson', TO_DATE('1975-12-19', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('ID Asignado: ' || v_nuevo_autor_id);
END;
/


-- 5
CREATE OR REPLACE FUNCTION borrado_autor (p_id VARCHAR) 
RETURN INTEGER IS
    v_count INTEGER; -- Variable para verificar si el autor existe
BEGIN
    -- Verificar si el autor con el ID proporcionado existe
    SELECT COUNT(*) INTO v_count FROM autor WHERE id = p_id;

    -- Si no existe, devolver 0
    IF v_count = 0 THEN
        RETURN 0;
    END IF;

    -- Si existe, eliminar el autor
    DELETE FROM autor WHERE id = p_id;

    -- Devolver 1 indicando que el autor fue elimnado 
    COMMIT;
    RETURN 1;

EXCEPTION
    WHEN OTHERS THEN
        -- Si ocurre un error devolver -1
        ROLLBACK;
        RETURN -1;
END borrado_autor;
/

DECLARE 
    v_result INTEGER; -- Variable para almacenar el resultado 
BEGIN 
    -- Intentar borrar un autor 
    v_result := borrado_autor('S0ZC');

    -- Mostrar el resultado en la sálida estandar
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_result);
END;
/


-- 6
CREATE OR REPLACE FUNCTION vincular (p_id_autor VARCHAR, p_id_obra VARCHAR)
RETURN INTEGER IS
    v_count_autor INTEGER;
    v_count_obra INTEGER;
    v_count_vinculo INTEGER;
BEGIN
    -- Verificar si el autor existe en la tabla autor
    SELECT COUNT(*) INTO v_count_autor FROM autor WHERE id = p_id_autor;
    IF v_count_autor = 0 THEN
        RETURN -2; -- Autor no encontado
    END IF;

    -- Verificar si la obra existe en la tabla obra
    SELECT COUNT(*) INTO v_count_obra FROM obra WHERE id = p_id_obra;
    IF v_count_obra = 0 THEN
        RETURN -3; -- Obra no encontrada
    END IF;

    -- Verificar si la relación ya existe en 'autor_obra'
    SELECT COUNT(*) INTO v_count_vinculo FROM autor_obra
    WHERE id_autor = p_id_autor AND id_obra = p_id_obra;

    IF v_count_vinculo > 0 THEN
        RETURN 0; -- La relaciön ya existe
    END IF;

    -- Insertamos la vinculación en 'autor_obra'
    INSERT INTO autor_obra (id_autor, id_obra)
    VALUES (p_id_autor, p_id_obra);

    RETURN 1; -- Vinculación existosa

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1; -- Error
END vincular    ;
/

DECLARE 
    v_result INTEGER; 
BEGIN
    -- autor / obra
    v_result := vincular('SOZC', 'O2KYG');
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_result);
END;
/


-- 7
CREATE OR REPLACE FUNCTION desvincular(
    p_id_autor VARCHAR,
    p_id_obra VARCHAR
) RETURN INTEGER IS
    v_count_vinculo INTEGER;
BEGIN
    -- Verificar si la relación existe en `autor_obra`
    SELECT COUNT(*) INTO v_count_vinculo FROM autor_obra 
    WHERE id_autor = p_id_autor AND id_obra = p_id_obra;

    -- Si no hay vínculo, devolver 0
    IF v_count_vinculo = 0 THEN
        RETURN 0; -- No existe vínculo
    END IF;

    -- Eliminar la vinculación en `autor_obra`
    DELETE FROM autor_obra 
    WHERE id_autor = p_id_autor AND id_obra = p_id_obra;

    -- Verificar si se realizó la eliminación
    IF SQL%ROWCOUNT > 0 THEN
        COMMIT;
        RETURN 1; -- Desvinculación exitosa
    ELSE
        RETURN 0; -- No se eliminó nada (caso raro)
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN -1; -- Error inesperado
END desvincular;
/

DECLARE
    v_result INTEGER;
BEGIN
    v_result := desvincular('SOZC', 'O2KYG'); -- ID de un autor y una obra ya vinculados
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_result);
END;
/


-- 8
CREATE OR REPLACE FUNCTION alta_edicion(p_id_obra VARCHAR, p_isbn VARCHAR, p_anyo INTEGER DEFAULT NULL) 
RETURN VARCHAR IS
    v_id_edicion CHAR(6);
    v_count INTEGER;
BEGIN
    -- Verificar que la obra existe
    SELECT COUNT(*) INTO v_count FROM obra WHERE id = p_id_obra;
    IF v_count = 0 THEN
        RETURN '0';  -- Error: la obra no existe
    END IF;

    -- Generar un nuevo ID único para la edición
    v_id_edicion := dbms_random.string('X', 6);

    -- Insertar la nueva edición
    INSERT INTO edicion (id, id_obra, isbn, anyo)
    VALUES (v_id_edicion, p_id_obra, p_isbn, p_anyo);

    RETURN v_id_edicion;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '-1';  -- En caso de cualquier error
END alta_edicion;
/

DECLARE
    v_id_obra VARCHAR(5) := 'O2KYG';
    v_isbn VARCHAR(20) := '978-3-16-148410-0';
    v_anyo INTEGER := 2025; 
    v_id_edicion VARCHAR(6);
BEGIN
    -- Llamar a la función y almacenar el resultado
    v_id_edicion := alta_edicion(v_id_obra, v_isbn, v_anyo);

    -- Mostrar el resultado
    DBMS_OUTPUT.PUT_LINE('ID Asignado: ' || v_id_edicion);
END;
/


-- 9
CREATE OR REPLACE FUNCTION borrado_edicion (p_id VARCHAR)
RETURN INTEGER IS 
    v_count INTEGER;
BEGIN
    -- Verificar si la edición existe
    SELECT COUNT(*) INTO v_count FROM edicion WHERE id = p_id;

    -- Si no existe devolver 0
    IF v_count = 0 THEN
        RETURN 0;
    END IF;

    -- Si existe, eliminar la obra
    DELETE FROM edicion WHERE id = p_id;

    -- Devolver 1 indicando que la obra fue eliminada correctamente y guardar cambios
    COMMIT;
    RETURN 1;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN -1;
END borrado_edicion;
/

DECLARE
    v_result INTEGER;
BEGIN
    v_result := borrado_edicion('QX86JR');
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_result);
END;
/


-- 10
CREATE OR REPLACE FUNCTION alta_ejemplar(p_id_edicion VARCHAR) 
RETURN INTEGER IS
    v_max_numero INTEGER;
    v_new_numero INTEGER;
    v_count INTEGER;
BEGIN
    -- Comprobar si la edición ya existe
    SELECT COUNT(*) INTO v_count
    FROM edicion
    WHERE id = p_id_edicion;

    IF v_count = 0 THEN
        RETURN -1;  -- Retorna -1 si la edición no existe
    END IF;

    -- Encontrar el número más alto de ejemplares para esta edición
    SELECT COALESCE(MAX(numero), 0) INTO v_max_numero -- Coalesce sustituye NULL por 0
    FROM ejemplar
    WHERE id_edicion = p_id_edicion;

    -- Asignar el nuevo número
    v_new_numero := v_max_numero + 1;

    -- Insertar el nuevo ejemplar con la fecha actual
    INSERT INTO ejemplar (id_edicion, numero, alta)
    VALUES (p_id_edicion, v_new_numero, SYSDATE);

    -- Devolver el número asignado
    RETURN v_new_numero;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -2;  -- Devuelve -2 si ocurre un error inesperado
END alta_ejemplar;
/

DECLARE
    v_id_edicion VARCHAR(10) := 'ZHEKI4';
    v_resultado INTEGER;
BEGIN
    -- Llamar a la función
    v_resultado := alta_ejemplar(v_id_edicion);

    -- Mostrar el resultado
    DBMS_OUTPUT.PUT_LINE('Número de ejemplar asignado: ' || v_resultado);
END;
/


-- 11
CREATE OR REPLACE FUNCTION borrado_ejemplar (p_id_edicion VARCHAR, p_numero INTEGER)
RETURN INTEGER IS 
    v_max_numero INTEGER;
    v_alta DATE;
    v_baja DATE;
    v_count INTEGER;
BEGIN
    -- Verificar si el ejemplar existe
    SELECT COUNT(*), MAX(numero) INTO v_count, v_max_numero
    FROM ejemplar
    WHERE id_edicion = p_id_edicion;

    -- Si el ejemplar no existe, devolver 0
    IF v_count = 0 THEN
        RETURN 0;
    END IF;

    -- Verificar si el ejemplar es el último de su serie
    IF p_numero != v_max_numero THEN
        RETURN -1;
    END IF;

    -- Obtener datos del ejemplar específico
    SELECT alta, baja INTO v_alta, v_baja
    FROM ejemplar
    WHERE id_edicion = p_id_edicion AND numero = p_numero;

    -- Verificar que no tenga fecha de baja y que no hayan pasado más de 30 días
    IF v_baja IS NOT NULL OR (SYSDATE - v_alta) > 30 THEN
        RETURN -1;
    END IF;

    -- Si todas las condiciones se cumplen, eliminar el ejemplar
    DELETE FROM ejemplar
    WHERE id_edicion = p_id_edicion AND numero = p_numero;

    -- Devolver 1 indicando que el ejemplar fue eliminado correctamente y guardar cambios
    COMMIT;
    RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN -2; -- Error inesperado
END borrado_ejemplar;
/

DECLARE 
    v_resultado INTEGER;
BEGIN
    v_resultado := borrado_ejemplar('ZHEKI4', 1);

    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Ejemplar borrado exitosamente.');
    ELSIF v_resultado = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ejemplar no encontrado.');
    ELSIF v_resultado = -1 THEN
        DBMS_OUTPUT.PUT_LINE('No se puede borrar: no cumple condiciones.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error inesperado.');
    END IF;
END;
/


-- 12
CREATE OR REPLACE FUNCTION baja_ejemplar(p_id_edicion VARCHAR, p_numero INTEGER)
RETURN INTEGER IS
    v_baja DATE;
    v_count INTEGER := 0;
BEGIN
    -- Verificar si el ejemplar existe
    SELECT COUNT(*) INTO v_count
    FROM ejemplar
    WHERE id_edicion = p_id_edicion AND numero = p_numero;

    -- Si el ejemplar no existe, devolver 0
    IF v_count = 0 THEN
        RETURN 0;
    END IF;

    -- Obtener la fecha de baja
    SELECT baja INTO v_baja
    FROM ejemplar
    WHERE id_edicion = p_id_edicion AND numero = p_numero;

    -- Verificar que el ejemplar no tenga fecha de baja
    IF v_baja IS NOT NULL THEN
        RETURN -1;
    END IF;

    -- Actualizar la fecha de baja con la fecha actual del sistema
    UPDATE ejemplar
    SET baja = SYSDATE
    WHERE id_edicion = p_id_edicion AND numero = p_numero;

    RETURN 1;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -2; -- Error inesperado
END baja_ejemplar;
/


DECLARE
    v_resultado INTEGER;
BEGIN
    v_resultado := baja_ejemplar('ZHEKI4', 1);

    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Baja efectuada correctamente.');
    ELSIF v_resultado = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ejemplar no encontrado.');
    ELSIF v_resultado = -1 THEN
        DBMS_OUTPUT.PUT_LINE('No se puede dar de baja: ya tiene fecha de baja.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error inesperado.');
    END IF;
END;
/


-- Opcionales
-- 1
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

CREATE OR REPLACE FUNCTION alta_socio (
    p_nombre VARCHAR2,
    p_apellidos VARCHAR2,  -- Corrección: parámetro renombrado
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
/

DECLARE
    v_nuevo_socio_id VARCHAR2(5);
BEGIN
    v_nuevo_socio_id := alta_socio('Carlos', 'López Fernández', TO_DATE('1985-07-21', 'YYYY-MM-DD'), '699123456', 'carlos@email.com');

    IF v_nuevo_socio_id = '-1' THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado al registrar el socio.');
    ELSIF v_nuevo_socio_id = '-2' THEN
        DBMS_OUTPUT.PUT_LINE('Error: El email ya está registrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Socio registrado exitosamente con ID: ' || v_nuevo_socio_id);
    END IF;
END;
/


-- 2
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

-- 3
CREATE OR REPLACE FUNCTION apertura_prestamo (
    p_id_socio    VARCHAR2,
    p_id_edicion  VARCHAR2,
    p_numero      INTEGER
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
/

DECLARE
    v_resultado INTEGER;
BEGIN
    v_resultado := apertura_prestamo('ABSNL', 'ZHEKI4', 1);

    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Préstamo registrado exitosamente.');
    ELSIF v_resultado = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Socio no encontrado.');
    ELSIF v_resultado = -2 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Ejemplar no encontrado.');
    ELSIF v_resultado = -3 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Ejemplar ya prestado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error inesperado.');
    END IF;
END;
/

-- 4
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

-- 5
CREATE OR REPLACE FUNCTION cierre_prestamo (
    p_id_prestamo VARCHAR2 --
) RETURN INTEGER IS
    v_count INTEGER;
    v_fecha_devolucion DATE;
BEGIN   
    -- Verificar si el prestamo existe
    SELECT COUNT(*) INTO v_count
    FROM prestamo_bibliotk
    WHERE id = p_id_prestamo;

    if v_count = 0 THEN
        RETURN -1; -- Error: Prestamo no encontrado
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
    RETURN 1; --Éxito: Prestamo cerrado correctamente
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN -3; -- Error inesperado
END cierre_prestamo;
/

DECLARE
    v_result INTEGER;
BEGIN
    v_result := cierre_prestamo('DHT13S'); -- ID de un préstamo válido

    IF v_result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Préstamo cerrado exitosamente.');
    ELSIF v_result = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Préstamo no encontrado.');
    ELSIF v_result = -2 THEN
        DBMS_OUTPUT.PUT_LINE('Error: El préstamo ya fue devuelto.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error inesperado.');
    END IF;
END;
/
