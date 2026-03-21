-- =============================================================
-- DB Learning Lab — Ejercicio 1: SELECT básico
-- Nivel: Principiante
-- Motores: MariaDB, PostgreSQL, Firebird (sintaxis idéntica)
-- =============================================================
-- Esquema de referencia:
--   alumnos(id, nombre, apellido, email, fecha_nac, ciudad)
--   cursos(id, nombre, descripcion, creditos)
--   matriculas(id, alumno_id, curso_id, fecha_alta)
--   notas(id, matricula_id, evaluacion, nota)
-- =============================================================

-- -------------------------------------------------------------
-- 1. Ver todos los alumnos
-- -------------------------------------------------------------
SELECT * FROM alumnos;

-- SOLUCIÓN: devuelve las 8 filas con todas las columnas.
-- Observa que 'email' tiene NULL en dos filas (Pedro y Laura).


-- -------------------------------------------------------------
-- 2. Ver solo nombre y apellido, ordenados por apellido
-- -------------------------------------------------------------
SELECT nombre, apellido FROM alumnos ORDER BY apellido;

-- SOLUCIÓN: proyección de columnas + ORDER BY.


-- -------------------------------------------------------------
-- 3. Alumnos de Sevilla
-- -------------------------------------------------------------
SELECT nombre, apellido, ciudad
FROM alumnos
WHERE ciudad = 'Sevilla';

-- SOLUCIÓN: Carlos Sánchez y Laura Moreno.


-- -------------------------------------------------------------
-- 4. Alumnos cuyo apellido empiece por 'M'
-- -------------------------------------------------------------
SELECT nombre, apellido
FROM alumnos
WHERE apellido LIKE 'M%';

-- SOLUCIÓN: Martínez, Moreno (y Fernández NO — empieza por F).


-- -------------------------------------------------------------
-- 5. Cursos con más de 3 créditos
-- -------------------------------------------------------------
SELECT nombre, creditos
FROM cursos
WHERE creditos > 3
ORDER BY creditos DESC;

-- SOLUCIÓN: Bases de Datos I (4) y Matemáticas I (4).


-- -------------------------------------------------------------
-- 6. Los 3 primeros alumnos ordenados por fecha de nacimiento
-- -------------------------------------------------------------
-- MariaDB / PostgreSQL:
SELECT nombre, apellido, fecha_nac
FROM alumnos
WHERE fecha_nac IS NOT NULL
ORDER BY fecha_nac
LIMIT 3;

-- Firebird (no existe LIMIT):
-- SELECT FIRST 3 nombre, apellido, fecha_nac
-- FROM alumnos
-- WHERE fecha_nac IS NOT NULL
-- ORDER BY fecha_nac;

-- SOLUCIÓN: Luis (2004), Ana (2005-03), Pedro (2005-06).
-- ¿Por qué filtramos con IS NOT NULL? Laura no tiene fecha_nac.


-- -------------------------------------------------------------
-- 7. Valores únicos de ciudad
-- -------------------------------------------------------------
SELECT DISTINCT ciudad
FROM alumnos
ORDER BY ciudad;

-- SOLUCIÓN: 5 ciudades. Madrid y Sevilla aparecen 2 veces en la
-- tabla, pero DISTINCT elimina duplicados.


-- -------------------------------------------------------------
-- 8. Alumnos sin email registrado
-- -------------------------------------------------------------
SELECT nombre, apellido
FROM alumnos
WHERE email IS NULL;

-- SOLUCIÓN: Pedro Ruiz y Laura Moreno.
-- NULL no se puede comparar con = NULL, hay que usar IS NULL.
