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
CREATE TABLE obra_historico (
    id CHAR(5),
    titulo VARCHAR(100),
    anyo INTEGER,
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE OR REPLACE TRIGGER auditar_borrado
BEFORE DELETE ON obra
FOR EACH ROW
BEGIN
    -- Guardar la obra eliminada en obra_historico antes de borrarla
    INSERT INTO obra_historico(id, titulo, anyo, fecha_borrado)
    VALUES (:OLD.id, :OLD.titulo, NULL, SYSTIMESTAMP);
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