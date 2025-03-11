ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
CREATE USER GOBLIN IDENTIFIED BY GOBLIN;
GRANT CONNECT TO GOBLIN;
GRANT RESOURCE TO GOBLIN;
GRANT DBA TO GOBLIN;
CONNECT GOBLIN/GOBLIN;
SET SERVEROUTPUT ON;

-- -------------------
-- TABLAS OBLIGATORIAS
-- -------------------

-- Crear tabla autor
CREATE TABLE obra (
    id CHAR (5),
    titulo VARCHAR(100),
    anyo INTEGER,
    CONSTRAINT PK_obra PRIMARY KEY (id),
    CONSTRAINT NN_titulo CHECK (titulo IS NOT NULL)
);

-- Crear tabla autor
CREATE TABLE autor (
    id CHAR(4),
    nombre VARCHAR(30),
    apellidos VARCHAR(60),
    nacimiento DATE,
    CONSTRAINT PK_autor PRIMARY KEY (id),
    CONSTRAINT NN_nombre CHECK (nombre IS NOT NULL),
    CONSTRAINT NN_apellidos CHECK (apellidos IS NOT NULL)
);

-- Crear tabla relación autor-obra
CREATE TABLE autor_obra (
    id_autor CHAR(4),
    id_obra CHAR(5),
    CONSTRAINT PK_autor_obra PRIMARY KEY (id_autor, id_obra),
    CONSTRAINT FK_autor_obra_id_autor FOREIGN KEY (id_autor) REFERENCES autor (id),
    CONSTRAINT FK_autor_obra_id_obra FOREIGN KEY (id_obra) REFERENCES obra (id)
);

-- Crear tabla edicion
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

-- Crear tabla ejemplar
CREATE TABLE ejemplar (
    id_edicion CHAR(6),
    numero INTEGER,
    alta DATE,
    baja DATE,
    CONSTRAINT PK_ejemplar PRIMARY KEY (id_edicion, numero),
    CONSTRAINT FK_ejemplar FOREIGN KEY (id_edicion) REFERENCES edicion(id),
    CONSTRAINT NN_alta CHECK (alta IS NOT NULL)
);

CREATE SEQUENCE obra_historico_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Crear tabla historico obra
CREATE TABLE obra_historico (
    id_historico NUMBER,
    id CHAR(5),
    titulo VARCHAR(100),
    anyo INTEGER,
    fecha_borrado TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT PK_id_historico PRIMARY KEY (id_historico)
);