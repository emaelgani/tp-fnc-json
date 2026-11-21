SELECT cyk('(1+2)*3'); --devuelve true



SELECT (j - i + 1) AS nivel, string_agg('X[' || i || ',' || j || ']=' || array_to_string(x, ','), ' | ' ORDER BY i) AS celdas FROM matriz_cyk GROUP BY (j - i + 1) ORDER BY (j - i + 1) DESC;