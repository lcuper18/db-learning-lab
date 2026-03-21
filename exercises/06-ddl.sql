-- =============================================================
-- DB Learning Lab — Ejercicio 6: DDL (definición de esquema)
-- Nivel: Intermedio-Avanzado
-- =============================================================
-- DDL = Data Definition Language: CREATE, ALTER, DROP.
-- Estos ejercicios trabajan en una tabla de práctica separada
-- para no afectar el esquema principal.
-- =============================================================

-- =============================================================
-- PARTE A — MariaDB / PostgreSQL (sintaxis prácticamente idéntica)
-- =============================================================

-- -------------------------------------------------------------
-- 1. Crear una tabla nueva con constraints
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS profesores (
    id         SERIAL PRIMARY KEY,             -- PostgreSQL; en MariaDB usar INT AUTO_INCREMENT PRIMARY KEY
    nombre     VARCHAR(60)  NOT NULL,
    apellido   VARCHAR(60)  NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    departamento VARCHAR(80),
    activo     BOOLEAN DEFAULT TRUE,
    fecha_alta DATE DEFAULT CURRENT_DATE
);

-- MariaDB no tiene BOOLEAN nativo; usa TINYINT(1).
-- Versión MariaDB:
-- CREATE TABLE IF NOT EXISTS profesores (
--     id           INT AUTO_INCREMENT PRIMARY KEY,
--     nombre       VARCHAR(60)  NOT NULL,
--     apellido     VARCHAR(60)  NOT NULL,
--     email        VARCHAR(100) NOT NULL UNIQUE,
--     departamento VARCHAR(80),
--     activo       TINYINT(1) DEFAULT 1,
--     fecha_alta   DATE DEFAULT (CURRENT_DATE)
-- );


-- -------------------------------------------------------------
-- 2. Añadir una columna (ALTER TABLE ADD)
-- -------------------------------------------------------------
ALTER TABLE profesores ADD COLUMN telefono VARCHAR(20);

-- Verificar estructura:
-- PostgreSQL: \d profesores  (en psql)
-- MariaDB:    DESCRIBE profesores;
-- Ambos:      SELECT column_name, data_type FROM information_schema.columns
--             WHERE table_name = 'profesores';


-- -------------------------------------------------------------
-- 3. Modificar el tipo de una columna (ALTER TABLE MODIFY / ALTER COLUMN)
-- -------------------------------------------------------------
-- MariaDB:
-- ALTER TABLE profesores MODIFY COLUMN departamento VARCHAR(120);

-- PostgreSQL:
ALTER TABLE profesores ALTER COLUMN departamento TYPE VARCHAR(120);


-- -------------------------------------------------------------
-- 4. Añadir una clave foránea con ALTER TABLE
-- -------------------------------------------------------------
-- Relacionar cursos con un profesor responsable:
ALTER TABLE cursos ADD COLUMN profesor_id INT;

ALTER TABLE cursos
ADD CONSTRAINT fk_curso_profesor
FOREIGN KEY (profesor_id) REFERENCES profesores(id);

-- ¿Qué pasa si intentas insertar un curso con profesor_id = 999
-- cuando ese profesor no existe?
-- INSERT INTO cursos (nombre, profesor_id) VALUES ('Prueba', 999);
-- ERROR: violación de clave foránea.


-- -------------------------------------------------------------
-- 5. Eliminar una constraint
-- -------------------------------------------------------------
-- PostgreSQL:
ALTER TABLE cursos DROP CONSTRAINT fk_curso_profesor;

-- MariaDB:
-- ALTER TABLE cursos DROP FOREIGN KEY fk_curso_profesor;


-- -------------------------------------------------------------
-- 6. Crear un índice para mejorar el rendimiento
-- -------------------------------------------------------------
CREATE INDEX idx_alumnos_apellido ON alumnos(apellido);
CREATE INDEX idx_notas_matricula  ON notas(matricula_id);

-- Ver el efecto con EXPLAIN:
EXPLAIN SELECT * FROM alumnos WHERE apellido = 'García';
-- PostgreSQL: EXPLAIN ANALYZE SELECT ...  (más detallado)


-- -------------------------------------------------------------
-- 7. Crear una vista
-- -------------------------------------------------------------
CREATE OR REPLACE VIEW vista_notas_completa AS
SELECT
    a.nombre      AS alumno_nombre,
    a.apellido    AS alumno_apellido,
    c.nombre      AS curso,
    n.evaluacion,
    n.nota
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN cursos c     ON c.id = m.curso_id
JOIN notas n      ON n.matricula_id = m.id;

-- Usar la vista como si fuera una tabla:
SELECT * FROM vista_notas_completa WHERE nota >= 8 ORDER BY nota DESC;


-- -------------------------------------------------------------
-- 8. Limpiar: eliminar la tabla de práctica
-- -------------------------------------------------------------
-- Primero hay que quitar la FK que apunta a ella (ya la quitamos en paso 5).
DROP TABLE IF EXISTS profesores;
DROP VIEW  IF EXISTS vista_notas_completa;
ALTER TABLE cursos DROP COLUMN IF EXISTS profesor_id;
DROP INDEX IF EXISTS idx_alumnos_apellido;   -- PostgreSQL
-- MariaDB: DROP INDEX idx_alumnos_apellido ON alumnos;


-- =============================================================
-- PARTE B — Diferencias Firebird en DDL
-- =============================================================
-- • CREATE OR REPLACE VIEW no existe → usar CREATE VIEW (error si ya existe)
--   o DROP VIEW vista_xxx; CREATE VIEW vista_xxx AS ...
-- • IF NOT EXISTS en CREATE TABLE no existe → la tabla no debe existir antes
-- • ALTER TABLE MODIFY COLUMN no existe →
--     usar: ALTER TABLE t ALTER COLUMN c TYPE VARCHAR(120);
-- • BOOLEAN no existe → usar CHAR(1) o SMALLINT con CHECK (val IN (0,1))
-- • DROP INDEX: DROP INDEX idx_alumnos_apellido;  (sin ON tabla)
-- • Índices: CREATE INDEX idx_apellido ON alumnos(apellido);
