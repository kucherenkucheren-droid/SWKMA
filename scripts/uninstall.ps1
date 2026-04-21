$ErrorActionPreference = 'Stop'

$addinGuid = '{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$dllPath = Join-Path $rootDir 'src\SWKMA\bin\x64\Release\SWKMA.dll'
$solidWorksRedistPath = 'C:\Program Files\SOLIDWORKS Corp\SOLIDWORKS\api\redist'
$regAsmPath = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe'
$addinsKey = "HKCU:\Software\SolidWorks\AddIns\$addinGuid"
$startupKey = "HKCU:\Software\SolidWorks\AddInsStartup\$addinGuid"

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Host 'Запустите scripts\uninstall.ps1 от имени администратора.'
    exit 1
}

if (Test-Path -LiteralPath $dllPath) {
    if (-not (Test-Path -LiteralPath $regAsmPath)) {
        Write-Host "RegAsm не найден: $regAsmPath"
        exit 1
    }

    & $regAsmPath $dllPath /unregister "/asmpath:$solidWorksRedistPath"
    if ($LASTEXITCODE -ne 0) {
        throw 'Снятие регистрации DLL завершилось с ошибкой.'
    }
}

Remove-Item -LiteralPath $addinsKey -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $startupKey -Recurse -Force -ErrorAction SilentlyContinue

Write-Host 'SWKMA удалён.'
