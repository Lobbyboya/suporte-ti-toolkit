// Cria o banco de exemplo em memoria e roda cada consulta de consultas.sql.
// Precisa do Node.js 22.5 ou mais novo (modulo node:sqlite). Uso: node sql/testar.js
const { DatabaseSync } = require("node:sqlite");
const fs = require("node:fs");
const path = require("node:path");

const ler = (nome) => fs.readFileSync(path.join(__dirname, nome), "utf8");

const banco = new DatabaseSync(":memory:");
banco.exec(ler("esquema.sql"));

const semComentarios = ler("consultas.sql").replace(/^\s*--.*$/gm, "");
const consultas = semComentarios.split(";").map((s) => s.trim()).filter(Boolean);

consultas.forEach((sql, i) => {
  const linhas = banco.prepare(sql).all();
  console.log(`\nConsulta ${i + 1}: ${linhas.length} linha(s)`);
  console.table(linhas);
});
