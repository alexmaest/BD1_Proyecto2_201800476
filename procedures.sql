DELIMITER $$
CREATE PROCEDURE RegistrarRestaurante(
  IN p_id_restaurante VARCHAR(255),
  IN p_direccion VARCHAR(255),
  IN p_municipio VARCHAR(255),
  IN p_zona INT,
  IN p_telefono INT,
  IN p_personal INT,
  IN p_tiene_parqueo INT
)
BEGIN
  DECLARE tiene_parqueo_val BOOLEAN;
  
  IF (p_zona > 0 AND p_personal > 0 AND (p_tiene_parqueo = 0 OR p_tiene_parqueo = 1)) THEN
    IF (p_tiene_parqueo = 1) THEN
      SET tiene_parqueo_val = TRUE;
    ELSE
      SET tiene_parqueo_val = FALSE;
    END IF;
    
    IF NOT EXISTS (SELECT id_restaurante FROM restaurante WHERE id_restaurante = p_id_restaurante) THEN
      INSERT INTO restaurante (
        id_restaurante,
        direccion,
        municipio,
        zona,
        telefono,
        personal,
        tiene_parqueo
      )
      VALUES (
        p_id_restaurante,
        p_direccion,
        p_municipio,
        p_zona,
        p_telefono,
        p_personal,
        tiene_parqueo_val
      );
      
      SELECT "Restaurante registrado exitosamente.";
    ELSE
      SELECT "Error al registrar restaurante. El restaurante ya existe en la tabla.";
    END IF;
  ELSE
    SELECT "Error al registrar restaurante. Verifique los parámetros ingresados.";
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE RegistrarPuesto(
  IN p_nombre VARCHAR(255),
  IN p_descripcion VARCHAR(255),
  IN p_salario DECIMAL(10,2)
)
BEGIN
    IF p_salario < 0 THEN
        SELECT "Error al registrar puesto. El salario es negativo.";
    ELSE
        IF NOT EXISTS (SELECT id_puesto FROM puesto WHERE nombre = p_nombre) THEN
            INSERT INTO puesto(nombre, descripcion, salario) VALUES (p_nombre, p_descripcion, p_salario);
            SELECT "Puesto registrado exitosamente.";
        ELSE
            SELECT "Error al registrar puesto. El puesto ya existe en la tabla.";
        END IF;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE RegistrarCliente(
  IN p_dpi BIGINT,
  IN p_nombre VARCHAR(255),
  IN p_apellidos VARCHAR(255),
  IN p_fecha_nacimiento DATETIME,
  IN p_correo VARCHAR(255),
  IN p_telefono INT,
  IN p_nit INT
)
BEGIN
  DECLARE num_rows INT;
  SELECT COUNT(*) INTO num_rows FROM cliente WHERE dpi = p_dpi;
  IF num_rows > 0 THEN
    SELECT "Error al registrar cliente. El DPI ya existe en la tabla.";
  ELSEIF p_correo NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' THEN
    SELECT "Error al registrar cliente. El correo no es un formato válido.";
  ELSE
    INSERT INTO cliente (dpi, nombre, apellidos, fecha_nacimiento, correo, telefono, nit) 
    VALUES (p_dpi, p_nombre, p_apellidos, p_fecha_nacimiento, p_correo, p_telefono, p_nit);
    SELECT "Cliente registrado exitosamente.";
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE RegistrarDireccion (IN dpi_cliente BIGINT, IN direccion VARCHAR(255), IN municipio VARCHAR(255), IN zona INT)
BEGIN
  DECLARE cliente_existente INT;

  SELECT COUNT(*) INTO cliente_existente FROM cliente WHERE dpi = dpi_cliente;
  
  IF cliente_existente = 0 THEN
    SELECT "Error al registrar dirección. EL cliente no existe.";
  ELSEIF zona <= 0 THEN
    SELECT "Error al registrar dirección. La zona debe ser un entero positivo.";
  ELSE
    INSERT INTO direccion (direccion, municipio, zona, dpi) VALUES (direccion, municipio, zona, dpi_cliente);
    SELECT "Direccion registrada exitosamente.";
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE CrearEmpleado(
  IN nombres VARCHAR(255), 
  IN apellidos VARCHAR(255), 
  IN fecha_nacimiento DATETIME, 
  IN correo VARCHAR(255), 
  IN telefono INT, 
  IN direccion VARCHAR(255), 
  IN p_dpi BIGINT, 
  IN p_id_puesto INT, 
  IN fecha_inicio DATETIME, 
  IN p_id_restaurante VARCHAR(255)
)
BEGIN
  
  DECLARE empleado_existente INT;
  DECLARE puesto_existente INT;
  DECLARE restaurante_existente INT;
  
  SELECT COUNT(*) INTO empleado_existente FROM empleado WHERE dpi = p_dpi;
  SELECT COUNT(*) INTO puesto_existente FROM puesto WHERE id_puesto = p_id_puesto;
  SELECT COUNT(*) INTO restaurante_existente FROM restaurante WHERE id_restaurante = p_id_restaurante;
  
  IF empleado_existente > 0 THEN
      SELECT "Error al registrar empleado. El DPI especificado ya existe en la tabla.";
  ELSEIF restaurante_existente = 0 THEN
      SELECT "Error al registrar empleado. El restaurante especificado no existe.";
  ELSEIF correo NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' THEN
      SELECT "Error al registrar empleado. El correo no es un formato válido.";
  ELSEIF puesto_existente = 0 THEN
      SELECT "Error al registrar empleado. El puesto especificado no existe.";
  ELSE
    
    INSERT INTO empleado (nombres, apellidos, fecha_nacimiento, correo, telefono, direccion, dpi, fecha_inicio, id_puesto, id_restaurante) 
    VALUES (nombres, apellidos, fecha_nacimiento, correo, telefono, direccion, p_dpi, fecha_inicio, p_id_puesto, p_id_restaurante);
    SELECT "Empleado registrado exitosamente.";
      
  END IF;
  
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE AgregarItem(
  IN IdOrden INT,
  IN TipoProducto CHAR(1),
  IN Producto INT,
  IN Cantidad INT,
  IN Observacion VARCHAR(255)
)
AgregarItem:BEGIN
  DECLARE OrdenExistente INT;
  DECLARE EstadoActual VARCHAR(255);
  DECLARE ProductoExistente INT;
  

  SELECT COUNT(*) INTO OrdenExistente FROM orden WHERE id_orden = IdOrden;
  SELECT estado INTO EstadoActual FROM orden WHERE id_orden = IdOrden;
  SELECT COUNT(*) INTO ProductoExistente FROM producto WHERE numero = Producto AND tipo = TipoProducto;
  
  IF OrdenExistente = 0 THEN
    SELECT "Error al añadir item. La orden indicada no existe.";
    LEAVE AgregarItem;
  END IF;

  IF EstadoActual != 'INICIADA' AND  EstadoActual != 'AGREGANDO' THEN
    SELECT "Error al añadir item. No se puede agregar un item a una orden que no está en estado INICIADA.";
    LEAVE AgregarItem;
  END IF;
  
  IF ProductoExistente = 0 THEN
    SELECT "Error al añadir item. El producto indicado no existe.";
    LEAVE AgregarItem;
  END IF;
  
  IF Cantidad <= 0 THEN
    SELECT "Error al añadir item. La cantidad debe ser un entero positivo.";
    LEAVE AgregarItem;
  END IF;
  
  UPDATE orden SET estado = 'AGREGANDO' WHERE id_orden = IdOrden;
  
  INSERT INTO item (tipo_producto, producto, cantidad, observacion, id_orden, id_producto)
  SELECT TipoProducto, Producto, Cantidad, Observacion, IdOrden, id_producto
  FROM producto
  WHERE tipo = TipoProducto AND numero = Producto;
  
  SELECT "Item añadido exitosamente.";
  
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE CrearOrden (IN dpi_cliente BIGINT, IN p_id_direccion_cliente INT, IN canal CHAR)
CrearOrden1:BEGIN
    DECLARE direccion_zona INT;
    DECLARE direccion_municipio VARCHAR(255);
    DECLARE restaurante_zona INT;
    DECLARE restaurante_municipio VARCHAR(255);
    DECLARE restaurante_id VARCHAR(255);
    DECLARE cliente_existente INT;
    DECLARE direccion_existente INT;

      -- Verificar si el cliente existe
      SELECT COUNT(*) INTO cliente_existente FROM cliente WHERE dpi = dpi_cliente;

      -- Verificar si la direccion pertenece al cliente
      SELECT COUNT(*) INTO direccion_existente FROM direccion WHERE id_direccion = p_id_direccion_cliente AND dpi = dpi_cliente;

      -- Obtener la zona y municipio de la direccion
      SELECT zona, municipio INTO direccion_zona, direccion_municipio FROM direccion WHERE id_direccion = p_id_direccion_cliente;

      -- Buscar un restaurante con la misma zona y municipio de la direccion del cliente
      SELECT id_restaurante, zona, municipio INTO restaurante_id, restaurante_zona, restaurante_municipio FROM restaurante WHERE zona = direccion_zona AND municipio = direccion_municipio;

      IF cliente_existente = 0 THEN
         SELECT "Error al registrar orden. El cliente no existe.";
          LEAVE CrearOrden1;
      END IF;

      IF direccion_existente = 0 THEN
         SELECT "Error al registrar orden. La direccion no pertenece al cliente.";
         LEAVE CrearOrden1;
      END IF;
      
      IF canal != 'L' AND canal != 'A' THEN
         SELECT "Error al registrar orden. El canal no es válido.";
          LEAVE CrearOrden1;
      END IF;
      
      
      IF restaurante_id IS NOT NULL THEN
          INSERT INTO orden (id_direccion_cliente, canal, dpi, id_restaurante, fecha_recibido, estado) VALUES (p_id_direccion_cliente, canal, dpi_cliente, restaurante_id, NOW(), 'INICIADA');
          SELECT "Orden creada exitosamente.";
      
      ELSE
          INSERT INTO orden (id_direccion_cliente, canal, dpi, fecha_recibido, estado) VALUES (p_id_direccion_cliente, canal, dpi_cliente, NOW(), 'SIN COBERTURA');
          SELECT "Orden creada exitosamente.";
      
      END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConfirmarOrden(IN IdOrden INT, IN FormaPago CHAR(1), IN IdRepartidor INT)
BEGIN
  DECLARE EstadoActual VARCHAR(255);
  DECLARE restauranteId VARCHAR(255);
  DECLARE repartidorId INT;
  DECLARE clienteNit VARCHAR(255);
  DECLARE montoTotal DECIMAL(10,2);
  DECLARE lugar VARCHAR(255);
  DECLARE noSerie VARCHAR(255);
 
  SELECT estado INTO EstadoActual FROM orden WHERE id_orden = IdOrden;

  SELECT id_restaurante INTO restauranteId FROM orden WHERE id_orden = IdOrden;

  SELECT id_empleado INTO repartidorId FROM empleado 
  WHERE id_empleado = IdRepartidor AND id_restaurante = restauranteId;

  SELECT nit INTO clienteNit FROM cliente WHERE dpi = (SELECT dpi FROM orden WHERE id_orden = IdOrden);

  IF (NOT EXISTS(SELECT id_orden FROM orden WHERE id_orden = IdOrden)) THEN
    SELECT "Error al confirmar orden. La orden especificada no existe";
  ELSEIF (FormaPago != 'E' AND FormaPago != 'T') THEN
    SELECT "Error al confirmar orden. La forma de pago no es válida";
  ELSEIF (NOT EXISTS(SELECT id_empleado FROM empleado WHERE id_empleado = IdRepartidor)) THEN
    SELECT "Error al confirmar orden. El repartidor no existe";
  ELSEIF (repartidorId IS NULL) THEN
    SELECT "Error al confirmar orden. El repartidor no trabaja en el restaurante de la orden";
  ELSEIF EstadoActual != 'AGREGANDO' THEN
    SELECT "Error al confirmar orden. El estado de la orden no es AGREGANDO";
  ELSE
  
    SELECT SUM(item.cantidad * producto.precio) INTO montoTotal FROM item
      INNER JOIN producto ON item.id_producto = producto.id_producto
      WHERE item.id_orden = IdOrden;
    SET montoTotal = montoTotal + (montoTotal * 0.12);

    SELECT municipio INTO lugar FROM direccion WHERE dpi = (SELECT dpi FROM orden WHERE id_orden = IdOrden LIMIT 1) LIMIT 1;

    SELECT CONCAT(YEAR(NOW()), '-', IdOrden) INTO noSerie;
    INSERT INTO factura (no_serie, monto_total, lugar, fecha_actual, nit, forma_pago, id_orden)
    VALUES (noSerie, montoTotal, lugar, NOW(), IFNULL(clienteNit, 'C/F'), IF(FormaPago = 'E', 'Efectivo', 'Tarjeta'), IdOrden);

    -- Actualizar la orden
    UPDATE orden SET estado = 'EN CAMINO', repartidor = IdRepartidor WHERE id_orden = IdOrden;
    SELECT "Orden confirmada exitosamente";
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE FinalizarOrden (IN p_id_orden INT)
FinalizarOrden1:BEGIN
    DECLARE estado_actual VARCHAR(255);
    DECLARE fecha_entrega_actual DATETIME;
    
    -- Verificar si la orden existe y obtener su estado actual y fecha de entrega
    SELECT estado, fecha_entrega INTO estado_actual, fecha_entrega_actual FROM orden WHERE id_orden = p_id_orden;
    IF estado_actual IS NULL THEN
      SELECT "Error al finalizar orden. La orden no existe";
        LEAVE FinalizarOrden1;
    END IF;

    -- Verificar si el estado actual es "EN CAMINO"
    IF estado_actual != 'EN CAMINO' THEN
        SELECT "Error al finalizar orden. El estado actual de la orden no es EN CAMINO";
        LEAVE FinalizarOrden1;
    END IF;

    -- Actualizar el estado de la orden a "ENTREGADA" y establecer la fecha de entrega
    UPDATE orden SET estado = 'ENTREGADA', fecha_entrega = NOW() WHERE id_orden = p_id_orden;
    SELECT "Orden finalizada exitosamente";
END$$
DELIMITER ;