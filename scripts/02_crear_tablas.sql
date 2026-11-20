-- Tablas para el algoritmo CYK

DROP TABLE IF EXISTS matriz_cyk CASCADE;
DROP TABLE IF EXISTS GLC_en_FNC CASCADE;

-- Gramatica Libre de Contexto en Forma Normal de Chomsky
CREATE TABLE GLC_en_FNC (
    start boolean NOT NULL,
    parte_izq text NOT NULL,
    parte_der1 text NOT NULL,
    parte_der2 text,
    tipo_produccion smallint NOT NULL CHECK (tipo_produccion IN (1, 2))
);

CREATE INDEX idx_glc_terminal ON GLC_en_FNC (parte_der1) WHERE tipo_produccion = 1;
CREATE INDEX idx_glc_binaria ON GLC_en_FNC (parte_der1, parte_der2) WHERE tipo_produccion = 2;

-- Matriz de reconocimiento CYK
CREATE TABLE matriz_cyk (
    i smallint NOT NULL,
    j smallint NOT NULL,
    x text[] NOT NULL,
    PRIMARY KEY (i, j)
);
