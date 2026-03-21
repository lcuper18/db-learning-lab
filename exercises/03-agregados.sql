-- =============================================================
-- DB Learning Lab — Ejercicio 3: Agregados y agrupación
-- Nivel: Intermedio
-- Motores: MariaDB, PostgreSQL, Firebird (sintaxis idéntica salvo nota)
-- =============================================================

-- -------------------------------------------------------------
-- 1. Número total de alumnos
-- -------------------------------------------------------------
SELECT COUNT(*) AS total_alumnos FROM alumnos;
-- SOLUCIÓN: 8


-- -------------------------------------------------------------
-- 2. Número de alumnos con email registrado
-- -------------------------------------------------------------
SELECT COUNT(email) AS con_email FROM alumnos;
-- SOLUCIÓN: 6 (COUNT ignora NULLs automáticamente)
-- Comparar con COUNT(*) = 8 para ver la diferencia.


-- -------------------------------------------------------------
-- 3. Alumnos por ciudad
-- -------------------------------------------------------------
SELECT ciudad, COUNT(*) AS num_alumnos
FROM alumnos
GROUP BY ciudad
ORDER BY num_alumnos DESC;
-- SOLUCIÓN: Madrid 2, Sevilla 2, Barcelona 1, Valencia 2 (con Diego), Bilbao 1.


-- -------------------------------------------------------------
-- 4. Nota mínima, máxima y promedio de todas las evaluaciones
-- -------------------------------------------------------------
SELECT
    MIN(nota)  AS nota_minima,
    MAX(nota)  AS nota_maxima,
    ROUND(AVG(nota), 2) AS promedio_global
FROM notas;
-- SOLUCIÓN: mín=5.50, máx=9.20, promedio≈7.42


-- -------------------------------------------------------------
-- 5. Nota promedio por alumno (solo alumnos con alguna nota)
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido, ROUND(AVG(n.nota), 2) AS promedio
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN notas n      ON n.matricula_id = m.id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY promedio DESC;
-- SOLUCIÓN: 6 alumnos (Pedro no tiene notas → no aparece con INNER JOIN).


-- -------------------------------------------------------------
-- 6. Alumnos con promedio superior a 7 (HAVING)
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido, ROUND(AVG(n.nota), 2) AS promedio
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN notas n      ON n.matricula_id = m.id
GROUP BY a.id, a.nombre, a.apellido
HAVING AVG(n.nota) > 7
ORDER BY promedio DESC;
-- SOLUCIÓN: Ana, Sofía, María, Laura.
-- Diferencia clave: WHERE filtra filas individuales ANTES de agrupar;
-- HAVING filtra grupos DESPUÉS de calcular el agregado.


-- -------------------------------------------------------------
-- 7. Número de matrículas por curso
-- -------------------------------------------------------------
SELECT c.nombre AS curso, COUNT(m.id) AS num_matriculados
FROM cursos c
LEFT JOIN matriculas m ON c.id = m.curso_id
GROUP BY c.id, c.nombre
ORDER BY num_matriculados DESC;
-- SOLUCIÓN: BD I=4, Prog.Web=3, Redes=2, Mat=2, Inglés=1, Seguridad=0.
-- LEFT JOIN necesario para que 'Seguridad Informática' aparezca con 0.


-- -------------------------------------------------------------
-- 8. Créditos totales por alumno matriculado
-- -------------------------------------------------------------
SELECT a.nombre, a.apellido, SUM(c.creditos) AS creditos_totales
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN cursos c     ON c.id = m.curso_id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY creditos_totales DESC;
