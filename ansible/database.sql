USE concierto;
CREATE TABLE IF NOT EXISTS tipo_entradas (
    id VARCHAR(36) NOT NULL,
    tipo VARCHAR(30),
    precio DECIMAL(10, 2),
    PRIMARY KEY (id)
);
