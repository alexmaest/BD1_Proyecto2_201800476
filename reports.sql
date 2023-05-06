DELIMITER $$
CREATE PROCEDURE ListarRestaurantes()
BEGIN
    SELECT 
        id_restaurante, 
        direccion, 
        municipio, 
        zona, 
        telefono, 
        personal, 
        CASE WHEN tiene_parqueo = 1 THEN 'Sí' ELSE 'No' END AS tiene_parqueo
    FROM 
        restaurante;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarEmpleado(IN id_empleado INT)
BEGIN
    DECLARE empleado_existente INT DEFAULT 0;
    DECLARE puesto_empleado VARCHAR(255);
    DECLARE salario_puesto DECIMAL(10,2);
    SELECT COUNT(*) INTO empleado_existente FROM empleado WHERE id_empleado = id_empleado;
    
    IF empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no existe';
    ELSE
        SELECT e.id_empleado, CONCAT(e.nombres, ' ', e.apellidos) AS nombre_completo, e.fecha_nacimiento, e.correo, e.telefono, e.direccion, e.dpi, p.nombre AS nombre_puesto, e.fecha_inicio, pu.salario 
        INTO @id_empleado, @nombre_completo, @fecha_nacimiento, @correo, @telefono, @direccion, @dpi, @nombre_puesto, @fecha_inicio, @salario_puesto
        FROM empleado e
        INNER JOIN puesto p ON e.id_puesto = p.id_puesto
        INNER JOIN puesto pu ON p.id_puesto = pu.id_puesto
        WHERE e.id_empleado = id_empleado;
        SELECT @id_empleado AS IdEmpleado, @nombre_completo AS NombreCompleto, @fecha_nacimiento AS FechaNacimiento, @correo AS Correo, @telefono AS Telefono, @direccion AS Direccion, @dpi AS NumeroDPI, @nombre_puesto AS NombrePuesto, @fecha_inicio AS FechaInicio, @salario_puesto AS Salario;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarPedidosCliente(IN cliente_dpi BIGINT)
BEGIN
    SELECT producto.nombre AS NombreProducto,
           CASE producto.tipo 
              WHEN 'C' THEN 'Combo' 
              WHEN 'E' THEN 'Extra' 
              WHEN 'B' THEN 'Bebida'
              WHEN 'P' THEN 'Postre' 
           END AS TipoProducto,
           producto.precio AS Precio,
           item.cantidad AS Cantidad,
           IFNULL(item.observacion, '') AS Observacion
    FROM orden 
    JOIN item ON orden.id_orden = item.id_orden
    JOIN producto ON item.id_producto = producto.id_producto
    WHERE orden.dpi = cliente_dpi;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarHistorialOrdenes(IN dpi_cliente BIGINT)
BEGIN
  DECLARE monto_total DECIMAL(10,2);
  SELECT COUNT(*) INTO @count FROM cliente WHERE dpi = dpi_cliente;
  IF @count = 0 THEN
    SELECT 'Error: DPI de cliente no existe' AS Resultado;
  ELSE
    SELECT o.id_orden, o.fecha_entrega, f.monto_total, o.id_restaurante, CONCAT(e.nombres, ' ', e.apellidos) AS repartidor, r.direccion AS direccion_envio, 
    CASE o.canal
      WHEN 'L' THEN 'Llamada'
      WHEN 'A' THEN 'Aplicación'
    END AS canal
    FROM orden o
    JOIN factura f ON f.id_orden = o.id_orden
    JOIN empleado e ON e.id_empleado = o.repartidor
    JOIN restaurante r ON r.id_restaurante = o.id_restaurante
    WHERE o.dpi = dpi_cliente;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarDirecciones(IN dpi_cliente BIGINT)
BEGIN
  DECLARE direccion_cliente VARCHAR(255);
  DECLARE municipio_cliente VARCHAR(255);
  DECLARE zona_cliente INT;
  
  SELECT direccion, municipio, zona INTO direccion_cliente, municipio_cliente, zona_cliente
  FROM direccion
  WHERE dpi = dpi_cliente;
  
  IF direccion_cliente IS NULL THEN
    SELECT "El DPI ingresado no existe en la base de datos.";
  ELSE
    SELECT direccion_cliente AS Direccion, municipio_cliente AS Municipio, zona_cliente AS Zona;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE MostrarOrdenes(IN estado INT)
BEGIN
    SELECT o.id_orden, o.estado, o.fecha_recibido, o.dpi, d.direccion, r.id_restaurante,
        CASE o.canal WHEN 'L' THEN 'Llamada' WHEN 'A' THEN 'Aplicación' ELSE 'Desconocido' END AS canal
    FROM orden o
    LEFT JOIN direccion d ON o.id_direccion_cliente = d.id_direccion
    LEFT JOIN restaurante r ON o.id_restaurante = r.id_restaurante
    WHERE o.estado = CASE estado
        WHEN 1 THEN 'INICIADA'
        WHEN 2 THEN 'AGREGANDO'
        WHEN 3 THEN 'EN CAMINO'
        WHEN 4 THEN 'ENTREGADA'
        ELSE 'SIN COBERTURA'
    END;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarFacturas(IN dia INT, IN mes INT, IN anio INT)
BEGIN
    SELECT f.no_serie AS 'Número de serie', f.monto_total AS 'Monto total de la factura', 
           d.municipio AS 'Lugar (municipio)', f.fecha_actual AS 'Fecha y hora actual de la factura', 
           f.id_orden AS 'IdOrden', f.nit AS 'NIT del cliente', 
           CASE f.forma_pago WHEN 'E' THEN 'Efectivo' WHEN 'T' THEN 'Tarjeta' END AS 'Forma de pago'
    FROM factura f
    INNER JOIN orden o ON f.id_orden = o.id_orden
    INNER JOIN direccion d ON o.id_direccion_cliente = d.id_direccion
    WHERE DAY(f.fecha_actual) = dia AND MONTH(f.fecha_actual) = mes AND YEAR(f.fecha_actual) = anio;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarTiempos(IN minutos INT)
BEGIN
  SELECT o.id_orden AS IdOrden, d.direccion AS DireccionEntrega, o.fecha_recibido AS FechaIniciada, 
    TIMESTAMPDIFF(MINUTE, o.fecha_recibido, o.fecha_entrega) AS TiempoEspera, 
    CONCAT(e.nombres, ' ', e.apellidos) AS Repartidor 
  FROM orden o 
  JOIN direccion d ON o.id_direccion_cliente = d.id_direccion 
  JOIN empleado e ON o.repartidor = e.id_empleado 
  WHERE o.fecha_entrega IS NOT NULL AND TIMESTAMPDIFF(MINUTE, o.fecha_recibido, o.fecha_entrega) >= minutos;
END$$
DELIMITER ;

