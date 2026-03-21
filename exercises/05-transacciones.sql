-- =============================================================
-- DB Learning Lab — Ejercicio 5: Transacciones
-- Nivel: Avanzado
-- Motores: MariaDB, PostgreSQL, Firebird (con variantes)
-- =============================================================
-- Una transacción agrupa varias operaciones en una unidad atómica:
-- o se ejecutan TODAS correctamente, o NO se ejecuta ninguna.
-- Propiedades ACID: Atomicidad, Consistencia, Aislamiento, Durabilidad.
-- =============================================================

-- =============================================================
-- PARTE A — MariaDB / PostgreSQL
-- =============================================================

-- -------------------------------------------------------------
-- 1. Transacción exitosa: matricular a un alumno con notas
-- -------------------------------------------------------------
BEGIN;

INSERT INTO matriculas (alumno_id, curso_id, fecha_alta)
VALUES (8, 4, CURRENT_DATE);   -- Diego Torres en Matemáticas I

-- Suponemos que el id de la nueva matrícula es 13:
INSERT INTO notas (matricula_id, evaluacion, nota)
VALUES (13, 'Parcial 1', 6.50);

-- Verificar antes de confirmar (aún no es permanente):
SELECT a.nombre, c.nombre AS curso, n.nota
FROM matriculas m
JOIN alumnos a ON a.id = m.alumno_id
JOIN cursos c  ON c.id = m.curso_id
LEFT JOIN notas n ON n.matricula_id = m.id
WHERE m.id = 13;

COMMIT;   -- Confirmar: los cambios son permanentes

-- -------------------------------------------------------------
-- 2. Transacción con ROLLBACK: simular un error y deshacer
-- -------------------------------------------------------------
BEGIN;

UPDATE notas SET nota = 11.00   -- Nota inválida (viola CHECK nota <= 10)
WHERE id = 1;

-- En MariaDB: el UPDATE falla silenciosamente o lanza error según la configuración.
-- En PostgreSQL: lanza error inmediatamente y la transacción queda abortada.

-- Si no hubo error automático, deshacemos manualmente:
ROLLBACK;

-- Verificar que la nota original sigue igual:
SELECT nota FROM notas WHERE id = 1;


-- -------------------------------------------------------------
-- 3. Demostración de aislamiento: dos sesiones
-- -------------------------------------------------------------
-- Abre DOS pestañas/ventanas en Adminer o CloudBeaver.
--
-- SESIÓN A:
BEGIN;
UPDATE alumnos SET ciudad = 'Murcia' WHERE id = 1;
-- NO hagas COMMIT todavía.
--
-- SESIÓN B (otra pestaña):
SELECT ciudad FROM alumnos WHERE id = 1;
-- PostgreSQL: devuelve 'Madrid' (ve el valor pre-transacción).
-- MariaDB: igual, nivel de aislamiento por defecto = REPEATABLE READ.
--
-- SESIÓN A:
COMMIT;
--
-- SESIÓN B:
SELECT ciudad FROM alumnos WHERE id = 1;
-- Ahora devuelve 'Murcia'.

-- Deshacer el cambio:
BEGIN;
UPDATE alumnos SET ciudad = 'Madrid' WHERE id = 1;
COMMIT;


-- =============================================================
-- PARTE B — Diferencias Firebird
-- =============================================================
-- Firebird gestiona las transacciones de forma diferente:
--
-- 1. En Firebird, TODA operación SQL está implícitamente
--    dentro de una transacción. No existe "auto-commit" por defecto
--    cuando se usa isql-fb.
--
-- 2. BEGIN no existe como palabra clave en isql-fb.
--    Las transacciones se controlan con:
--      SET TRANSACTION;  -- iniciar explícitamente
--      COMMIT;           -- confirmar
--      ROLLBACK;         -- deshacer
--
-- 3. Ejemplo equivalente al ejercicio 2 en Firebird (isql-fb):

-- SET TRANSACTION;
-- UPDATE notas SET nota = 11.00 WHERE id = 1;
-- -- Si la restricción CHECK falla → error
-- ROLLBACK;
-- SELECT nota FROM notas WHERE id = 1;

-- 4. En Adminer/CloudBeaver con el driver JDBC de Firebird,
--    BEGIN/COMMIT/ROLLBACK funcionan igual que en PostgreSQL.
