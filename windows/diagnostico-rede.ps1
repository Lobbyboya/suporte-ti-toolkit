<#
.SYNOPSIS
    Diagnostico de rede em camadas: placa, gateway, DNS e internet.

.DESCRIPTION
    Testa a conexao de dentro para fora e para no primeiro ponto que falha,
    dizendo onde esta o problema e o que verificar. Somente leitura: nao altera
    nenhuma configuracao da maquina.

.PARAMETER Destino
    Nome usado nos testes de DNS e de internet. Padrao: www.microsoft.com

.EXAMPLE
    .\diagnostico-rede.ps1

.EXAMPLE
    .\diagnostico-rede.ps1 -Destino servidor.empresa.local
#>
param(
    [string]$Destino = "www.microsoft.com"
)

$falhou = $false

function Escrever-Resultado {
    param([string]$Etapa, [bool]$Ok, [string]$Detalhe, [string]$Dica)
    if ($Ok) {
        Write-Host ("[ OK  ] {0}: {1}" -f $Etapa, $Detalhe) -ForegroundColor Green
    } else {
        Write-Host ("[FALHA] {0}: {1}" -f $Etapa, $Detalhe) -ForegroundColor Red
        if ($Dica) { Write-Host ("        Verificar: {0}" -f $Dica) -ForegroundColor Yellow }
    }
}

function Testar-Ping {
    param([string]$Alvo)
    # Test-Connection muda de parametros entre o PowerShell 5.1 e o 7; ping.exe existe nos dois.
    $null = & ping.exe -n 2 -w 1500 $Alvo
    return ($LASTEXITCODE -eq 0)
}

Write-Host ""
Write-Host ("Diagnostico de rede - {0} - {1}" -f $env:COMPUTERNAME, (Get-Date -Format "dd/MM/yyyy HH:mm"))
Write-Host ""

# 1. Placa de rede ativa com endereco IPv4
$config = Get-NetIPConfiguration |
    Where-Object { $_.NetAdapter.Status -eq "Up" -and $_.IPv4Address } |
    Sort-Object { if ($_.IPv4DefaultGateway) { 0 } else { 1 } } |
    Select-Object -First 1

if (-not $config) {
    Escrever-Resultado "Placa de rede" $false "nenhuma placa ativa com endereco IPv4" "cabo de rede ou Wi-Fi conectado; placa habilitada em ncpa.cpl"
    exit 1
}

$ip = $config.IPv4Address[0].IPAddress
if ($ip -like "169.254.*") {
    Escrever-Resultado "Placa de rede" $false ("{0} com IP automatico {1}" -f $config.InterfaceAlias, $ip) "a maquina nao recebeu IP do DHCP: testar cabo/porta do switch e rodar ipconfig /renew"
    exit 1
}
Escrever-Resultado "Placa de rede" $true ("{0} com IP {1}" -f $config.InterfaceAlias, $ip)

# 2. Gateway (roteador da rede local)
$gateway = $null
if ($config.IPv4DefaultGateway) { $gateway = $config.IPv4DefaultGateway[0].NextHop }

if (-not $gateway) {
    Escrever-Resultado "Gateway" $false "nenhum gateway configurado" "configuracao de IP fixo sem gateway, ou DHCP incompleto"
    $falhou = $true
} elseif (Testar-Ping $gateway) {
    Escrever-Resultado "Gateway" $true ("{0} responde" -f $gateway)
} else {
    # Alguns roteadores nao respondem a ping; por isso o teste continua.
    Escrever-Resultado "Gateway" $false ("{0} nao responde ao ping" -f $gateway) "roteador ligado; cabo entre a maquina e o switch; outras maquinas da mesma rede"
    $falhou = $true
}

# 3. DNS
$dnsOk = $false
try {
    $resposta = Resolve-DnsName -Name $Destino -Type A -ErrorAction Stop |
        Where-Object { $_.IPAddress } | Select-Object -First 1
    if ($resposta) {
        $dnsOk = $true
        Escrever-Resultado "DNS" $true ("{0} resolve para {1}" -f $Destino, $resposta.IPAddress)
    }
} catch {
    $dnsOk = $false
}
if (-not $dnsOk) {
    $servidores = ($config.DNSServer | Where-Object { $_.AddressFamily -eq 2 } | ForEach-Object { $_.ServerAddresses }) -join ", "
    Escrever-Resultado "DNS" $false ("nao foi possivel resolver {0} (servidores: {1})" -f $Destino, $servidores) "servidor DNS configurado na placa; testar com ipconfig /flushdns"
    $falhou = $true
}

# 4. Saida para a internet (HTTPS, porque muitos sites bloqueiam ping)
if ($dnsOk) {
    $porta = Test-NetConnection -ComputerName $Destino -Port 443 -WarningAction SilentlyContinue
    if ($porta.TcpTestSucceeded) {
        Escrever-Resultado "Internet" $true ("conexao HTTPS com {0} aberta" -f $Destino)
    } else {
        Escrever-Resultado "Internet" $false ("sem conexao HTTPS com {0}" -f $Destino) "firewall, proxy ou link do provedor"
        $falhou = $true
    }
}

Write-Host ""
if ($falhou) {
    Write-Host "Resultado: ha pelo menos uma falha. Comece pela primeira da lista." -ForegroundColor Yellow
    exit 1
}
Write-Host "Resultado: rede funcionando nas quatro etapas." -ForegroundColor Green
exit 0
