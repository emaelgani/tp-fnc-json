-- ============================================================================
-- SCRIPT 06: PARTE 5 - DEMOSTRACIÓN DE FLEXIBILIDAD DEL PARSER CYK
-- ============================================================================
-- Objetivo: Demostrar que el algoritmo CYK implementado en PostgreSQL es
-- 100% genérico. Al cambiar las reglas en la tabla GLC_en_FNC por las de
-- una gramática de expresiones aritméticas con números reales (0-9, +, *, ()),
-- la función cyk(cadena) valida el nuevo lenguaje sin tocar una sola línea
-- de código PL/pgSQL.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. VACIADO DE LA GRAMÁTICA ANTERIOR (JSON)
-- ----------------------------------------------------------------------------
TRUNCATE TABLE GLC_en_FNC;

-- ----------------------------------------------------------------------------
-- 2. CARGA DE PRODUCCIONES TERMINALES EN FNC (Tipo 1: A -> a)
-- ----------------------------------------------------------------------------
-- Los dígitos del 0 al 9 derivan directamente del símbolo inicial 'S' (start = true).
-- Los operadores y paréntesis derivan en sus variables terminales auxiliares.
INSERT INTO GLC_en_FNC (start, parte_izq, parte_der1, parte_der2, tipo_produccion) VALUES
(true,  'S',   '0', NULL, 1),
(true,  'S',   '1', NULL, 1),
(true,  'S',   '2', NULL, 1),
(true,  'S',   '3', NULL, 1),
(true,  'S',   '4', NULL, 1),
(true,  'S',   '5', NULL, 1),
(true,  'S',   '6', NULL, 1),
(true,  'S',   '7', NULL, 1),
(true,  'S',   '8', NULL, 1),
(true,  'S',   '9', NULL, 1),
(false, 'T_+', '+', NULL, 1),
(false, 'T_*', '*', NULL, 1),
(false, 'T_(', '(', NULL, 1),
(false, 'T_)', ')', NULL, 1);

-- ----------------------------------------------------------------------------
-- 3. CARGA DE PRODUCCIONES BINARIAS EN FNC (Tipo 2: A -> B C)
-- ----------------------------------------------------------------------------
INSERT INTO GLC_en_FNC (start, parte_izq, parte_der1, parte_der2, tipo_produccion) VALUES
-- Suma: S -> S + S  =>  S -> S A1  con  A1 -> T_+ S
(true,  'S',  'S',   'A1', 2),
(false, 'A1', 'T_+', 'S',  2),

-- Multiplicación: S -> S * S  =>  S -> S A2  con  A2 -> T_* S
(true,  'S',  'S',   'A2', 2),
(false, 'A2', 'T_*', 'S',  2),

-- Paréntesis asociativos: S -> ( S )  =>  S -> T_( A3  con  A3 -> S T_)
(true,  'S',  'T_(', 'A3', 2),
(false, 'A3', 'S',   'T_)', 2);

-- ----------------------------------------------------------------------------
-- 4. BATERÍA DE PRUEBAS AUTOMATIZADA
-- ----------------------------------------------------------------------------
-- Ejecuta la función cyk(cadena) sobre expresiones válidas e inválidas,
-- comparando el resultado obtenido con el esperado.
WITH pruebas(id, descripcion, entrada, resultado_esperado) AS (
    VALUES
        -- Casos Válidos (esperan true)
        (1,  'Número simple de un dígito',         '3',             true),
        (2,  'Suma simple',                        '1+2',           true),
        (3,  'Multiplicación simple',              '4*5',           true),
        (4,  'Operación combinada sin paréntesis', '1+2*3',         true),
        (5,  'Operación con paréntesis agrupados', '(1+2)*3',       true),
        (6,  'Paréntesis anidados dobles',         '((1+2))',       true),
        (7,  'Doble grupo con multiplicación',     '(1+2)*(3+4)',   true),

        -- Casos Inválidos con errores de sintaxis (esperan false)
        (8,  'Operador duplicado',                 '1++2',          false),
        (9,  'Paréntesis de apertura sin cerrar',  '(1+2',          false),
        (10, 'Inicia con operador binario',        '*1+2',          false),
        (11, 'Termina con operador binario',       '1+2*',          false),
        (12, 'Dos operadores seguidos',            '1+*2',          false),
        (13, 'Paréntesis vacíos sin expresión',    '()',            false)
)
SELECT 
    id,
    descripcion,
    entrada,
    cyk(entrada) AS resultado_obtenido,
    resultado_esperado,
    CASE 
        WHEN cyk(entrada) = resultado_esperado THEN 'Correcto'
        ELSE 'Fallo'
    END AS estado
FROM pruebas
ORDER BY id;

-- ============================================================================
-- NOTA: Para volver a dejar la base de datos lista para JSON,
-- simplemente vuelva a ejecutar el script "03_cargar_gramatica.sql".
-- ============================================================================
