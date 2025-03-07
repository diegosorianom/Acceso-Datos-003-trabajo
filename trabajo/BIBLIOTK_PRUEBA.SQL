DECLARE
    v_id_obra VARCHAR(5);
    v_id_autor VARCHAR(4);
    v_resultado INTEGER;
    v_id_edicion VARCHAR(6);
    v_id_ejemplar INTEGER;
BEGIN
    -- Alta de una obra
    v_id_obra := BiblioTK.alta_obra('El Imperio Final', 2006);
    DBMS_OUTPUT.PUT_LINE('Obra creada con ID: ' || v_id_obra);

    -- Alta de un autor
    v_id_autor := BiblioTK.alta_autor('Brandon', 'Sanderson', TO_DATE('1975-12-19', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Autor creado con ID: ' || v_id_autor);

    -- Vincular autor con la obra
    v_resultado := BiblioTK.vincular(v_id_autor, v_id_obra);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor vinculado con la obra correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al vincular autor con la obra.');
    END IF;

    -- Alta de una edición de la obra
    v_id_edicion := BiblioTK.alta_edicion(v_id_obra, '978-84-450-7430-5', 2008);
    DBMS_OUTPUT.PUT_LINE('Edición creada con ID: ' || v_id_edicion);

    -- Alta de un ejemplar
    v_id_ejemplar := BiblioTK.alta_ejemplar(v_id_edicion);
    DBMS_OUTPUT.PUT_LINE('Ejemplar creado con número: ' || v_id_ejemplar);

    -- Borrar ejemplar
    v_resultado := BiblioTK.borrado_ejemplar(v_id_edicion, v_id_ejemplar);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Ejemplar eliminado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al eliminar ejemplar.');
    END IF;

    -- Desvincular autor de la obra
    v_resultado := BiblioTK.desvincular(v_id_autor, v_id_obra);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor desvinculado de la obra correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al desvincular autor.');
    END IF;

    -- Borrar la obra
    v_resultado := BiblioTK.borrado_obra(v_id_obra);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Obra eliminada correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al eliminar la obra.');
    END IF;

    -- Borrar el autor
    v_resultado := BiblioTK.borrado_autor(v_id_autor);
    IF v_resultado = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Autor eliminado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al eliminar el autor.');
    END IF;

END;
/
