--Ejercicio 1

CREATE OR REPLACE FUNCTION celsius_a_fahrenheit(celsius NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (celsius * 9.0/5.0) + 32;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT celsius_a_fahrenheit(25);


--Ejercicio 2 

CREATE TABLE alumnos (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    creditos INTEGER
);

CREATE TABLE alumnos_cursos (
    alumno_id INTEGER REFERENCES alumnos(id),
    curso_id INTEGER REFERENCES cursos(id),
    PRIMARY KEY (alumno_id, curso_id)
);

INSERT INTO alumnos (nombre) VALUES ('Ana'), ('Luis');

INSERT INTO cursos (nombre, creditos) VALUES 
('Matemáticas', 5),
('Historia', 3),
('Biología', 4);

INSERT INTO alumnos_cursos (alumno_id, curso_id) VALUES
(1, 1),
(1, 2),
(2, 3);

CREATE OR REPLACE FUNCTION cursos_por_alumno(p_alumno_id INTEGER) 
RETURNS TABLE(
    curso_id INTEGER,
    nombre_curso TEXT,
    creditos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.nombre, c.creditos
    FROM cursos c
    JOIN alumnos_cursos ac ON ac.curso_id = c.id
    WHERE ac.alumno_id = p_alumno_id;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT * FROM cursos_por_alumno(1);

--Ejercicio 3

CREATE OR REPLACE FUNCTION calcular_descuento(
    tipo_cliente TEXT,
    monto_compra NUMERIC
)
RETURNS NUMERIC AS $$
DECLARE
    porcentaje_descuento NUMERIC := 0;
BEGIN
    tipo_cliente := UPPER(tipo_cliente);
    
    IF tipo_cliente = 'VIP' THEN
        porcentaje_descuento := 0.20;
    ELSIF tipo_cliente = 'REGULAR' THEN
        porcentaje_descuento := 0.10;
    ELSE
        porcentaje_descuento := 0.00;
    END IF;
    
    RETURN monto_compra * porcentaje_descuento;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT calcular_descuento('VIP', 1000);     -- Devuelve 200
SELECT calcular_descuento('Regular', 500);  -- Devuelve 50
SELECT calcular_descuento('Nuevo', 300);    -- Devuelve 0


--Ejercicio 4

CREATE OR REPLACE FUNCTION clasificar_numero(numero NUMERIC)
RETURNS TEXT AS $$
BEGIN
    IF numero > 0 THEN
        RETURN 'Positivo';
    ELSIF numero < 0 THEN
        RETURN 'Negativo';
    ELSE
        RETURN 'Cero';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT clasificar_numero(15);   -- Devuelve 'Positivo'
SELECT clasificar_numero(-5);   -- Devuelve 'Negativo'
SELECT clasificar_numero(0);    -- Devuelve 'Cero'


--Ejercicio 6 (no habia 5)

CREATE OR REPLACE FUNCTION calcular_comision(
    tipo_producto TEXT,
    monto_venta NUMERIC
)
RETURNS NUMERIC AS $$
DECLARE
    porcentaje_comision NUMERIC := 0;
BEGIN
    tipo_producto := UPPER(tipo_producto);
    
    CASE tipo_producto
        WHEN 'ELECTRONICO' THEN porcentaje_comision := 0.05;  
        WHEN 'ROPA' THEN porcentaje_comision := 0.08;         
        WHEN 'HOGAR' THEN porcentaje_comision := 0.03;        
        WHEN 'DEPORTES' THEN porcentaje_comision := 0.06;     
        ELSE porcentaje_comision := 0.02;                     
    END CASE;
    
    RETURN monto_venta * porcentaje_comision;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT calcular_comision('ELECTRONICO', 1000); -- Devuelve 50
SELECT calcular_comision('ROPA', 500);         -- Devuelve 40


--Ejercicio 7

CREATE OR REPLACE FUNCTION es_año_bisiesto(año INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    IF (año % 400 = 0) THEN
        RETURN TRUE;
    ELSIF (año % 100 = 0) THEN
        RETURN FALSE;
    ELSIF (año % 4 = 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT es_año_bisiesto(2024); -- Devuelve TRUE
SELECT es_año_bisiesto(2023); -- Devuelve FALSE
SELECT es_año_bisiesto(2000); -- Devuelve TRUE
SELECT es_año_bisiesto(1900); -- Devuelve FALSE
 
--Ejercicio 8

CREATE OR REPLACE FUNCTION nombre_mes(numero_mes INTEGER)
RETURNS TEXT AS $$
BEGIN
    CASE numero_mes
        WHEN 1 THEN RETURN 'Enero';
        WHEN 2 THEN RETURN 'Febrero';
        WHEN 3 THEN RETURN 'Marzo';
        WHEN 4 THEN RETURN 'Abril';
        WHEN 5 THEN RETURN 'Mayo';
        WHEN 6 THEN RETURN 'Junio';
        WHEN 7 THEN RETURN 'Julio';
        WHEN 8 THEN RETURN 'Agosto';
        WHEN 9 THEN RETURN 'Septiembre';
        WHEN 10 THEN RETURN 'Octubre';
        WHEN 11 THEN RETURN 'Noviembre';
        WHEN 12 THEN RETURN 'Diciembre';
        ELSE RETURN 'Mes inválido';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT nombre_mes(5);  -- Devuelve 'Mayo'
SELECT nombre_mes(12); -- Devuelve 'Diciembre'


--Ejercicio 9

CREATE OR REPLACE FUNCTION es_mayor_edad(fecha_nacimiento DATE)
RETURNS BOOLEAN AS $$
DECLARE
    edad INTEGER;
BEGIN
    edad := EXTRACT(YEAR FROM AGE(CURRENT_DATE, fecha_nacimiento));
    RETURN edad >= 18;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT es_mayor_edad('1990-05-15'); -- Devuelve TRUE
SELECT es_mayor_edad('2010-05-15'); -- Devuelve FALSE


--Ejercicio 10

CREATE OR REPLACE FUNCTION clasificar_precio(precio NUMERIC)
RETURNS TEXT AS $$
BEGIN
    IF precio < 100 THEN
        RETURN 'Bajo';
    ELSIF precio <= 500 THEN
        RETURN 'Medio';
    ELSE
        RETURN 'Alto';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Uso:
SELECT clasificar_precio(75);   -- Devuelve 'Bajo'
SELECT clasificar_precio(250);  -- Devuelve 'Medio'
SELECT clasificar_precio(750);  -- Devuelve 'Alto'