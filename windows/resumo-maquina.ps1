<#
.SYNOPSIS
    Resumo da maquina para abrir ou escalar um chamado.

.DESCRIPTION
    Junta em uma tela o que o suporte costuma perguntar primeiro: sistema,
    tempo ligado, memoria, espaco em disco e os processos que mais consomem
    memoria. Marca com ATENCAO o que costuma causar lentidao.
    Somente leitura: nao altera nada na maquina.

.PARAMETER Salvar
    Caminho de um arquivo .txt para gravar o resumo e anexar ao chamado.

.EXAMPLE
    .\resumo-maquina.ps1

.EXAMPLE
    .\resumo-maquina.ps1 -Salvar C:\Temp\resumo.txt
#>
param(
    [string]$Salvar
)

$linhas = New-Object System.Collections.Generic.List[string]
$alertas = New-Object System.Collections.Generic.List[string]

$so = Get-CimInstance Win32_OperatingSystem
$pc = Get-CimInstance Win32_ComputerSystem

$ligadoHa = (Get-Date) - $so.LastBootUpTime
$memTotalGb = [math]::Round($so.TotalVisibleMemorySize / 1MB, 1)
$memLivreGb = [math]::Round($so.FreePhysicalMemory / 1MB, 1)
$memUsoPct = [math]::Round((1 - ($so.FreePhysicalMemory / $so.TotalVisibleMemorySize)) * 100)

$linhas.Add(("Resumo da maquina - {0}" -f (Get-Date -Format "dd/MM/yyyy HH:mm")))
$linhas.Add("")
$linhas.Add(("Computador : {0}" -f $env:COMPUTERNAME))
$linhas.Add(("Usuario    : {0}" -f $env:USERNAME))
$linhas.Add(("Modelo     : {0} {1}" -f $pc.Manufacturer, $pc.Model))
$linhas.Add(("Sistema    : {0} (build {1})" -f $so.Caption, $so.BuildNumber))
$linhas.Add(("Ligado ha  : {0} dias e {1} horas" -f $ligadoHa.Days, $ligadoHa.Hours))
$linhas.Add(("Memoria    : {0} GB livres de {1} GB ({2}% em uso)" -f $memLivreGb, $memTotalGb, $memUsoPct))

if ($ligadoHa.Days -ge 7) { $alertas.Add("Maquina ligada ha 7 dias ou mais: reiniciar antes de investigar lentidao.") }
if ($memUsoPct -ge 90) { $alertas.Add("Memoria com 90% ou mais em uso: ver os processos abaixo.") }

$linhas.Add("")
$linhas.Add("Discos:")
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $livreGb = [math]::Round($_.FreeSpace / 1GB, 1)
    $totalGb = [math]::Round($_.Size / 1GB, 1)
    $livrePct = [math]::Round(($_.FreeSpace / $_.Size) * 100)
    $linhas.Add(("  {0}  {1} GB livres de {2} GB ({3}% livre)" -f $_.DeviceID, $livreGb, $totalGb, $livrePct))
    if ($livrePct -lt 10) { $alertas.Add(("Disco {0} com menos de 10% livre." -f $_.DeviceID)) }
}

$linhas.Add("")
$linhas.Add("Processos que mais usam memoria:")
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 | ForEach-Object {
    $linhas.Add(("  {0,-30} {1,8} MB" -f $_.ProcessName, [math]::Round($_.WorkingSet64 / 1MB)))
}

$linhas.Add("")
if ($alertas.Count -eq 0) {
    $linhas.Add("Nenhum ponto de atencao encontrado.")
} else {
    foreach ($a in $alertas) { $linhas.Add(("ATENCAO: {0}" -f $a)) }
}

$linhas | ForEach-Object { Write-Host $_ }

if ($Salvar) {
    $linhas | Set-Content -Path $Salvar -Encoding UTF8
    Write-Host ""
    Write-Host ("Resumo salvo em {0}" -f $Salvar)
}
