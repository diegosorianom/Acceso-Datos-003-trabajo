CREATE OR REPLACE PACKAGE BiblioTK AS
    FUNCTION alta_obra(p_titulo VARCHAR, p_anyo INTEGER DEFAULT NULL) RETURN VARCHAR;
    FUNCTION borrado_obra(p_id VARCHAR) RETURN INTEGER;
    FUNCTION alta_autor(p_nombre VARCHAR, p_apellidos VARCHAR, p_nacimiento DATE DEFAULT NULL) RETURN VARCHAR IS;
    FUNCTION borrado_autor(p_id VARCHAR) RETURN INTEGER;
    FUNCTION vincular(p_id_autor VARCHAR, p_id_obra VARCHAR) RETURN INTEGER;
    FUNCTION desvincular(p_id_autor VARCHAR, p_id_obra VARCHAR) RETURN INTEGER;
    FUNCTION alta_edicion(p_id_obra VARCHAR, p_isbn VARCHAR, p_anyo INTEGER DEFAULT NULL) RETURN VARCHAR;
    FUNCTION borrado_edicion(p_id VARCHAR) RETURN INTEGER;
    FUNCTION alta_ejemplar(p_id_edicion VARCHAR) RETURN INTEGER;
    FUNCTION borrado_ejemplar(p_id_edicion VARCHAR, p_numero INTEGER) RETURN INTEGER;
    FUNCTION baja_ejemplar(p_id_edicion VARCHAR, p_numero INTEGER) RETURN INTEGER;
END BiblioTK;
/