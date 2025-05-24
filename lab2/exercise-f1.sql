CREATE TABLE pilotos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    equipo VARCHAR(100)
);

CREATE TABLE carreras (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE resultados (
    id SERIAL PRIMARY KEY,
    piloto_id INTEGER REFERENCES pilotos(id),
    carrera_id INTEGER REFERENCES carreras(id),
    posicion INTEGER CHECK (posicion > 0),
    puntos INTEGER DEFAULT 0
);


INSERT INTO pilotos (nombre, apellido, nacionalidad, equipo) VALUES
('Max', 'Verstappen', 'Países Bajos', 'Red Bull Racing'),
('Lewis', 'Hamilton', 'Reino Unido', 'Mercedes'),
('Charles', 'Leclerc', 'Mónaco', 'Ferrari'),
('George', 'Russell', 'Reino Unido', 'Mercedes'),
('Carlos', 'Sainz', 'España', 'Ferrari'),
('Lando', 'Norris', 'Reino Unido', 'McLaren'),
('Oscar', 'Piastri', 'Australia', 'McLaren'),
('Fernando', 'Alonso', 'España', 'Aston Martin');

INSERT INTO carreras (nombre, pais, fecha, circuito) VALUES
('Gran Premio de Bahrein', 'Bahrein', '2024-03-02', 'Circuito Internacional de Bahrein'),
('Gran Premio de Arabia Saudí', 'Arabia Saudí', '2024-03-09', 'Circuito Callejero de Jeddah'),
('Gran Premio de Australia', 'Australia', '2024-03-24', 'Circuito de Albert Park'),
('Gran Premio de Japón', 'Japón', '2024-04-07', 'Circuito de Suzuka'),
('Gran Premio de China', 'China', '2024-04-21', 'Circuito Internacional de Shanghái'),
('Gran Premio de Miami', 'Estados Unidos', '2024-05-05', 'Circuito Internacional de Miami');

-- Función para calcular puntos según posición
CREATE OR REPLACE FUNCTION calcular_puntos(pos INTEGER)
RETURNS INTEGER AS $$
BEGIN
    CASE pos
        WHEN 1 THEN RETURN 25;
        WHEN 2 THEN RETURN 18;
        WHEN 3 THEN RETURN 15;
        WHEN 4 THEN RETURN 12;
        WHEN 5 THEN RETURN 10;
        WHEN 6 THEN RETURN 8;
        WHEN 7 THEN RETURN 6;
        WHEN 8 THEN RETURN 4;
        WHEN 9 THEN RETURN 2;
        WHEN 10 THEN RETURN 1;
        ELSE RETURN 0;
    END CASE;
END;
$$ LANGUAGE plpgsql;

INSERT INTO resultados (piloto_id, carrera_id, posicion, puntos) VALUES
-- Bahrein
(1, 1, 1, calcular_puntos(1)), -- Verstappen 
(3, 1, 2, calcular_puntos(2)), -- Leclerc 
(6, 1, 3, calcular_puntos(3)), -- Norris 
(2, 1, 4, calcular_puntos(4)), -- Hamilton 
(4, 1, 5, calcular_puntos(5)), -- Russell 
(5, 1, 6, calcular_puntos(6)), -- Sainz 
(7, 1, 7, calcular_puntos(7)), -- Piastri 
(8, 1, 8, calcular_puntos(8)), -- Alonso 

-- Arabia Saudí
(1, 2, 1, calcular_puntos(1)), -- Verstappen 
(7, 2, 2, calcular_puntos(2)), -- Piastri 
(3, 2, 3, calcular_puntos(3)), -- Leclerc 
(8, 2, 4, calcular_puntos(4)), -- Alonso 
(4, 2, 5, calcular_puntos(5)), -- Russell 
(6, 2, 6, calcular_puntos(6)), -- Norris 
(2, 2, 7, calcular_puntos(7)), -- Hamilton 
(5, 2, 8, calcular_puntos(8)), -- Sainz 

-- Australia
(5, 3, 1, calcular_puntos(1)), -- Sainz 
(3, 3, 2, calcular_puntos(2)), -- Leclerc 
(6, 3, 3, calcular_puntos(3)), -- Norris 
(7, 3, 4, calcular_puntos(4)), -- Piastri 
(1, 3, 5, calcular_puntos(5)), -- Verstappen 
(2, 3, 6, calcular_puntos(6)), -- Hamilton 
(4, 3, 7, calcular_puntos(7)), -- Russell 
(8, 3, 8, calcular_puntos(8)), -- Alonso 

-- Japon
(1, 4, 1, calcular_puntos(1)), -- Verstappen 
(7, 4, 2, calcular_puntos(2)), -- Piastri 
(5, 4, 3, calcular_puntos(3)), -- Sainz 
(3, 4, 4, calcular_puntos(4)), -- Leclerc 
(6, 4, 5, calcular_puntos(5)), -- Norris 
(2, 4, 6, calcular_puntos(6)), -- Hamilton 
(8, 4, 7, calcular_puntos(7)), -- Alonso 
(4, 4, 8, calcular_puntos(8)), -- Russell 

-- China
(6, 5, 1, calcular_puntos(1)), -- Norris 
(1, 5, 2, calcular_puntos(2)), -- Verstappen 
(7, 5, 3, calcular_puntos(3)), -- Piastri 
(3, 5, 4, calcular_puntos(4)), -- Leclerc 
(5, 5, 5, calcular_puntos(5)), -- Sainz 
(2, 5, 6, calcular_puntos(6)), -- Hamilton 
(4, 5, 7, calcular_puntos(7)), -- Russell 
(8, 5, 8, calcular_puntos(8)), -- Alonso 

-- Miami
(1, 6, 1, calcular_puntos(1)), -- Verstappen 
(6, 6, 2, calcular_puntos(2)), -- Norris 
(3, 6, 3, calcular_puntos(3)), -- Leclerc 
(5, 6, 4, calcular_puntos(4)), -- Sainz 
(7, 6, 5, calcular_puntos(5)), -- Piastri 
(8, 6, 6, calcular_puntos(6)), -- Alonso 
(2, 6, 7, calcular_puntos(7)), -- Hamilton 
(4, 6, 8, calcular_puntos(8)); -- Russell 


--Puntos por piloto
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) AS piloto,
    p.equipo,
    SUM(r.puntos) AS total_puntos
FROM pilotos p
JOIN resultados r ON p.id = r.piloto_id
GROUP BY p.id, p.nombre, p.apellido, p.equipo
ORDER BY total_puntos DESC;

--Suma total puntos
SELECT SUM(puntos) AS suma_total_puntos
FROM resultados;


--Puntos por piloto
SELECT DISTINCT
    CONCAT(p.nombre, ' ', p.apellido) AS piloto,
    p.equipo,
    SUM(r.puntos) OVER (PARTITION BY p.id) AS total_puntos
FROM pilotos p
JOIN resultados r ON p.id = r.piloto_id
ORDER BY total_puntos DESC;

--4 Mejores resultados
WITH mejores_resultados AS (
    SELECT 
        piloto_id,
        puntos,
        ROW_NUMBER() OVER (PARTITION BY piloto_id ORDER BY puntos DESC) as ranking_resultado
    FROM resultados
    WHERE puntos > 0
)
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) AS piloto,
    p.equipo,
    SUM(mr.puntos) AS puntos_4_mejores
FROM pilotos p
JOIN mejores_resultados mr ON p.id = mr.piloto_id
WHERE mr.ranking_resultado <= 4
GROUP BY p.id, p.nombre, p.apellido, p.equipo
ORDER BY puntos_4_mejores DESC;
