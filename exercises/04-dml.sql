-- =============================================================
-- DB Learning Lab — Ejercicio 4: DML (INSERT, UPDATE, DELETE)
-- Nivel: Intermedio
-- Motores: MariaDB, PostgreSQL (sintaxis idéntica)
--          Firebird: ver variantes al final
-- =============================================================
-- IMPORTANTE: ejecuta estos ejercicios en orden.
-- Usa reset.sh para volver al estado inicial cuando quieras.
-- =============================================================

-- -------------------------------------------------------------
-- 1. INSERT — Añadir un nuevo alumno
-- -------------------------------------------------------------
INSERT INTO alumnos (nombre, apellido, email, fecha_nac, ciudad)
VALUES ('Marta', 'Iglesias', 'marta.iglesias@lab.local', '2005-08-12', 'Zaragoza');

-- Verificar:
SELECT * FROM alumnos WHERE apellido = 'Iglesias';


-- -------------------------------------------------------------
-- 2. INSERT — Matricular al nuevo alumno en un curso
-- -------------------------------------------------------------
-- Primero averigua el id del alumno recién creado:
SELECT id FROM alumnos WHERE email = 'marta.iglesias@lab.local';

-- Luego matricularlo (sustituye 9 por el id real si es diferente):
INSERT INTO matriculas (alumno_id, curso_id, fecha_alta)
VALUES (9, 3, CURRENT_DATE);

-- Verificar:
SELECT a.nombre, c.nombre AS curso
FROM alumnos a JOIN matriculas m ON a.id = m.alumno_id
               JOIN cursos c     ON c.id = m.curso_id
WHERE a.apellido = 'Iglesias';


-- -------------------------------------------------------------
-- 3. UPDATE — Corregir una nota
-- -------------------------------------------------------------
-- Ver la nota actual del Parcial 1 de la matrícula 1:
SELECT * FROM notas WHERE matricula_id = 1 AND evaluacion = 'Parcial 1';

-- Actualizarla:
UPDATE notas
SET nota = 8.00
WHERE matricula_id = 1 AND evaluacion = 'Parcial 1';

-- Verificar:
SELECT * FROM notas WHERE matricula_id = 1;


-- -------------------------------------------------------------
-- 4. UPDATE — Añadir email a alumno que no tenía
-- -------------------------------------------------------------
UPDATE alumnos
SET email = 'pedro.ruiz@lab.local'
WHERE nombre = 'Pedro' AND apellido = 'Ruiz';

-- Verificar:
SELECT nombre, apellido, email FROM alumnos WHERE apellido = 'Ruiz';


-- -------------------------------------------------------------
-- 5. DELETE — Eliminar una nota
-- -------------------------------------------------------------
DELETE FROM notas
WHERE matricula_id = 2 AND evaluacion = 'Final';

-- Verificar:
SELECT * FROM notas WHERE matricula_id = 2;

-- ¿Qué pasa si intentas borrar una matrícula que tiene notas?
-- DELETE FROM matriculas WHERE id = 1;
-- ERROR: violación de clave foránea (fk_nota_mat).
-- Hay que borrar primero las notas, luego la matrícula.


-- -------------------------------------------------------------
-- 6. DELETE — Eliminar matrícula (primero sus notas)
-- -------------------------------------------------------------
DELETE FROM notas     WHERE matricula_id = 3;
DELETE FROM matriculas WHERE id = 3;

-- Verificar: Sofía ya no está en Programación Web
SELECT a.nombre, c.nombre AS curso
FROM alumnos a JOIN matriculas m ON a.id = m.alumno_id
               JOIN cursos c     ON c.id = m.curso_id
WHERE a.nombre = 'Sofía';


-- =============================================================
-- Variantes Firebird
-- =============================================================
-- Todo lo anterior funciona igual en Firebird EXCEPTO:
--
-- CURRENT_DATE: funciona igual ✓
-- Funciones de fecha: usar CURRENT_DATE en lugar de NOW() o CURDATE()
-- Multi-row INSERT: NO soportado → un INSERT por fila
-- RETURNING: Firebird no tiene RETURNING al estilo PostgreSQL
--
-- Para obtener el último ID insertado en Firebird:
--   SELECT MAX(id) FROM alumnos;  -- método sencillo (no atómico en concurrencia)
