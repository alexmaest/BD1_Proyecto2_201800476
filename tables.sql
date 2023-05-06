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
  id_producto VARCHAR(2) NOT NULL,
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
