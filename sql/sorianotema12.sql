-- 1. Desarrolla un procedimiento que visualice el apellido y la fecha de alta de todos los empleados ordenados por apellido.
CREATE OR REPLACE PROCEDURE Mostrar_Empleados_Ordenados IS
BEGIN
    -- Recorremos todos los empleados de la tabla EMPLE, ordenados por apellido
    FOR empleado IN (
        SELECT APELLIDO, FECHA_ALT
        FROM EMPLE
        ORDER BY APELLIDO
    ) LOOP
        -- Mostramos el apellido y la fecha de alta de cada empleado en la salida de la consola
        DBMS_OUTPUT.PUT_LINE('Apellido: ' || empleado.APELLIDO || ' - Fecha de Alta: ' || TO_CHAR(empleado.FECHA_ALT, 'DD/MM/YYYY'));
    END LOOP;
END Mostrar_Empleados_Ordenados;
/

BEGIN
    Mostrar_Empleados_Ordenados;
END;
/

-- 2. Codifica un procedimiento que muestre el nombre de cada departamento y el número de empleados que tiene
CREATE OR REPLACE PROCEDURE Recuento_Departamento IS
BEGIN
    -- Recorremos todos los departamentos y contamos cuántos empleados hay en cada uno
    FOR depto IN (
        SELECT D.DNOMBRE AS NOMBRE_DEPARTAMENTO,
               COUNT(E.EMP_NO) AS NUMERO_EMPLEADOS
        FROM DEPART D
        LEFT JOIN EMPLE E ON D.DEPT_NO = E.DEPT_NO
        GROUP BY D.DNOMBRE
        ORDER BY D.DNOMBRE
    ) LOOP
        -- Mostramos el nombre del departamento y la cantidad de empleados
        DBMS_OUTPUT.PUT_LINE('Departamento: ' || depto.NOMBRE_DEPARTAMENTO || ' - Número de empleados: ' || depto.NUMERO_EMPLEADOS);
    END LOOP;
END Recuento_Departamento;
/

BEGIN
    Recuento_Departamento;
END;
/

-- 3. Escribe un programa que visualice el apellido y el salario de los cinco empleados que tienen el salario más alto
CREATE OR REPLACE PROCEDURE Top_5_Salarios IS
BEGIN
    -- Recorremos los 5 empleados con el salario más alto
    FOR empleado IN (
        SELECT APELLIDO, SALARIO
        FROM (SELECT APELLIDO, SALARIO FROM EMPLE ORDER BY SALARIO DESC)
        WHERE ROWNUM <= 5
    ) LOOP
        -- Mostramos el apellido y el salario de cada empleado
        DBMS_OUTPUT.PUT_LINE('Apellido: ' || empleado.APELLIDO || ' - Salario: ' || empleado.SALARIO);
    END LOOP;
END Top_5_Salarios;
/

BEGIN
    Top_5_Salarios;
END;
/

-- 4. Codifica un programa que visualice los dos empleados que ganan menos de cada oficio
CREATE OR REPLACE PROCEDURE Sub_2_Salarios IS
BEGIN
    -- Recorremos los dos empleados con el salario más bajo
    FOR empleado IN (
        SELECT APELLIDO, OFICIO, SALARIO
        FROM (
            SELECT APELLIDO, OFICIO, SALARIO,
                DENSE_RANK() OVER (PARTITION BY OFICIO ORDER BY SALARIO ASC) AS RANKING
            FROM EMPLE
        )
        WHERE RANKING <= 2
        ORDER BY OFICIO, SALARIO
    ) LOOP
        -- Mostramos el apellido, oficio y salario de los empleados seleccionados
        DBMS_OUTPUT.PUT_LINE('Oficio: ' || empleado.OFICIO || ' - Apellido: ' || empleado.APELLIDO || ' - Salario: ' || empleado.SALARIO);
    END LOOP;
END Sub_2_Salarios;
/

BEGIN
    Sub_2_salarios;
END;
/

-- 5. Desarrolla un procedimiento que permita insertar nuevos departamentos según las siguientes especificaciones:
-- Se pasará al procedimiento el nomrbe del departamento y la localidad
-- El procedimiento se insertará lafila nueva asignando como número de departamento la decena siguiente al número mayor de la tabla
-- Se incluirá la gestión de posibles errores
CREATE OR REPLACE PROCEDURE Insertar_Departamento(
    p_nombre IN DEPART.DNOMBRE%TYPE,
    p_localidad IN DEPART.LOC%TYPE
)
IS
    v_nuevo_dept_no NUMBER(2); -- Variable para almacenar el nuevo número de departamento
BEGIN
    -- Verificar que los valores no sean NULL
    IF p_nombre IS NULL OR p_localidad IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre del departamento y la localidad no pueden ser nulos.');
    END IF;

    -- Obtener el mayor número de departamento y sumarle 10
    SELECT NVL(MAX(DEPT_NO), 0) + 10 INTO v_nuevo_dept_no FROM DEPART;

    -- Insertar el nuevo departamento
    INSERT INTO DEPART (DEPT_NO, DNOMBRE, LOC)
    VALUES (v_nuevo_dept_no, p_nombre, p_localidad);

    -- Confirmar la inserción
    COMMIT;

    -- Mensaje de confirmación
    DBMS_OUTPUT.PUT_LINE('Departamento insertado correctamente: ' || p_nombre || ' (Nº ' || v_nuevo_dept_no || ') en ' || p_localidad);

EXCEPTION
    -- Error si el nombre del departamento ya existe
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Ya existe un departamento con ese nombre.');

    -- Otros errores inesperados
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        ROLLBACK; -- Deshacer la transacción en caso de error
END Insertar_Departamento;
/

BEGIN
    Insertar_Departamento('TRANSPORTE', 'ASTURIAS');
END;
/

-- 6. Codifica un procedimiento que reciba como parámetros un número de departamento, un importe y un porcentaje;
-- y que suba el salario a todos los empleados del departamento indicado en la llamada. La subida será el porcentaje
-- o el importe que se indica en la llamada (el que sea más beneficioso para el empleado en cada caso)
CREATE OR REPLACE PROCEDURE Ascenso_Dpto(
    p_dept_no IN EMPLE.DEPT_NO%TYPE,
    p_importe IN NUMBER,
    p_porcentaje IN NUMBER
) IS
    v_count NUMBER;
BEGIN   
    -- Validar si el departamento existe
    SELECT COUNT(*) INTO v_count FROM DEPART WHERE DEPT_NO = p_dept_no;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El departamento no existe');
    END IF;

    -- Actualizar los salarios seleccionando la mejor opción para cada empleado
    FOR empleado IN (
        SELECT EMP_NO, APELLIDO, SALARIO
        FROM EMPLE
        WHERE DEPT_NO = p_dept_no
    ) LOOP
        DECLARE
            v_nuevo_salario NUMBER;
            v_aumento_importe NUMBER;
            v_aumento_porcentaje NUMBER;
        BEGIN
            -- calcular ambas opciones de aumento
            v_aumento_importe := p_importe;
            v_aumento_porcentaje := (empleado.SALARIO * p_porcentaje) / 100;

            -- Elegir el mayor aumento
            v_nuevo_salario := empleado.SALARIO + GREATEST(v_aumento_importe, v_aumento_porcentaje);

            -- Aplicar el aumento en la base de datos
            UPDATE EMPLE
            SET SALARIO = v_nuevo_salario
            WHERE EMP_NO = empleado.EMP_NO;

            -- Mostrar los cambios
            DBMS_OUTPUT.PUT_LINE('Empleado: ' || empleado.APELLIDO || ' - Salario anterior: ' || empleado.SALARIO || ' - Nuevo salario: ' || v_nuevo_salario);
        END;
    END LOOP;

    -- Confirmar cambios
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Subida de salarios completada para el departamento ' || p_dept_no);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No hay empleados en el departamento ' || p_dept_no);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
    ROLLBACK;
END Ascenso_Dpto;
/

BEGIN
    Ascenso_Dpto(30, 200, 10);
END;
/

-- 7. Escribe un procedimiento que suba el sueldo de todos los empleados que ganen menos que el salario medio de su oficio.
-- La subida será del 50 por 100 de la diferencia entre el salario del empleado y la media de su oficio. Se deberá hacer
-- que la transacción no se quede a medias, y se gestionarán los posibles errores.
CREATE OR REPLACE PROCEDURE Subir_Salario_Bajo IS
BEGIN
    -- Recorremos los empleados que ganan menos que la media de su oficio
    FOR empleado IN (
        SELECT E.EMP_NO, E.APELLIDO, E.SALARIO, E.OFICIO, 
               (SELECT AVG(SALARIO) FROM EMPLE WHERE OFICIO = E.OFICIO) AS SALARIO_MEDIO
        FROM EMPLE E
    ) LOOP
        -- Si el salario es menor que la media, se calcula el aumento
        IF empleado.SALARIO < empleado.SALARIO_MEDIO THEN
            DECLARE
                v_aumento NUMBER;
                v_nuevo_salario NUMBER;
            BEGIN
                -- Calcular el aumento (50% de la diferencia) y redondear
                v_aumento := ROUND((empleado.SALARIO_MEDIO - empleado.SALARIO) * 0.5, 2);
                v_nuevo_salario := ROUND(empleado.SALARIO + v_aumento, 2);

                -- Actualizar el salario en la base de datos
                UPDATE EMPLE 
                SET SALARIO = v_nuevo_salario 
                WHERE EMP_NO = empleado.EMP_NO;

                -- Mostrar los cambios con decimales limitados
                DBMS_OUTPUT.PUT_LINE('Empleado: ' || empleado.APELLIDO ||
                                    ' - Salario anterior: ' || empleado.SALARIO || 
                                    ' - Nuevo salario: ' || v_nuevo_salario);
            END;
        END IF;
    END LOOP;

    -- Confirmar los cambios
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Subida de salario completada.');

EXCEPTION
    WHEN OTHERS THEN
        -- Si hay un error, deshacer los cambios
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        ROLLBACK;
END Subir_Salario_Bajo;
/

BEGIN
    Subir_Salario_Bajo;
END;
/

-- 8. Diseña una aplicación que simule un listado de liquidación de los empleados según
-- las siguientes especificaciones:
-- *****************************
-- Liquidación del empleado :(1)
-- Dpto                     :(2)
-- Oficio                   :(3)
-- Salario                  :(4)
-- Trienios                 :(5)
-- Comp. responsabilidad    :(6)
-- Comision                 :(7)
-- *****************************
-- Total                    :(8)

-- Donde:
-- 1, 2, 3 y 4 corresponden a apellido, departamento, oficio y salario del empleado
-- 5 es el importe en concepto de trienios. Un trienio son tres años completos, desde la fecha de alta hasta la de emisión, y supone 50€
-- 6 es el complemento por responsabilidad. Será de 100€ por cada empleado que se encuentre directamente a cargo del empleado en cuestión
-- 7 es la comisión. Los valores nulos serán sustituidos por ceros
-- 8 es la suma de todos los conceptos anteriores

-- El listado ira ordenado por Apellido
CREATE OR REPLACE PROCEDURE Listado_Liquidacion IS
BEGIN
    -- Recorremos cada empleado ordenado por apellido
    FOR rec IN (
        SELECT 
            E.APELLIDO,
            D.DNOMBRE AS DEPARTAMENTO, -- Cambiado de D.NOMBRE a D.DNOMBRE
            E.OFICIO,
            E.SALARIO,
            E.FECHA_ALT,  
            NVL(E.COMISION, 0) AS COMISION,
            E.EMP_NO
        FROM EMPLE E
        JOIN DEPART D ON E.DEPT_NO = D.DEPT_NO
        ORDER BY E.APELLIDO
    ) LOOP
        -- Variables locales
        DECLARE
            v_trienios NUMBER;
            v_comp_responsabilidad NUMBER;
            v_total NUMBER;
        BEGIN
            -- Cálculo de trienios (50€ por cada 3 años completos)
            v_trienios := FLOOR(MONTHS_BETWEEN(SYSDATE, rec.FECHA_ALT) / 36) * 50;

            -- Cálculo del complemento de responsabilidad (100€ por cada subordinado)
            SELECT NVL(COUNT(*), 0) * 100 
            INTO v_comp_responsabilidad
            FROM EMPLE
            WHERE DIR = rec.EMP_NO;

            -- Cálculo del total de liquidación
            v_total := rec.SALARIO + v_trienios + v_comp_responsabilidad + rec.COMISION;

            -- Mostrar la liquidación con formato
            DBMS_OUTPUT.PUT_LINE('*****************************');
            DBMS_OUTPUT.PUT_LINE('Liquidación del empleado: ' || rec.APELLIDO);
            DBMS_OUTPUT.PUT_LINE('Dpto                     : ' || rec.DEPARTAMENTO);
            DBMS_OUTPUT.PUT_LINE('Oficio                   : ' || rec.OFICIO);
            DBMS_OUTPUT.PUT_LINE('Salario                  : ' || rec.SALARIO);
            DBMS_OUTPUT.PUT_LINE('Trienios                 : ' || v_trienios);
            DBMS_OUTPUT.PUT_LINE('Comp. responsabilidad    : ' || v_comp_responsabilidad);
            DBMS_OUTPUT.PUT_LINE('Comisión                 : ' || rec.COMISION);
            DBMS_OUTPUT.PUT_LINE('*****************************');
            DBMS_OUTPUT.PUT_LINE('Total                    : ' || v_total);
            DBMS_OUTPUT.PUT_LINE('');
        END;
    END LOOP;

    -- Confirmar ejecución exitosa
    DBMS_OUTPUT.PUT_LINE('Listado de liquidación generado con éxito.');

EXCEPTION
    WHEN OTHERS THEN
        -- Manejo de errores
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END Listado_Liquidacion;
/

BEGIN
    Listado_Liquidacion;
END;
/

-- 9. Crea la tabla T_liquidacion con las columnas apellido, departamento, oficio, salario, trienios
-- comp_responsabilidad, comision y total; y modifica la aplicación anterior para que, en lugar de 
-- realizar el listado directamente en pantalla, guarde los datos en la tabla. Se controlarán
-- todas las posibles incidencias que puedan ocurrir durante el proceso.

CREATE TABLE T_liquidacion (
    APELLIDO VARCHAR2(20),
    DEPARTAMENTO VARCHAR2(20),
    OFICIO VARCHAR2(10),
    SALARIO NUMBER(10, 2),
    TRIENIOS NUMBER(10, 2),
    COMP_RESPONSABILIDAD NUMBER(10, 2),
    COMISION NUMBER(10, 2),
    TOTAL NUMBER(10, 2)
);

CREATE OR REPLACE PROCEDURE Listado_Liquidacion IS
BEGIN
    -- Recorremos cada empleado ordenado por apellido
    FOR rec IN (
        SELECT 
            E.APELLIDO,
            D.DNOMBRE AS DEPARTAMENTO,
            E.OFICIO,
            E.SALARIO,
            E.FECHA_ALT,
            NVL(E.COMISION, 0) AS COMISION,
            E.EMP_NO
        FROM EMPLE E
        JOIN DEPART D ON E.DEPT_NO = D.DEPT_NO
        ORDER BY E.APELLIDO
    ) LOOP
        -- Variables locales
        DECLARE
            v_trienios NUMBER(10, 2);
            v_comp_responsabilidad NUMBER(10, 2);
            v_total NUMBER(10, 2);
        BEGIN
            -- Cálculo de trienios (50€ por cada 3 años completos)
            v_trienios := FLOOR(MONTHS_BETWEEN(SYSDATE, rec.FECHA_ALT) / 36) * 50;

            -- Cálculo del complemento de responsabilidad (100€ por cada subordinado)
            SELECT NVL(COUNT(*), 0) * 100
            INTO v_comp_responsabilidad
            FROM EMPLE
            WHERE DIR = rec.EMP_NO;

            -- Cálculo del total de liquidación
            v_total := rec.SALARIO + v_trienios + v_comp_responsabilidad + rec.COMISION;

            -- Insertar los datos en la tabla T_liquidacion
            INSERT INTO T_liquidacion (
                APELLIDO, DEPARTAMENTO, OFICIO, SALARIO, TRIENIOS,
                COMP_RESPONSABILIDAD, COMISION, TOTAL
            ) VALUES (
                rec.APELLIDO, rec.DEPARTAMENTO, rec.OFICIO, rec.SALARIO,
                v_trienios, v_comp_responsabilidad, rec.COMISION, v_total
            );

        END;
    END LOOP;

    -- Confirmar los cambios
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Los datos de liquidación han sido almacenados en la tabla T_liquidacion.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Se ha intentado insertar un valor duplicado.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        ROLLBACK;
END Listado_Liquidacion;
/

BEGIN
    Listado_Liquidacion;
END;
/

-- 10. Escribe un programa para introducir nuevos pedidos según las siguientes especificaciones:
-- · Recibirá como parámetros PEDIDO_NO, PRODUCTO_NO, CLIENTE_NO, UNIDADES y la FECHA_PEDIDO (opcional, por defecto la del sistema)
-- Verifica todos estos datos así como las unidades disponibles del producto y el limite de crédito del cliente y fallará enviando
-- un mensja mensaje de error en caso de que alguno sea erróneo
-- · Insertará el pedido y actualizará la columna DEBE de clientes incrementandola el valor del pedido (UNIDADES * PRECIO_ACTUAL). 
-- Tambien actualizara las unidades disponibles del producto e incrementará la comisión para el empleado correspondiente al cliente
-- en un 5% del valor total del pedido. Todas estas operaciones se realizarán como una única transacción.
CREATE OR REPLACE PROCEDURE Insertar_Pedido(
    p_pedido_no IN NUMBER,
    p_producto_no IN NUMBER,
    p_cliente_no IN NUMBER,
    p_unidades IN NUMBER,
    p_fecha_pedido IN DATE DEFAULT SYSDATE
) IS
    -- Variables auxiliares
    v_precio_actual NUMBER;
    v_stock_disponible NUMBER;
    v_limite_credito NUMBER;
    v_debe_actual NUMBER;
    v_total_pedido NUMBER;
    v_empleado_no NUMBER;
BEGIN
    -- Verificar si el producto existe y obtener su precio y stock
    SELECT PRECIO_ACTUAL, STOCK_DISPONIBLE
    INTO v_precio_actual, v_stock_disponible
    FROM PRODUCTOS08
    WHERE PRODUCTO_NO = p_producto_no;

    -- Verificar si hay suficiente stock disponible
    IF v_stock_disponible < p_unidades THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Stock insuficiente para el producto.');
    END IF;

    -- Verificar si el cliente existe y obtener su límite de crédito y deuda actual
    SELECT LIMITE_CREDITO, DEBE, VENDEDOR_NO
    INTO v_limite_credito, v_debe_actual, v_empleado_no
    FROM CLIENTES08
    WHERE CLIENTE_NO = p_cliente_no;

    -- Calcular el total del pedido
    v_total_pedido := p_unidades * v_precio_actual;

    -- Verificar si el pedido supera el límite de crédito del cliente
    IF (v_debe_actual + v_total_pedido) > v_limite_credito THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: Pedido excede el límite de crédito del cliente.');
    END IF;

    -- Insertar el nuevo pedido
    INSERT INTO PEDIDOS08 (PEDIDO_NO, PRODUCTO_NO, CLIENTE_NO, UNIDADES, FECHA_PEDIDO)
    VALUES (p_pedido_no, p_producto_no, p_cliente_no, p_unidades, p_fecha_pedido);

    -- Actualizar la deuda del cliente
    UPDATE CLIENTES08
    SET DEBE = DEBE + v_total_pedido
    WHERE CLIENTE_NO = p_cliente_no;

    -- Actualizar el stock del producto
    UPDATE PRODUCTOS08
    SET STOCK_DISPONIBLE = STOCK_DISPONIBLE - p_unidades
    WHERE PRODUCTO_NO = p_producto_no;

    -- Incrementar la comisión del empleado asignado al cliente en un 5% del total del pedido
    UPDATE EMPLE
    SET COMISION = NVL(COMISION, 0) + (v_total_pedido * 0.05)
    WHERE EMP_NO = v_empleado_no;

    -- Confirmar la transacción
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Pedido insertado correctamente.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Producto o cliente no encontrado.');
        ROLLBACK;
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: El número de pedido ya existe.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        ROLLBACK;
END Insertar_Pedido;
/

EXEC Insertar_Pedido(1018, 10, 105, 3, SYSDATE);
