-- Tabla producto

DELIMITER $$
CREATE TRIGGER producto_insert
AFTER INSERT ON producto
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla producto', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER producto_update
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla producto', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER producto_delete
AFTER DELETE ON producto
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla producto', 'DELETE');
END$$
DELIMITER ;

-- Tabla puesto

DELIMITER $$
CREATE TRIGGER puesto_insert
AFTER INSERT ON puesto
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla puesto', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER puesto_update
AFTER UPDATE ON puesto
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla puesto', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER puesto_delete
AFTER DELETE ON puesto
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla puesto', 'DELETE');
END$$
DELIMITER ;

-- Tabla cliente

DELIMITER $$
CREATE TRIGGER cliente_insert
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla cliente', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER cliente_update
AFTER UPDATE ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla cliente', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER cliente_delete
AFTER DELETE ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla cliente', 'DELETE');
END$$
DELIMITER ;

-- Tabla restaurante

DELIMITER $$
CREATE TRIGGER restaurante_insert
AFTER INSERT ON restaurante
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla restaurante', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER restaurante_update
AFTER UPDATE ON restaurante
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla restaurante', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER restaurante_delete
AFTER DELETE ON restaurante
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla restaurante', 'DELETE');
END$$
DELIMITER ;

-- Tabla orden

DELIMITER $$
CREATE TRIGGER orden_insert
AFTER INSERT ON orden
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla orden', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER orden_update
AFTER UPDATE ON orden
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla orden', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER orden_delete
AFTER DELETE ON orden
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla orden', 'DELETE');
END$$
DELIMITER ;

-- Tabla item

DELIMITER $$
CREATE TRIGGER item_insert
AFTER INSERT ON item
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla item', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER item_update
AFTER UPDATE ON item
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla item', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER item_delete
AFTER DELETE ON item
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla item', 'DELETE');
END$$
DELIMITER ;

-- Tabla direccion

DELIMITER $$
CREATE TRIGGER direccion_insert
AFTER INSERT ON direccion
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla direccion', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER direccion_update
AFTER UPDATE ON direccion
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla direccion', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER direccion_delete
AFTER DELETE ON direccion
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla direccion', 'DELETE');
END$$
DELIMITER ;

-- Tabla empleado

DELIMITER $$
CREATE TRIGGER empleado_insert
AFTER INSERT ON empleado
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla empleado', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER empleado_update
AFTER UPDATE ON empleado
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla empleado', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER empleado_delete
AFTER DELETE ON empleado
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla empleado', 'DELETE');
END$$
DELIMITER ;

-- Tabla factura

DELIMITER $$
CREATE TRIGGER factura_insert
AFTER INSERT ON factura
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una insercion en la tabla factura', 'INSERT');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER factura_update
AFTER UPDATE ON factura
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una actualización en la tabla factura', 'UPDATE');
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER factura_delete
AFTER DELETE ON factura
FOR EACH ROW
BEGIN
    INSERT INTO transaccion (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una eliminación en la tabla factura', 'DELETE');
END$$
DELIMITER ;