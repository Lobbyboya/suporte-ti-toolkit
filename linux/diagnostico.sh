#!/usr/bin/env bash
# Diagnostico rapido de uma maquina Linux: sistema, disco, memoria e rede.
# Somente leitura: nao altera nenhuma configuracao.
#
# Uso:
#   ./diagnostico.sh                 # testa a internet com www.debian.org
#   ./diagnostico.sh servidor.local  # testa com outro nome

destino="${1:-www.debian.org}"
falhas=0

ok()    { printf '[ OK  ] %s: %s\n' "$1" "$2"; }
falha() { printf '[FALHA] %s: %s\n        Verificar: %s\n' "$1" "$2" "$3"; falhas=$((falhas + 1)); }

printf '\nDiagnostico - %s - %s\n\n' "$(hostname)" "$(date '+%d/%m/%Y %H:%M')"

# Sistema
if [ -r /etc/os-release ]; then
  . /etc/os-release
  printf 'Sistema   : %s\n' "${PRETTY_NAME:-desconhecido}"
fi
printf 'Kernel    : %s\n' "$(uname -r)"
printf 'Ligado ha : %s\n\n' "$(uptime -p 2>/dev/null || uptime)"

# Disco: qualquer particao com 90% ou mais de uso
cheias=$(df -P -x tmpfs -x devtmpfs 2>/dev/null | awk 'NR > 1 && $5 + 0 >= 90 { printf "%s (%s) ", $6, $5 }')
if [ -n "$cheias" ]; then
  falha "Disco" "particoes com 90% ou mais de uso: $cheias" "logs em /var/log, cache de pacotes e arquivos grandes (du -xh / | sort -h | tail)"
else
  ok "Disco" "nenhuma particao acima de 90%"
fi

# Memoria disponivel
if [ -r /proc/meminfo ]; then
  total=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
  livre=$(awk '/^MemAvailable:/ { print $2 }' /proc/meminfo)
  if [ -n "$total" ] && [ -n "$livre" ]; then
    pct=$((livre * 100 / total))
    if [ "$pct" -lt 10 ]; then
      falha "Memoria" "apenas ${pct}% disponivel" "processos que mais consomem: ps aux --sort=-%mem | head"
    else
      ok "Memoria" "${pct}% disponivel"
    fi
  fi
fi

# Rede: gateway, DNS e internet, de dentro para fora
gateway=$(ip route 2>/dev/null | awk '/^default/ { print $3; exit }')
if [ -z "$gateway" ]; then
  falha "Gateway" "nenhuma rota padrao" "cabo ou Wi-Fi conectado; configuracao da interface (ip addr)"
elif ping -c 2 -W 2 "$gateway" > /dev/null 2>&1; then
  ok "Gateway" "$gateway responde"
else
  falha "Gateway" "$gateway nao responde ao ping" "roteador ligado; cabo; outras maquinas da mesma rede"
fi

if getent hosts "$destino" > /dev/null 2>&1; then
  ok "DNS" "$destino resolve"
  if command -v curl > /dev/null 2>&1; then
    if curl -sS -o /dev/null --max-time 8 "https://$destino" 2>/dev/null; then
      ok "Internet" "conexao HTTPS com $destino aberta"
    else
      falha "Internet" "sem conexao HTTPS com $destino" "firewall, proxy ou link do provedor"
    fi
  fi
else
  falha "DNS" "nao foi possivel resolver $destino" "servidores em /etc/resolv.conf"
fi

printf '\n'
if [ "$falhas" -gt 0 ]; then
  printf 'Resultado: %s falha(s). Comece pela primeira da lista.\n' "$falhas"
  exit 1
fi
printf 'Resultado: nenhum problema encontrado.\n'
