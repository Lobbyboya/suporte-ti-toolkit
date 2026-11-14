-- Esquema FICTICIO de um ERP de varejo, criado so para exercitar as consultas.
-- Nao reproduz as tabelas de nenhum sistema real.

CREATE TABLE produto (
  id            INTEGER PRIMARY KEY,
  descricao     TEXT    NOT NULL,
  codigo_barras TEXT,
  ncm           TEXT,
  preco_venda   REAL,
  ativo         INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE estoque (
  produto_id INTEGER PRIMARY KEY REFERENCES produto (id),
  quantidade REAL NOT NULL
);

CREATE TABLE venda (
  id        INTEGER PRIMARY KEY,
  caixa     INTEGER NOT NULL,
  data_hora TEXT    NOT NULL,
  total     REAL    NOT NULL,
  cancelada INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE venda_pagamento (
  id       INTEGER PRIMARY KEY,
  venda_id INTEGER NOT NULL REFERENCES venda (id),
  forma    TEXT    NOT NULL,
  valor    REAL    NOT NULL
);

-- Dados de exemplo, com um problema plantado para cada consulta encontrar.
INSERT INTO produto (id, descricao, codigo_barras, ncm, preco_venda, ativo) VALUES
  (1, 'Arroz 5kg',         '7890000000011', '10063021', 28.90, 1),
  (2, 'Feijao 1kg',        '7890000000028', '07133319',  8.50, 1),
  (3, 'Cafe 500g',         '7890000000035', NULL,       18.90, 1),  -- sem NCM
  (4, 'Acucar 1kg',        '7890000000042', '17019900',  0,    1),  -- preco zerado
  (5, 'Oleo de soja 900ml','7890000000028', '15079011',  7.99, 1),  -- codigo de barras repetido
  (6, 'Macarrao 500g',     '7890000000066', '19021900',  4.50, 1),
  (7, 'Produto antigo',    NULL,            NULL,        NULL, 0);  -- inativo: deve ser ignorado

INSERT INTO estoque (produto_id, quantidade) VALUES
  (1, 40), (2, 12), (3, 6), (4, 25), (5, 18),
  (6, -3);  -- estoque negativo

INSERT INTO venda (id, caixa, data_hora, total, cancelada) VALUES
  (101, 1, '2026-11-10 09:15:00', 37.40, 0),
  (102, 1, '2026-11-10 09:42:00', 18.90, 0),
  (103, 2, '2026-11-10 10:05:00', 12.49, 0),  -- sem pagamento registrado
  (104, 2, '2026-11-10 10:30:00', 28.90, 0),  -- pagamento menor que o total
  (105, 1, '2026-11-10 11:00:00',  8.50, 1);  -- cancelada: deve ser ignorada

INSERT INTO venda_pagamento (venda_id, forma, valor) VALUES
  (101, 'DINHEIRO', 37.40),
  (102, 'PIX',      18.90),
  (104, 'CARTAO',   20.00);
