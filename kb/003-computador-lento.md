# KB-003: Computador lento

**Sintoma relatado:** "Meu computador está travando" ou "o sistema demora para abrir".

## Perguntas antes de mexer

1. Está lento o tempo todo ou só em um programa?
2. Desde quando? Algo foi instalado ou atualizado nesse período?
3. Quando foi a última vez que a máquina foi reiniciada (reiniciada mesmo, não só a tela desligada)?

## Diagnóstico

Rodar `windows/resumo-maquina.ps1`. O script marca com `ATENCAO` as três causas mais comuns:

| Alerta | Causa | Solução |
|---|---|---|
| Ligada há 7 dias ou mais | Programas e atualizações acumulados sem reinício | Reiniciar e testar de novo antes de qualquer outra coisa |
| Memória com 90% ou mais em uso | Programa consumindo demais, ou muitas abas e programas abertos | Fechar o que aparece no topo da lista; se for sempre o mesmo programa, abrir chamado sobre ele |
| Disco com menos de 10% livre | Falta espaço para o sistema trabalhar | Limpeza de Disco do Windows, esvaziar a lixeira e a pasta Downloads com o usuário |

## Se nenhum alerta aparecer

- Conferir no Gerenciador de Tarefas, aba Inicializar, o que abre junto com o Windows.
- Se a lentidão é só em um sistema que depende de servidor, o problema pode ser a rede: ver [KB-001](001-sem-internet.md).

## O que registrar no chamado

A saída do script (`-Salvar` gera um arquivo para anexar), o que foi feito e se a lentidão voltou depois.

## Quando escalar

Lentidão que persiste com memória e disco folgados e máquina recém-reiniciada: pode ser disco com defeito ou hardware insuficiente para o uso.
