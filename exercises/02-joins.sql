-- =============================================================
-- DB Learning Lab — Ejercicio 2: JOIN (combinación de tablas)
-- Nivel: Intermedio
-- Motores: MariaDB, PostgreSQL, Firebird (sintaxis idéntica)
-- =============================================================

-- -------------------------------------------------------------
-- 1. Qué cursos tiene matriculado cada alumno (INNER JOIN)
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido, c.nombre AS curso, m.fecha_alta
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN cursos c     ON c.id = m.curso_id
ORDER BY a.apellido, c.nombre;

-- SOLUCIÓN: 12 filas (Diego no aparece — no tiene matrícula).
-- INNER JOIN solo devuelve filas que tienen coincidencia en AMBAS tablas.


-- -------------------------------------------------------------
-- 2. Todos los alumnos, tengan o no matrícula (LEFT JOIN)
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido, c.nombre AS curso
FROM alumnos a
LEFT JOIN matriculas m ON a.id = m.alumno_id
LEFT JOIN cursos c     ON c.id = m.curso_id
ORDER BY a.apellido;

-- SOLUCIÓN: 13 filas. Diego Torres aparece con NULL en 'curso'.
-- LEFT JOIN conserva TODAS las filas de la tabla de la izquierda.


-- -------------------------------------------------------------
-- 3. Cursos sin ningún alumno matriculado (LEFT JOIN inverso)
-- -------------------------------------------------------------
SELECT c.nombre AS curso, m.alumno_id
FROM cursos c
LEFT JOIN matriculas m ON c.id = m.curso_id
WHERE m.alumno_id IS NULL;

-- SOLUCIÓN: 'Seguridad Informática' — no tiene matrículas.
-- Patrón clásico: LEFT JOIN + WHERE columna_derecha IS NULL.


-- -------------------------------------------------------------
-- 4. Notas de cada alumno con nombre y evaluación
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido, c.nombre AS curso,
       n.evaluacion, n.nota
FROM alumnos a
JOIN matriculas m ON a.id  = m.alumno_id
JOIN cursos c     ON c.id  = m.curso_id
JOIN notas n      ON n.matricula_id = m.id
ORDER BY a.apellido, c.nombre, n.evaluacion;

-- SOLUCIÓN: 15 notas. Pedro (matrícula 11) no aparece porque
-- su matrícula no tiene notas → usa LEFT JOIN para verlo.


-- -------------------------------------------------------------
-- 5. Matrículas sin notas (alumno que aún no ha sido evaluado)
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido, c.nombre AS curso, m.fecha_alta
FROM matriculas m
JOIN alumnos a ON a.id = m.alumno_id
JOIN cursos c  ON c.id = m.curso_id
LEFT JOIN notas n ON n.matricula_id = m.id
WHERE n.id IS NULL
ORDER BY m.fecha_alta;

-- SOLUCIÓN: Pedro Ruiz en 'Bases de Datos I'.


-- -------------------------------------------------------------
-- 6. Alumnos matriculados en 'Bases de Datos I'
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN cursos c     ON c.id = m.curso_id
WHERE c.nombre = 'Bases de Datos I'
ORDER BY a.apellido;

-- SOLUCIÓN: Ana García, Luis Martínez, Carlos Sánchez, Pedro Ruiz.
