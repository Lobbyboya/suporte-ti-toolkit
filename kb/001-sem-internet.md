# KB-001: Computador sem acesso à internet

**Sintoma relatado:** "Minha internet caiu" ou "o sistema não abre".

## Perguntas antes de mexer

1. É só nesta máquina ou os colegas ao lado também estão sem acesso?
2. Parou de repente ou depois de alguma mudança (troca de mesa, cabo, atualização)?
3. Nada abre, ou só um site ou sistema específico?

Se for a rede inteira, o problema não está na máquina: escalar para quem cuida do link ou do roteador.

## Diagnóstico

Rodar `windows/diagnostico-rede.ps1` (ou `linux/diagnostico.sh`). O teste vai de dentro para fora e a primeira falha indica a causa:

| Primeira falha | Causa provável | Solução |
|---|---|---|
| Placa de rede | Cabo solto, Wi-Fi desligado ou placa desabilitada | Reconectar o cabo, testar outra porta do switch, habilitar a placa |
| Placa com IP `169.254.x.x` | A máquina não recebeu endereço do DHCP | `ipconfig /release` e `ipconfig /renew`; se persistir, testar cabo e porta |
| Gateway | Roteador ou switch sem resposta | Conferir se outras máquinas da mesma rede respondem; escalar |
| DNS | Servidor DNS errado ou fora do ar | `ipconfig /flushdns`; conferir o DNS configurado na placa |
| Internet | Bloqueio de firewall ou proxy, ou link do provedor | Testar outro site; escalar com o resultado do script |

## O que registrar no chamado

- Resultado do script (qual etapa falhou).
- Se o problema atinge uma máquina ou várias.
- O que já foi tentado.

## Quando escalar

Falha no gateway em mais de uma máquina, ou falha de internet com as outras três etapas funcionando.
