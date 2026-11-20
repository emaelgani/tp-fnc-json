-- Funciones para el algoritmo CYK

-- Calcula una fila de la matriz para subcadenas de longitud dada por el parametro
CREATE OR REPLACE FUNCTION setear_matriz(fila integer)
RETURNS void AS $$
DECLARE
    n integer;
    idx_i integer;
    idx_j integer;
    variables_encontradas text[];
BEGIN
    SELECT MAX(j) INTO n FROM matriz_cyk WHERE i = j;

    IF n IS NULL OR fila < 2 OR fila > n THEN
        RETURN;
    END IF;

    FOR idx_i IN 1 .. (n - fila + 1) LOOP
        idx_j := idx_i + fila - 1;

        -- Busca particiones k donde B pertenezca a X[idx_i, k],
        -- C pertenezca a X[k+1, idx_j] y exista la regla A -> B C
        SELECT COALESCE(array_agg(DISTINCT g.parte_izq), '{}')
        INTO variables_encontradas
        FROM generate_series(idx_i, idx_j - 1) AS k
        JOIN matriz_cyk m1 ON m1.i = idx_i AND m1.j = k
        JOIN matriz_cyk m2 ON m2.i = k + 1 AND m2.j = idx_j
        JOIN GLC_en_FNC g ON g.tipo_produccion = 2
                         AND g.parte_der1 = ANY(m1.x)
                         AND g.parte_der2 = ANY(m2.x);

        INSERT INTO matriz_cyk (i, j, x)
        VALUES (idx_i::smallint, idx_j::smallint, variables_encontradas);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Funcion principal: inicializa la matriz, ejecuta los pasos inductivos y verifica si S reconoce la cadena
CREATE OR REPLACE FUNCTION cyk(cadena text)
RETURNS boolean AS $$
DECLARE
    n integer;
    pos integer;
    caracter text;
    variables_base text[];
    es_valido boolean;
BEGIN
    IF cadena IS NULL OR length(cadena) = 0 THEN
        RETURN FALSE;
    END IF;

    n := length(cadena);

    TRUNCATE TABLE matriz_cyk;

    -- Caso base: subcadenas de longitud 1
    FOR pos IN 1 .. n LOOP
        caracter := substr(cadena, pos, 1);

        SELECT COALESCE(array_agg(DISTINCT parte_izq), '{}')
        INTO variables_base
        FROM GLC_en_FNC
        WHERE tipo_produccion = 1 AND parte_der1 = caracter;

        INSERT INTO matriz_cyk (i, j, x)
        VALUES (pos::smallint, pos::smallint, variables_base);
    END LOOP;

    -- Paso inductivo: subcadenas de longitud 2 a n
    FOR f IN 2 .. n LOOP
        PERFORM setear_matriz(f);
    END LOOP;

    -- Verificacion en la raiz X[1, n]
    SELECT 'S' = ANY(x)
    INTO es_valido
    FROM matriz_cyk
    WHERE i = 1 AND j = n;

    RETURN COALESCE(es_valido, FALSE);
END;
$$ LANGUAGE plpgsql;
