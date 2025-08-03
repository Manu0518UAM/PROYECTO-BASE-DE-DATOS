CREATE DATABASE tienda_digital;
USE tienda_digital;

CREATE TABLE Clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  correo_electronico VARCHAR(100) UNIQUE,
  direccion VARCHAR(200),
  numero_telefono VARCHAR(30)
);

CREATE TABLE Categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(200),
  descripcion VARCHAR(500)
);

CREATE TABLE Productos (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  descripcion VARCHAR(500),
  precio DECIMAL(10, 2),
  stock INT,
  id_categoria INT,
  FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE TABLE Pedidos (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT,
  estado VARCHAR(50),
  fecha_pedido DATE,
  FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

CREATE TABLE Detalles_Pedido (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT,
  id_producto INT,
  cantidad INT,
  FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
  FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Resenas (
  id_resena INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT,
  id_producto INT,
  calificacion INT,
  comentario VARCHAR(500),
  FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
  FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE INDEX idx_nombre ON Productos(nombre);
CREATE INDEX idx_categoria ON Productos(id_categoria);
CREATE INDEX idx_cliente ON Pedidos(id_cliente);
