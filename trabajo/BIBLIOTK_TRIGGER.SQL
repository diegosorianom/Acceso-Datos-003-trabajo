CREATE OR REPLACE TRIGGER trg_auditar_borrado_obra
BEFORE DELETE ON obra
FOR EACH ROW
BEGIN
    -- Guarda la obra eliminada en obra_historico antes de borrarla
    INSERT INTO obra_historico (id, titulo, anyo, fecha_borrado)
    VALUES (:OLD.id, :OLD.titulo, :OLD.anyo, SYSTIMESTAMP);
END;
/
