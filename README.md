# Suporte TI Toolkit

Material de apoio para atendimento de Suporte N1 / Help Desk: scripts de diagnóstico, consultas SQL de conferência e artigos de base de conhecimento.

Tudo aqui é **somente leitura**: os scripts e as consultas apenas coletam informação, sem alterar a máquina ou o banco.

## O que tem aqui

| Pasta | Conteúdo |
|---|---|
| [`windows/`](windows) | Scripts PowerShell de diagnóstico de rede e resumo da máquina |
| [`linux/`](linux) | Script Bash de diagnóstico de sistema e rede |
| [`sql/`](sql) | Consultas de conferência para um ERP de varejo, sobre um banco de exemplo |
| [`kb/`](kb) | Artigos de base de conhecimento no formato sintoma → causa → solução |

## Scripts

### `windows/diagnostico-rede.ps1`

Testa a rede de dentro para fora (placa, gateway, DNS, internet) e aponta a primeira etapa que falha, com o que verificar.

```powershell
.\windows\diagnostico-rede.ps1
```

```text
[ OK  ] Placa de rede: Ethernet com IP 192.168.1.2
[ OK  ] Gateway: 192.168.1.1 responde
[ OK  ] DNS: www.microsoft.com resolve para 23.194.182.92
[ OK  ] Internet: conexao HTTPS com www.microsoft.com aberta

Resultado: rede funcionando nas quatro etapas.
```

### `windows/resumo-maquina.ps1`

Reúne o que o suporte pergunta primeiro: sistema, tempo ligado, memória, discos e processos que mais consomem memória. Marca com `ATENCAO` máquina ligada há 7 dias ou mais, memória acima de 90% e disco com menos de 10% livre. Com `-Salvar` grava um arquivo para anexar ao chamado.

```powershell
.\windows\resumo-maquina.ps1 -Salvar C:\Temp\resumo.txt
```

### `linux/diagnostico.sh`

Mesma ideia para Linux: sistema, disco, memória, gateway, DNS e internet.

```bash
./linux/diagnostico.sh
```

## Consultas SQL

[`sql/consultas.sql`](sql/consultas.sql) traz cinco consultas, cada uma ligada a uma pergunta comum de chamado no varejo: produto que não passa no caixa, código de barras duplicado, estoque negativo, diferença no fechamento de caixa e resumo do dia por forma de pagamento.

O esquema em [`sql/esquema.sql`](sql/esquema.sql) é **fictício**, criado só para exercitar as consultas; não reproduz as tabelas de nenhum sistema real. Para rodar tudo em um banco em memória:

```bash
node sql/testar.js
```

## Base de conhecimento

- [KB-001: Computador sem acesso à internet](kb/001-sem-internet.md)
- [KB-002: Impressora não imprime (fila travada)](kb/002-impressora-nao-imprime.md)
- [KB-003: Computador lento](kb/003-computador-lento.md)

## Como foi testado

| Item | Teste |
|---|---|
| Scripts PowerShell | Executados no Windows 11, em Windows PowerShell 5.1 e PowerShell 7 |
| Consultas SQL | Executadas com `node sql/testar.js` (SQLite em memória, Node.js 22.5 ou mais novo) |
| Script Bash | Apenas checagem de sintaxe (`bash -n`); ainda não executado em uma máquina Linux |

## Licença

[MIT](LICENSE)
