CREATE TABLE IF NOT EXISTS tipo_entradas (
    id VARCHAR(36) NOT NULL,
    tipo VARCHAR(30),
    precio DECIMAL(10, 2),
    PRIMARY KEY (id)
);
 
CREATE TABLE IF NOT EXISTS entradas (
    id VARCHAR(36) NOT NULL,
    fecha DATE,
    nombre VARCHAR(15),
    apellidos VARCHAR(30),
    telefono VARCHAR(9),
    tipo_entrada VARCHAR(36),
    cantidad INT,
    precio DECIMAL(10, 2),
    PRIMARY KEY (id),
    FOREIGN KEY (tipo_entrada) REFERENCES tipo_entradas(id)
);
 
INSERT INTO tipo_entradas (id, tipo, precio) VALUES
(UUID(), 'Menor', 10),
(UUID(), 'Adulto', 5),
(UUID(), 'Jubilado', 7);
