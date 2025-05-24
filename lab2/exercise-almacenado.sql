
--Ejercicio 1

CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(20) DEFAULT 'USUARIO',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE insertar_usuario(
    IN p_nombre_usuario VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_nombre_completo VARCHAR(100),
    IN p_password VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    usuario_existente INTEGER;
BEGIN
    -- Verificar si ya existe usuario con mismo nombre o email
    SELECT COUNT(*) INTO usuario_existente
    FROM usuarios 
    WHERE nombre_usuario = p_nombre_usuario OR email = p_email;
    
    IF usuario_existente > 0 THEN
        RAISE NOTICE 'Error: Ya existe un usuario con ese nombre de usuario o correo electrónico';
    ELSE
        -- Insertar nuevo usuario
        INSERT INTO usuarios (nombre_usuario, email, nombre_completo, password, fecha_creacion, activo)
        VALUES (p_nombre_usuario, p_email, p_nombre_completo, p_password, NOW(), TRUE);
        
        RAISE NOTICE 'Usuario % creado exitosamente', p_nombre_usuario;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al crear usuario: %', SQLERRM;
END;
$$;


-- Uso:
CALL insertar_usuario('genlser', 'genlser@email.com', 'Genser Catalan', 'secret');


--Ejercicio 2
DROP TABLE alumnos CASCADE;
CREATE TABLE IF NOT EXISTS alumnos (
    id SERIAL PRIMARY KEY,
    numero_carne VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    estado VARCHAR(30) DEFAULT 'ACTIVO',
    fecha_ingreso DATE DEFAULT CURRENT_DATE,
    fecha_actualizacion TIMESTAMP DEFAULT NOW()
);

INSERT INTO alumnos (numero_carne, nombre, apellido, email, telefono)
VALUES ('2024-001', 'Juan', 'Pérez', 'juan@email.com', '555-1234');


CREATE OR REPLACE PROCEDURE cancelar_matricula(
    IN p_numero_carne VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    estado_actual VARCHAR(20);
BEGIN
    -- Verificar si el alumno existe y obtener su estado
    SELECT estado INTO estado_actual
    FROM alumnos 
    WHERE numero_carne = p_numero_carne;

    IF FOUND THEN
        IF estado_actual = 'ACTIVO' THEN
            -- Actualizar estado a cancelado
            UPDATE alumnos 
            SET estado = 'MATRICULA_CANCELADA',
                fecha_actualizacion = NOW()
            WHERE numero_carne = p_numero_carne;

            RAISE NOTICE 'Matrícula del alumno % cancelada exitosamente', p_numero_carne;
        ELSE
            RAISE NOTICE 'El alumno % ya tiene matrícula cancelada o estado: %', p_numero_carne, estado_actual;
        END IF;
    ELSE
        RAISE NOTICE 'No existe alumno con número de carné: %', p_numero_carne;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al cancelar matrícula: %', SQLERRM;
END;
$$;


-- Uso:
CALL cancelar_matricula('2024-001');


--Ejercicio 3
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

DROP TABLE usuarios CASCADE;
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(20) DEFAULT 'USUARIO',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW()
);

INSERT INTO usuarios (nombre_usuario, email, nombre_completo, password, rol, activo)
VALUES ('admin_user', 'admin@email.com', 'Admin Test', 'admin123', 'ADMINISTRADOR', TRUE);

INSERT INTO empleados (nombre, apellido, email, telefono, puesto, salario, departamento, fecha_ingreso)
VALUES ('Luis', 'Pérez', 'luis.perez@email.com', '5555-5555', 'Contador', 4500.00, 'Contabilidad', CURRENT_DATE);

CREATE OR REPLACE PROCEDURE borrar_registro_con_permisos(
    IN p_usuario_id INTEGER,
    IN p_tabla VARCHAR(50),
    IN p_registro_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    es_admin BOOLEAN := FALSE;
    filas_afectadas INTEGER := 0;
BEGIN
    -- Verificar si el usuario tiene permisos de administrador
    SELECT (rol = 'ADMINISTRADOR') INTO es_admin
    FROM usuarios 
    WHERE id = p_usuario_id AND activo = TRUE;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Usuario no encontrado o inactivo';
        RETURN;
    END IF;
    
    IF es_admin THEN
        -- Eliminar de la tabla permitida según el nombre
        CASE p_tabla
            WHEN 'productos' THEN
                DELETE FROM productos WHERE id = p_registro_id;
                GET DIAGNOSTICS filas_afectadas = ROW_COUNT;
            WHEN 'clientes' THEN
                DELETE FROM clientes WHERE id = p_registro_id;
                GET DIAGNOSTICS filas_afectadas = ROW_COUNT;
            WHEN 'empleados' THEN
                DELETE FROM empleados WHERE id = p_registro_id;
                GET DIAGNOSTICS filas_afectadas = ROW_COUNT;
            ELSE
                RAISE NOTICE 'Tabla no válida: %', p_tabla;
                RETURN;
        END CASE;

        IF filas_afectadas > 0 THEN
            RAISE NOTICE 'Registro % eliminado de tabla % por administrador %', p_registro_id, p_tabla, p_usuario_id;
        ELSE
            RAISE NOTICE 'No se encontró registro % en tabla %', p_registro_id, p_tabla;
        END IF;
    ELSE
        RAISE NOTICE 'Usuario % no tiene permisos de administrador para borrar registros', p_usuario_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al borrar registro: %', SQLERRM;
END;
$$;


-- Uso:
CALL borrar_registro_con_permisos(1, 'empleados', 1);


--Ejercicio 4
DROP TABLE usuarios CASCADE;
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(20) DEFAULT 'USUARIO',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW()
);
INSERT INTO empleados (
    nombre, apellido, email, telefono, puesto, salario, departamento,
    fecha_ingreso, fecha_ultima_actualizacion_salario, activo
)
VALUES (
    'Ana', 'Lopez', 'ana.lopez@email.com', '5555-9999',
    'Analista', 3000.00, 'TI',
    CURRENT_DATE - INTERVAL '2 years', NULL, TRUE
);

CREATE OR REPLACE PROCEDURE actualizar_salario_por_antiguedad(
    IN p_empleado_id INTEGER,
    IN p_nuevo_salario NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    fecha_ingreso DATE;
    dias_antiguedad INTEGER;
    salario_actual NUMERIC;
BEGIN
    -- Obtener fecha de ingreso y salario actual
    SELECT e.fecha_ingreso, e.salario INTO fecha_ingreso, salario_actual
    FROM empleados e
    WHERE e.id = p_empleado_id AND e.activo = TRUE;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Empleado no encontrado o inactivo';
        RETURN;
    END IF;
    
    -- Calcular días de antigüedad
    dias_antiguedad := CURRENT_DATE - fecha_ingreso;
    
    IF dias_antiguedad >= 365 THEN
        -- Actualizar salario
        UPDATE empleados 
        SET salario = p_nuevo_salario,
            fecha_ultima_actualizacion_salario = NOW()
        WHERE id = p_empleado_id;
        
        RAISE NOTICE 'Salario actualizado para empleado %. Anterior: %, Nuevo: %, Antigüedad: % días', 
                     p_empleado_id, salario_actual, p_nuevo_salario, dias_antiguedad;
    ELSE
        RAISE NOTICE 'Empleado % no cumple requisito de antigüedad (% días). Requiere mínimo 365 días', 
                     p_empleado_id, dias_antiguedad;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al actualizar salario: %', SQLERRM;
END;
$$;

-- Uso:
CALL actualizar_salario_por_antiguedad(3, 3500.00);

--Ejercicio 5
DROP TABLE cursos CASCADE;
CREATE TABLE IF NOT EXISTS cursos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado VARCHAR(20) NOT NULL  
);

CREATE TABLE IF NOT EXISTS inscripciones (
    id SERIAL PRIMARY KEY,
    estudiante_id INTEGER NOT NULL,
    curso_id INTEGER NOT NULL,
    fecha_inscripcion TIMESTAMP NOT NULL,
    estado VARCHAR(20) NOT NULL,  
    UNIQUE(estudiante_id, curso_id)
);

INSERT INTO cursos (nombre, estado) VALUES ('Matemáticas Avanzadas', 'ACTIVO');

INSERT INTO cursos (nombre, estado) VALUES ('Historia del Arte', 'INACTIVO');


CREATE OR REPLACE PROCEDURE insertar_inscripcion(
    IN p_estudiante_id INTEGER,
    IN p_curso_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    curso_activo BOOLEAN := FALSE;
    nombre_curso VARCHAR(100);
    ya_inscrito BOOLEAN := FALSE;
BEGIN
    -- Verificar si el curso está activo
    SELECT (estado = 'ACTIVO'), nombre INTO curso_activo, nombre_curso
    FROM cursos 
    WHERE id = p_curso_id;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Curso con ID % no encontrado', p_curso_id;
        RETURN;
    END IF;
    
    IF NOT curso_activo THEN
        RAISE NOTICE 'No se puede inscribir en el curso %. Estado: INACTIVO', nombre_curso;
        RETURN;
    END IF;
    
    -- Verificar si ya está inscrito
    SELECT TRUE INTO ya_inscrito
    FROM inscripciones 
    WHERE estudiante_id = p_estudiante_id AND curso_id = p_curso_id;
    
    IF ya_inscrito THEN
        RAISE NOTICE 'El estudiante ya está inscrito en el curso %', nombre_curso;
        RETURN;
    END IF;
    
    -- Insertar inscripción
    INSERT INTO inscripciones (estudiante_id, curso_id, fecha_inscripcion, estado)
    VALUES (p_estudiante_id, p_curso_id, NOW(), 'ACTIVA');
    
    RAISE NOTICE 'Estudiante % inscrito exitosamente en curso %', p_estudiante_id, nombre_curso;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al insertar inscripción: %', SQLERRM;
END;
$$;

-- Uso:
CALL insertar_inscripcion(1, 1);