SELECT 
    OBJECT_NAME AS PROCEDURE_NAME,
    STATUS
FROM 
    USER_OBJECTS
WHERE 
    OBJECT_TYPE = 'PROCEDURE'
OR
    OBJECT_TYPE = 'FUNCTION'
ORDER BY 
    OBJECT_NAME;