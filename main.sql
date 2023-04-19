CREATE TABLE producto (
  id_producto VARCHAR(2) PRIMARY KEY,
  tipo CHAR(1) NOT NULL,
  numero INT NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  precio DECIMAL(10,2) NOT NULL
);

CREATE TABLE factura (
  no_serie VARCHAR(255) PRIMARY KEY,
  monto_total INT NOT NULL,
  lugar VARCHAR(255) NOT NULL,
  fecha_actual DATETIME NOT NULL,
  nit INT NOT NULL,
  forma_pago CHAR(1) NOT NULL,
  id_orden int NOT NULL,
  FOREIGN KEY (id_orden) REFERENCES orden(id_orden)
);

CREATE TABLE puesto (
  id_puesto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  descripcion VARCHAR(255) NOT NULL,
  salario DECIMAL(10,2) NOT NULL
);

CREATE TABLE cliente (
  dpi BIGINT PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  apellidos VARCHAR(255) NOT NULL,
  fecha_nacimiento DATETIME NOT NULL,
  correo VARCHAR(255) NOT NULL,
  telefono INT NOT NULL,
  nit INT
);

CREATE TABLE restaurante (
  id_restaurante VARCHAR(255) PRIMARY KEY,
  direccion VARCHAR(255) NOT NULL,
  municipio VARCHAR(255) NOT NULL,
  zona INT NOT NULL,
  telefono INT NOT NULL,
  personal INT NOT NULL,
  tiene_parqueo BOOLEAN NOT NULL
);

CREATE TABLE item (
  id_item INT AUTO_INCREMENT PRIMARY KEY,
  tipo_producto CHAR NOT NULL,
  producto INT NOT NULL,
  cantidad INT NOT NULL,
  observacion VARCHAR(255),
  id_orden INT NOT NULL,
  id_producto INT NOT NULL,
  FOREIGN KEY (id_orden) REFERENCES orden(id_orden),
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

CREATE TABLE direccion (
  id_direccion INT AUTO_INCREMENT PRIMARY KEY,
  direccion VARCHAR(255) NOT NULL,
  municipio VARCHAR(255) NOT NULL,
  zona INT NOT NULL,
  dpi BIGINT NOT NULL,
  FOREIGN KEY (dpi) REFERENCES cliente(dpi)
);

CREATE TABLE empleado (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(255) NOT NULL,
  apellidos VARCHAR(255) NOT NULL,
  fecha_nacimiento DATETIME NOT NULL,
  correo VARCHAR(255) NOT NULL,
  telefono INT NOT NULL,
  direccion VARCHAR(255) NOT NULL,
  dpi BIGINT NOT NULL,
  fecha_inicio DATETIME NOT NULL,
  id_puesto INT NOT NULL,
  id_restaurante VARCHAR(255) NOT NULL,
  FOREIGN KEY (id_puesto) REFERENCES puesto(id_puesto),
  FOREIGN KEY (id_restaurante) REFERENCES restaurante(id_restaurante)
);

CREATE TABLE orden (
  id_orden INT AUTO_INCREMENT PRIMARY KEY,
  id_direccion_cliente INT,
  repartidor INT,
  fecha_recibido DATETIME NOT NULL,
  fecha_entrega DATETIME,
  estado VARCHAR(255) NOT NULL,
  canal CHAR NOT NULL,
  dpi BIGINT,
  id_restaurante VARCHAR(255),
  FOREIGN KEY (dpi) REFERENCES cliente(dpi),
  FOREIGN KEY (id_restaurante) REFERENCES restaurante(id_restaurante)
);

CREATE PROCEDURE RegistrarRestaurante(
  IN p_id_restaurante VARCHAR(255),
  IN p_direccion VARCHAR(255),
  IN p_municipio VARCHAR(255),DECIMAL(10,2)
  IN p_zona INT,
  IN p_telefono INT,
  IN p_personal INT,
  IN p_tiene_parqueo INT
)
BEGIN
  INSERT INTO restaurante (id_restaurante, direccion, municipio, zona, telefono, personal, tiene_parqueo) 
  VALUES (
    p_id_restaurante,
    p_direccion,
    p_municipio,
    IF(ABS(p_zona) = p_zona, p_zona, NULL),
    p_telefono,
    p_personal,
    CASE p_tiene_parqueo
      WHEN 0 THEN FALSE
      WHEN 1 THEN TRUE
      ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El valor de tiene_parqueo no es valido';
        RETURN;
    END
  );
END;

CREATE PROCEDURE RegistrarPuesto(IN p_nombre VARCHAR(255), IN p_descripcion VARCHAR(255), IN p_salario DECIMAL(10,2))
BEGIN
    IF p_salario < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El salario no puede ser negativo';
        RETURN;
    ELSE
        INSERT INTO puesto(nombre, descripcion, salario) VALUES (p_nombre, p_descripcion, p_salario);
    END IF;
END;

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
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DPI ya existe en la tabla cliente';
    RETURN;
  ELSEIF p_correo NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo no es un formato válido';
    RETURN;
  ELSE
    INSERT INTO cliente (dpi, nombre, apellidos, fecha_nacimiento, correo, telefono, nit) 
    VALUES (p_dpi, p_nombre, p_apellidos, p_fecha_nacimiento, p_correo, p_telefono, p_nit);
  END IF;
END;

CREATE PROCEDURE RegistrarDireccion (IN dpi_cliente BIGINT, IN direccion VARCHAR(255), IN municipio VARCHAR(255), IN zona INT)
BEGIN
  DECLARE cliente_existente INT;
  SELECT COUNT(*) INTO cliente_existente FROM cliente WHERE dpi = dpi_cliente;
  IF cliente_existente = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El cliente no existe';
    RETURN;
  END IF;

  IF zona <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La zona debe ser un entero positivo';
    RETURN;
  END IF;

  INSERT INTO direccion (direccion, municipio, zona, dpi) VALUES (direccion, municipio, zona, dpi_cliente);
END;

CREATE PROCEDURE CrearEmpleado(
  IN nombres VARCHAR(255), 
  IN apellidos VARCHAR(255), 
  IN fecha_nacimiento DATETIME, 
  IN correo VARCHAR(255), 
  IN telefono INT, 
  IN direccion VARCHAR(255), 
  IN dpi BIGINT, 
  IN id_puesto INT, 
  IN fecha_inicio DATETIME, 
  IN id_restaurante VARCHAR(255)
)
BEGIN
  DECLARE id_empleado VARCHAR(8);
  
  -- Verificar que el puesto exista
  SELECT COUNT(*) INTO @puesto_existente FROM puesto WHERE id_puesto = id_puesto;
  
  IF @puesto_existente = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El puesto especificado no existe';
      RETURN;
  END IF;
  
  -- Verificar que el restaurante exista
  SELECT COUNT(*) INTO @restaurante_existente FROM restaurante WHERE id_restaurante = id_restaurante;
  
  IF @restaurante_existente = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El restaurante especificado no existe';
      RETURN;
  END IF;
  
  -- Generar el identificador del empleado
  SELECT LPAD(COUNT(*)+1, 8, '0') INTO id_empleado FROM empleado;
  
  -- Insertar el empleado
  INSERT INTO empleado (id_empleado, nombres, apellidos, fecha_nacimiento, correo, telefono, direccion, dpi, fecha_inicio, id_puesto, id_restaurante) 
  VALUES (id_empleado, nombres, apellidos, fecha_nacimiento, correo, telefono, direccion, dpi, fecha_inicio, id_puesto, id_restaurante);
END;

CREATE PROCEDURE CrearOrden (IN dpi_cliente BIGINT, IN id_direccion_cliente INT, IN canal CHAR)
BEGIN
    DECLARE direccion_zona INT;
    DECLARE direccion_municipio VARCHAR(255);
    DECLARE restaurante_zona INT;
    DECLARE restaurante_municipio VARCHAR(255);
    DECLARE restaurante_id VARCHAR(255);
    DECLARE cliente_existente INT;
    DECLARE direccion_existente INT;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existente FROM cliente WHERE dpi = dpi_cliente;
    IF cliente_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El cliente no existe';
        RETURN;
    END IF;

    -- Verificar si la direccion pertenece al cliente
    SELECT COUNT(*) INTO direccion_existente FROM direccion WHERE id_direccion = id_direccion_cliente AND dpi = dpi_cliente;
    IF direccion_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La direccion no pertenece al cliente';
        RETURN;
    END IF;

    -- Verificar si el canal es válido
    IF canal != 'L' AND canal != 'A' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El canal no es válido';
        RETURN;
    END IF;

    -- Obtener la zona y municipio de la direccion
    SELECT zona, municipio INTO direccion_zona, direccion_municipio FROM direccion WHERE id_direccion = id_direccion_cliente;

    -- Buscar un restaurante con la misma zona y municipio de la direccion del cliente
    SELECT id_restaurante, zona, municipio INTO restaurante_id, restaurante_zona, restaurante_municipio FROM restaurante WHERE zona = direccion_zona AND municipio = direccion_municipio;

    -- Si se encontró un restaurante, crear la orden
    IF restaurante_id IS NOT NULL THEN
        INSERT INTO orden (id_direccion_cliente, canal, dpi, id_restaurante, fecha_recibido, estado) VALUES (id_direccion_cliente, canal, dpi_cliente, restaurante_id, NOW(), 'INICIADA');
        SELECT LAST_INSERT_ID() AS id_orden;
    ELSE
        INSERT INTO orden (id_direccion_cliente, canal, dpi, fecha_recibido, estado) VALUES (id_direccion_cliente, canal, dpi_cliente, NOW(), 'SIN COBERTURA');
        SELECT LAST_INSERT_ID() AS id_orden;
        RETURN;
    END IF;
    
END;

CREATE PROCEDURE FinalizarOrden (IN id_orden INT)
BEGIN
    DECLARE estado_actual VARCHAR(255);
    DECLARE fecha_entrega_actual DATETIME;
    
    -- Verificar si la orden existe y obtener su estado actual y fecha de entrega
    SELECT estado, fecha_entrega INTO estado_actual, fecha_entrega_actual FROM orden WHERE id_orden = id_orden;
    IF estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La orden no existe';
        RETURN;
    END IF;

    -- Verificar si el estado actual es "EN CAMINO"
    IF estado_actual <> 'EN CAMINO' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La orden no se puede finalizar porque su estado actual no es "EN CAMINO"';
        RETURN;
    END IF;

    -- Actualizar el estado de la orden a "ENTREGADA" y establecer la fecha de entrega
    UPDATE orden SET estado = 'ENTREGADA', fecha_entrega = NOW() WHERE id_orden = id_orden;
END;

CREATE PROCEDURE AgregarItem(
  IN IdOrden INT,
  IN TipoProducto CHAR(1),
  IN Producto INT,
  IN Cantidad INT,
  IN Observacion VARCHAR(255)
)
BEGIN
  DECLARE EstadoActual VARCHAR(255);
  DECLARE ProductoExistente INT;
  
  SELECT estado INTO EstadoActual FROM orden WHERE id_orden = IdOrden;
  
  IF EstadoActual != 'INICIADA' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No se puede agregar un item a una orden que no está en estado "INICIADA".';
      RETURN;
  END IF;
  
  SELECT COUNT(*) INTO ProductoExistente FROM producto WHERE numero = Producto AND tipo = TipoProducto;
  
  IF ProductoExistente = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El producto indicado no existe.';
      RETURN;
  END IF;
  
  IF Cantidad <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La cantidad debe ser un entero positivo.';
      RETURN;
  END IF;
  
  UPDATE orden SET estado = 'AGREGANDO' WHERE id_orden = IdOrden;
  
  INSERT INTO item (tipo_producto, producto, cantidad, observacion, id_orden, id_producto)
  SELECT TipoProducto, Producto, Cantidad, Observacion, IdOrden, id_producto
  FROM producto
  WHERE tipo = TipoProducto AND numero = Producto;
END;

CREATE PROCEDURE ConfirmarOrden(IN IdOrden INT, IN FormaPago CHAR(1), IN IdRepartidor INT)
BEGIN
  DECLARE restauranteId VARCHAR(255);
  DECLARE repartidorId INT;
  SELECT id_restaurante INTO restauranteId FROM orden WHERE id_orden = IdOrden;
  SELECT id_empleado INTO repartidorId FROM empleado 
    WHERE id_restaurante = restauranteId 
    AND id_puesto = (SELECT id_puesto FROM puesto WHERE nombre = 'repartidor')
    LIMIT 1;
  IF (NOT EXISTS(SELECT id_orden FROM orden WHERE id_orden = IdOrden AND estado = 'EN CAMINO')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden no existe o su estado no es EN CAMINO';
    RETURN;
  ELSEIF (FormaPago <> 'E' AND FormaPago <> 'T') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La forma de pago no es válida';
    RETURN;
  ELSEIF (NOT EXISTS(SELECT id_empleado FROM empleado WHERE id_empleado = IdRepartidor)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El repartidor no existe';
    RETURN;
  ELSEIF (repartidorId <> IdRepartidor) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El repartidor no trabaja en el restaurante de la orden o no es repartidor';
    RETURN;
  ELSE
    UPDATE orden SET estado = 'CONFIRMADA', forma_pago = FormaPago, repartidor = IdRepartidor WHERE id_orden = IdOrden;
  END IF;
END;

INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("C1", "C", 1, "Cheeseburger", 41.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("C2", "C", 2, "Chicken Sandwinch", 32.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("C3", "C", 3, "BBQ Ribs", 54.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("C4", "C", 4, "Pasta Alfredo", 47.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("C5", "C", 5, "Pizza Espinator", 85.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("C6", "C", 6, "Buffalo Wings", 36.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("E1", "E", 1, "Papas fritas", 15.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("E2", "E", 2, "Aros de cebolla", 17.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("E3", "E", 3, "Coleslaw", 12.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("B1", "B", 1, "Coca-Cola", 12.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("B2", "B", 2, "Fanta", 12.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("B3", "B", 3, "Sprite", 12.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("B4", "B", 4, "Té frío", 12.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("B5", "B", 5, "Cerveza de barril", 18.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("P1", "P", 1, "Copa de helado", 13.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("P2", "P", 2, "Cheesecake", 15.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("P3", "P", 3, "Cupcake de chocolate", 8.00);
INSERT INTO producto (id_producto, tipo, numero, nombre, precio) VALUES ("P4", "P", 4, "Flan", 10.00);
