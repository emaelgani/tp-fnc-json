-- -----------------------------------------------------------------------------
-- 1. EJECUCIÓN DEL PARSER SOBRE JSON VÁLIDO
-- -----------------------------------------------------------------------------

SELECT cyk('{"a":10}') AS es_valido;
-- Retorna: true


-- -----------------------------------------------------------------------------
-- 2. VISUALIZACIÓN DE LA PIRÁMIDE TRIANGULAR
-- -----------------------------------------------------------------------------

SELECT 
    (j - i + 1) AS nivel,
    string_agg(
        'X[' || i || ',' || j || ']=' || array_to_string(x, ','),
        '  |  ' ORDER BY i
    ) AS celdas
FROM matriz_cyk
GROUP BY (j - i + 1)
ORDER BY (j - i + 1) DESC;
