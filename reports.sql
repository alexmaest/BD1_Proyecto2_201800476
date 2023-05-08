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
CREATE PROCEDURE ConsultarEmpleado(IN p_id_empleado INT)
BEGIN
    DECLARE empleado_existente INT DEFAULT 0;
    DECLARE puesto_empleado VARCHAR(255);
    DECLARE salario_puesto DECIMAL(10,2);
    SELECT COUNT(*) INTO empleado_existente FROM empleado WHERE id_empleado = p_id_empleado;
    
    IF empleado_existente = 0 THEN
      SELECT "El empleado no existe";
    ELSE
        SELECT e.id_empleado, CONCAT(e.nombres, ' ', e.apellidos) AS nombre_completo, e.fecha_nacimiento, e.correo, e.telefono, e.direccion, e.dpi, p.nombre AS nombre_puesto, e.fecha_inicio, pu.salario 
        INTO @id_empleado, @nombre_completo, @fecha_nacimiento, @correo, @telefono, @direccion, @dpi, @nombre_puesto, @fecha_inicio, @salario_puesto
        FROM empleado e
        INNER JOIN puesto p ON e.id_puesto = p.id_puesto
        INNER JOIN puesto pu ON p.id_puesto = pu.id_puesto
        WHERE e.id_empleado = p_id_empleado;
        SELECT @id_empleado AS IdEmpleado, @nombre_completo AS NombreCompleto, @fecha_nacimiento AS FechaNacimiento, @correo AS Correo, @telefono AS Telefono, @direccion AS Direccion, @dpi AS NumeroDPI, @nombre_puesto AS NombrePuesto, @fecha_inicio AS FechaInicio, @salario_puesto AS Salario;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarPedidosCliente(IN IdOrden INT)
BEGIN
  DECLARE estado_actual VARCHAR(255);
  DECLARE existe_orden INT;
  
  -- Verificar si la orden existe
  SELECT COUNT(*) INTO existe_orden FROM orden WHERE id_orden = IdOrden;
  SELECT estado INTO estado_actual FROM orden WHERE id_orden = IdOrden;
  
  IF existe_orden = 0 THEN
    SELECT 'La orden especificada no existe' AS Resultado;
  ELSEIF estado_actual = 'SIN COBERTURA' THEN
    SELECT "El estado de la orden es SIN COBERTURA";
  ELSE
    -- Obtener información de los ítems asociados a la orden
    SELECT producto.nombre AS 'Nombre del Producto', 
           CASE producto.tipo
             WHEN 'C' THEN 'Combo'
             WHEN 'E' THEN 'Extra'
             WHEN 'B' THEN 'Bebida'
             WHEN 'P' THEN 'Postre'
           END AS 'Tipo Producto',
           producto.precio AS 'Precio',
           item.cantidad AS 'Cantidad',
           item.observacion AS 'Observacion'
    FROM item
    INNER JOIN producto ON item.id_producto = producto.id_producto
    WHERE item.id_orden = IdOrden;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarHistorialOrdenes(IN dpi_cliente BIGINT)
BEGIN
  DECLARE existe_dpi INT DEFAULT 0;
  SELECT COUNT(*) INTO existe_dpi FROM cliente WHERE dpi = dpi_cliente;
  
  IF existe_dpi = 0 THEN
    SELECT 'Error: DPI no existe en la tabla cliente' AS resultado;
  ELSE
    SELECT orden.id_orden, orden.fecha_recibido, factura.monto_total, orden.id_restaurante, 
           CONCAT(empleado.nombres, ' ', empleado.apellidos) AS repartidor, direccion.direccion,
           CASE orden.canal
             WHEN 'L' THEN 'Llamada'
             WHEN 'A' THEN 'Aplicación'
             ELSE ''
           END AS canal
      FROM orden
      LEFT JOIN factura ON orden.id_orden = factura.id_orden
      LEFT JOIN empleado ON orden.repartidor = empleado.id_empleado
      LEFT JOIN direccion ON orden.id_direccion_cliente = direccion.id_direccion
     WHERE orden.dpi = dpi_cliente;
  END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarDirecciones(IN dpi_cliente BIGINT)
BEGIN
  DECLARE count INT;

  SELECT COUNT(*) INTO count FROM cliente WHERE dpi = dpi_cliente;

  IF count = 0 THEN
    SELECT 'El DPI del cliente no existe' AS Resultado;
  ELSE
    SELECT DISTINCT direccion, municipio, zona FROM direccion WHERE dpi = dpi_cliente;
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
        WHEN -1 THEN 'SIN COBERTURA'
        ELSE 'Error: El estado no existe'
    END;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ConsultarFacturas(IN dia INT, IN mes INT, IN anio INT)
BEGIN
    SELECT f.no_serie AS 'Número de serie', f.monto_total AS 'Monto total', 
           d.municipio AS 'Municipio', f.fecha_actual AS 'Fecha y hora actual', 
           f.id_orden AS 'IdOrden', f.nit AS 'NIT del cliente', 
           f.forma_pago AS 'Forma de pago' 
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
