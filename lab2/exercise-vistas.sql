--Ejercicio 1
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria_id INTEGER REFERENCES categorias(id),
    precio NUMERIC(10, 2),
    activo BOOLEAN DEFAULT TRUE
);

INSERT INTO categorias (nombre) VALUES 
('Electrónicos'),
('Ropa'),
('Alimentos');

INSERT INTO productos (nombre, categoria_id, precio, activo) VALUES
('Smartphone', 1, 500.00, TRUE),
('Laptop', 1, 1200.00, TRUE),
('Camiseta', 2, 25.00, TRUE),
('Queso', 3, 5.00, FALSE); 

CREATE OR REPLACE VIEW vista_productos AS
SELECT 
    p.nombre AS nombre_producto,
    c.nombre AS categoria,
    p.precio
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.activo = TRUE;

-- Uso:
SELECT * FROM vista_productos;
SELECT * FROM vista_productos WHERE categoria = 'Electrónicos';


--Ejercicio 2
DROP TABLE empleados CASCADE;
CREATE TABLE IF NOT EXISTS empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    puesto VARCHAR(50),
    salario NUMERIC(10,2),
    departamento VARCHAR(50),
    fecha_ingreso DATE NOT NULL,
    fecha_ultima_actualizacion_salario TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT NOW()
);

INSERT INTO empleados (nombre, apellido, email, telefono, puesto, salario, departamento, fecha_ingreso)
VALUES 
('Carlos', 'López', 'carlos@example.com', '555-1234', 'Vendedor', 2500.00, 'Ventas', '2022-01-10'),
('Ana', 'Martínez', 'ana@example.com', '555-5678', 'Gerente', 5000.00, 'Administración', '2020-08-15'),
('Luis', 'Pérez', 'luis@example.com', '555-9012', 'Soporte', 2000.00, 'IT', '2023-03-20');


CREATE OR REPLACE VIEW empleados_activos AS
SELECT 
    id,
    nombre,
    apellido,
    email,
    telefono,
    puesto,
    salario,
    fecha_ingreso,
    departamento
FROM empleados
WHERE activo = TRUE;

-- Uso:
SELECT * FROM empleados_activos;
SELECT * FROM empleados_activos WHERE departamento = 'Ventas';

--Ejercicio 3
DROP TABLE productos CASCADE;
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10, 2) NOT NULL,
    categoria_id INTEGER,
    activo BOOLEAN DEFAULT TRUE
);

INSERT INTO productos (nombre, precio, categoria_id)
VALUES
('Televisor', 500.00, 1),
('Audífonos', 45.50, 2),
('Mouse', 20.00, 2),
('Licuadora', 80.00, 3),
('Celular', 650.00, 1);


CREATE OR REPLACE VIEW productos_con_iva AS
SELECT 
    nombre AS nombre_producto,
    precio AS precio_sin_iva,
    ROUND(precio * 1.12, 2) AS precio_con_iva,
    ROUND(precio * 0.12, 2) AS monto_iva
FROM productos
WHERE activo = TRUE;

-- Uso:
SELECT * FROM productos_con_iva;
SELECT * FROM productos_con_iva WHERE precio_con_iva > 100;


--Ejercicio 4
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    total NUMERIC(10, 2) NOT NULL,
    fecha_venta DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO clientes (nombre, email) VALUES
('Juan Pérez', 'juan@example.com'),
('Ana Gómez', 'ana@example.com'),
('Luis Torres', 'luis@example.com');

INSERT INTO ventas (cliente_id, total, fecha_venta) VALUES
(1, 150.00, '2024-05-01'),
(1, 200.00, '2024-06-15'),
(2, 300.00, '2024-06-20'),
(1, 50.00, '2024-07-05');

CREATE OR REPLACE VIEW resumen_compras_clientes AS
SELECT 
    c.id AS cliente_id,
    c.nombre AS nombre_cliente,
    c.email,
    COUNT(v.id) AS cantidad_compras,
    COALESCE(SUM(v.total), 0) AS monto_total_acumulado,
    COALESCE(AVG(v.total), 0) AS promedio_por_compra,
    MAX(v.fecha_venta) AS ultima_compra
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
WHERE c.activo = TRUE
GROUP BY c.id, c.nombre, c.email;

-- Uso:
SELECT * FROM resumen_compras_clientes ORDER BY monto_total_acumulado DESC;


--Ejercicio 5
CREATE TABLE categorias_curso (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE profesores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);

DROP TABLE cursos CASCADE; 
CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    categoria_id INTEGER REFERENCES categorias_curso(id),
    profesor_id INTEGER REFERENCES profesores(id),
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    creditos INTEGER,
    duracion_horas INTEGER,
    estado VARCHAR(20),
    fecha_inicio DATE,
    fecha_fin DATE
);

INSERT INTO categorias_curso (nombre) VALUES
('Programación'),
('Matemáticas'),
('Diseño');

INSERT INTO profesores (nombre, email) VALUES
('Juan López', 'juan.lopez@example.com'),
('Ana Martínez', 'ana.martinez@example.com');

INSERT INTO cursos (categoria_id, profesor_id, titulo, descripcion, creditos, duracion_horas, estado, fecha_inicio, fecha_fin)
VALUES
(1, 1, 'Introducción a JavaScript', 'Curso básico de JS', 3, 40, 'ACTIVO', '2025-01-10', '2025-02-10'),
(1, 2, 'Python avanzado', 'Curso avanzado de Python', 4, 50, 'ACTIVO', '2025-03-01', '2025-04-01'),
(2, NULL, 'Álgebra lineal', 'Curso de álgebra', 3, 45, 'INACTIVO', '2024-09-01', '2024-10-01');


CREATE OR REPLACE VIEW cursos_ordenados AS
SELECT 
    cat.nombre AS categoria,
    c.titulo,
    c.descripcion,
    c.creditos,
    c.duracion_horas,
    c.estado,
    c.fecha_inicio,
    c.fecha_fin,
    p.nombre AS profesor
FROM cursos c
JOIN categorias_curso cat ON c.categoria_id = cat.id
LEFT JOIN profesores p ON c.profesor_id = p.id
ORDER BY cat.nombre ASC, c.titulo ASC;

-- Uso:
SELECT categoria, COUNT(*) as total_cursos FROM cursos_ordenados GROUP BY categoria;
