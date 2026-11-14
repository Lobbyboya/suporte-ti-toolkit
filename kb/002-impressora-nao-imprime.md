# KB-002: Impressora não imprime (fila travada)

**Sintoma relatado:** "Mando imprimir e não sai nada", com documentos parados na fila.

## Perguntas antes de mexer

1. A impressora está ligada, com papel e sem luz de erro?
2. É impressora USB, de rede ou compartilhada por outro computador?
3. Outros usuários conseguem imprimir nela?

## Causa mais comum

Um documento com erro fica preso no início da fila e bloqueia todos os que vêm depois.

## Solução

1. Abrir a fila da impressora e cancelar todos os documentos.
2. Se os documentos não saírem da fila, reiniciar o serviço de impressão em um PowerShell aberto como administrador:

   ```powershell
   Stop-Service Spooler -Force
   Remove-Item "$env:SystemRoot\System32\spool\PRINTERS\*" -Force
   Start-Service Spooler
   ```

   O segundo comando apaga os trabalhos pendentes de **todas** as impressoras da máquina. Avisar o usuário de que será preciso mandar imprimir de novo.
3. Imprimir uma página de teste.

## Se não resolver

| Situação | Verificar |
|---|---|
| Impressora de rede aparece como offline | Se o IP da impressora responde ao ping e se não mudou |
| Só um usuário não imprime | Impressora padrão do usuário e driver instalado na máquina dele |
| Sai página em branco ou com caracteres estranhos | Driver errado: reinstalar o driver do modelo exato |

## O que registrar no chamado

Modelo da impressora, tipo de conexão, quantos usuários foram afetados e qual passo resolveu.
