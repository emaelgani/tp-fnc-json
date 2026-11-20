-- Carga de reglas de la gramatica en FNC

TRUNCATE TABLE GLC_en_FNC;

-- Producciones terminales (tipo 1: A -> a)
INSERT INTO GLC_en_FNC (start, parte_izq, parte_der1, parte_der2, tipo_produccion) VALUES
(false, 'T_{',  '{',  NULL, 1),
(false, 'T_}',  '}',  NULL, 1),
(false, 'T_"',  '"',  NULL, 1),
(false, 'T_''', '''', NULL, 1),
(false, 'T_:',  ':',  NULL, 1),
(false, 'T_,',  ',',  NULL, 1);

-- Espacio en blanco
INSERT INTO GLC_en_FNC (start, parte_izq, parte_der1, parte_der2, tipo_produccion) VALUES
(false, 'car', ' ', NULL, 1),
(false, 'X',   ' ', NULL, 1);

-- Digitos del 0 al 9
INSERT INTO GLC_en_FNC (start, parte_izq, parte_der1, parte_der2, tipo_produccion) VALUES
(false, 'D', '0', NULL, 1), (false, 'N', '0', NULL, 1), (false, 'V', '0', NULL, 1),
(false, 'D', '1', NULL, 1), (false, 'N', '1', NULL, 1), (false, 'V', '1', NULL, 1),
(false, 'D', '2', NULL, 1), (false, 'N', '2', NULL, 1), (false, 'V', '2', NULL, 1),
(false, 'D', '3', NULL, 1), (false, 'N', '3', NULL, 1), (false, 'V', '3', NULL, 1),
(false, 'D', '4', NULL, 1), (false, 'N', '4', NULL, 1), (false, 'V', '4', NULL, 1),
(false, 'D', '5', NULL, 1), (false, 'N', '5', NULL, 1), (false, 'V', '5', NULL, 1),
(false, 'D', '6', NULL, 1), (false, 'N', '6', NULL, 1), (false, 'V', '6', NULL, 1),
(false, 'D', '7', NULL, 1), (false, 'N', '7', NULL, 1), (false, 'V', '7', NULL, 1),
(false, 'D', '8', NULL, 1), (false, 'N', '8', NULL, 1), (false, 'V', '8', NULL, 1),
(false, 'D', '9', NULL, 1), (false, 'N', '9', NULL, 1), (false, 'V', '9', NULL, 1);

-- Letras de la 'a' a la 'z'
INSERT INTO GLC_en_FNC (start, parte_izq, parte_der1, parte_der2, tipo_produccion)
SELECT false, v, ch, NULL, 1
FROM unnest(ARRAY['letra', 'car', 'C', 'X']) AS v
CROSS JOIN unnest(ARRAY[
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z'
]) AS ch;

-- Producciones binarias (tipo 2: A -> B C)
INSERT INTO GLC_en_FNC (start, parte_izq, parte_der1, parte_der2, tipo_produccion) VALUES
-- Simbolo inicial S
(true,  'S',   'T_{',  'T_}',  2),
(true,  'S',   'T_{',  'R1',   2),
(false, 'R1',  'L',    'T_}',  2),

-- Pares y listas
(false, 'L',   'K',    'M1',   2),
(false, 'L',   'P',    'M2',   2),
(false, 'P',   'K',    'M1',   2),
(false, 'M1',  'T_:',  'V',    2),
(false, 'M2',  'T_,',  'L',    2),

-- Claves entre comillas dobles
(false, 'K',   'T_"',  'W1',   2),
(false, 'W1',  'C',    'T_"',  2),
(false, 'C',   'letra','C',    2),

-- Valores
(false, 'V',   'T_''', 'T_''', 2),
(false, 'V',   'T_''', 'U1',   2),
(false, 'U1',  'X',    'T_''', 2),
(false, 'V',   'T_{',  'T_}',  2),
(false, 'V',   'T_{',  'R1',   2),
(false, 'V',   'D',    'N',    2),

-- Cadenas de caracteres y numeros
(false, 'X',   'car',  'X',    2),
(false, 'N',   'D',    'N',    2);
