-- =============================================================
-- DB Learning Lab — PostgreSQL
-- Base de datos de ejemplo: Sistema Escolar
-- =============================================================
-- Tablas: alumnos, cursos, matriculas, notas
-- Ejercicios sugeridos al final del archivo
-- =============================================================

-- -------------------------------------------------------------
-- Tabla: alumnos
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS alumnos (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(60)  NOT NULL,
    apellido   VARCHAR(60)  NOT NULL,
    email      VARCHAR(100) UNIQUE,
    fecha_nac  DATE,
    ciudad     VARCHAR(60)
);

-- -------------------------------------------------------------
-- Tabla: cursos
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cursos (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    descripcion TEXT,
    creditos    SMALLINT DEFAULT 3
);

-- -------------------------------------------------------------
-- Tabla: matriculas (relación alumno ↔ curso)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS matriculas (
    id         SERIAL PRIMARY KEY,
    alumno_id  INT  NOT NULL REFERENCES alumnos(id),
    curso_id   INT  NOT NULL REFERENCES cursos(id),
    fecha_alta DATE DEFAULT CURRENT_DATE,
    UNIQUE (alumno_id, curso_id)
);

-- -------------------------------------------------------------
-- Tabla: notas
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notas (
    id           SERIAL PRIMARY KEY,
    matricula_id INT          NOT NULL REFERENCES matriculas(id),
    evaluacion   VARCHAR(50)  NOT NULL,
    nota         NUMERIC(4,2) CHECK (nota >= 0 AND nota <= 10)
);

-- =============================================================
-- Datos de ejemplo
-- =============================================================

INSERT INTO alumnos (nombre, apellido, email, fecha_nac, ciudad) VALUES
  ('Ana',    'García',    'ana.garcia@lab.local',     '2005-03-15', 'Madrid'),
  ('Luis',   'Martínez',  'luis.martinez@lab.local',  '2004-07-22', 'Barcelona'),
  ('Sofía',  'López',     'sofia.lopez@lab.local',    '2005-11-08', 'Valencia'),
  ('Carlos', 'Sánchez',   'carlos.sanchez@lab.local', '2006-01-30', 'Sevilla'),
  ('María',  'Fernández', 'maria.fernandez@lab.local','2005-09-14', 'Bilbao');

INSERT INTO cursos (nombre, descripcion, creditos) VALUES
  ('Bases de Datos I',  'Fundamentos de SQL y diseño relacional', 4),
  ('Programación Web',  'HTML, CSS y JavaScript básico',          3),
  ('Redes y Sistemas',  'Conceptos de redes LAN/WAN',             3),
  ('Matemáticas I',     'Álgebra y cálculo diferencial',          4),
  ('Inglés Técnico',    'Vocabulario y comunicación técnica',     2);

INSERT INTO matriculas (alumno_id, curso_id, fecha_alta) VALUES
  (1, 1, '2026-02-01'), (1, 2, '2026-02-01'),
  (2, 1, '2026-02-01'), (2, 3, '2026-02-01'),
  (3, 2, '2026-02-01'), (3, 4, '2026-02-01'),
  (4, 1, '2026-02-01'), (4, 5, '2026-02-01'),
  (5, 3, '2026-02-01'), (5, 4, '2026-02-01');

INSERT INTO notas (matricula_id, evaluacion, nota) VALUES
  (1, 'Parcial 1', 7.50), (1, 'Parcial 2', 8.00), (1, 'Final', 7.80),
  (2, 'Parcial 1', 6.00),                          (2, 'Final', 6.50),
  (3, 'Parcial 1', 9.00), (3, 'Parcial 2', 8.50), (3, 'Final', 9.20),
  (4, 'Parcial 1', 5.50),                          (4, 'Final', 6.00),
  (5, 'Parcial 1', 7.00), (5, 'Parcial 2', 7.50), (5, 'Final', 7.30);

-- =============================================================
-- Ejercicios sugeridos (ejecutar en Adminer o cliente SQL)
-- =============================================================
-- 1. Listar todos los alumnos ordenados por apellido:
--    SELECT * FROM alumnos ORDER BY apellido;
--
-- 2. Ver qué cursos tiene matriculado cada alumno:
--    SELECT a.nombre, a.apellido, c.nombre AS curso
--    FROM alumnos a
--    JOIN matriculas m ON a.id = m.alumno_id
--    JOIN cursos c ON c.id = m.curso_id;
--
-- 3. Nota promedio por alumno:
--    SELECT a.nombre, a.apellido, ROUND(AVG(n.nota)::NUMERIC, 2) AS promedio
--    FROM alumnos a
--    JOIN matriculas m ON a.id = m.alumno_id
--    JOIN notas n ON n.matricula_id = m.id
--    GROUP BY a.id, a.nombre, a.apellido;
--
-- 4. Alumnos matriculados en 'Bases de Datos I':
--    SELECT a.nombre, a.apellido
--    FROM alumnos a
--    JOIN matriculas m ON a.id = m.alumno_id
--    JOIN cursos c ON c.id = m.curso_id
--    WHERE c.nombre = 'Bases de Datos I';
--
-- 5. Insertar un nuevo alumno:
--    INSERT INTO alumnos (nombre, apellido, email, ciudad)
--    VALUES ('Pedro', 'Ruiz', 'pedro.ruiz@lab.local', 'Málaga');
--
-- 6. Diferencia respecto a MySQL/MariaDB: usar SERIAL en lugar de AUTO_INCREMENT,
--    NUMERIC en lugar de DECIMAL, y el operador :: para castear tipos.
