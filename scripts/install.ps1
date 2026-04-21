$ErrorActionPreference = 'Stop'

$addinGuid = '{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}'
$addinTitle = 'SWKMA'
$addinDescription = 'Автоматизация рутины инженера-конструктора'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$projectPath = Join-Path $rootDir 'src\SWKMA\SWKMA.csproj'
$dllPath = Join-Path $rootDir 'src\SWKMA\bin\x64\Release\SWKMA.dll'
$outputDir = Split-Path -Parent $dllPath
$solidWorksRedistPath = 'C:\Program Files\SOLIDWORKS Corp\SOLIDWORKS\api\redist'
$solidWorksInteropDlls = @(
    'SolidWorks.Interop.sldworks.dll',
    'SolidWorks.Interop.swconst.dll',
    'SolidWorks.Interop.swpublished.dll'
)
$msBuildPath = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'
$regAsmPath = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe'
$addinsSubKey = "Software\SolidWorks\AddIns\$addinGuid"
$startupSubKey = "Software\SolidWorks\AddInsStartup\$addinGuid"

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Host 'Запустите scripts\install.ps1 от имени администратора.'
    exit 1
}

if (Get-Process -Name 'SLDWORKS' -ErrorAction SilentlyContinue) {
    Write-Host 'SolidWorks открыт. Закройте SolidWorks и запустите установку снова.'
    exit 1
}

if (-not (Test-Path -LiteralPath $msBuildPath)) {
    Write-Host "MSBuild не найден: $msBuildPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $regAsmPath)) {
    Write-Host "RegAsm не найден: $regAsmPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $solidWorksRedistPath)) {
    Write-Host "Папка DLL SolidWorks не найдена: $solidWorksRedistPath"
    exit 1
}

foreach ($interopDll in $solidWorksInteropDlls) {
    $interopPath = Join-Path $solidWorksRedistPath $interopDll
    if (-not (Test-Path -LiteralPath $interopPath)) {
        Write-Host "DLL SolidWorks не найдена: $interopPath"
        exit 1
    }
}

Push-Location $rootDir
try {
    & $msBuildPath $projectPath /p:Configuration=Release /p:Platform=x64 /p:RegisterForComInterop=false
    if ($LASTEXITCODE -ne 0) {
        throw 'Сборка проекта завершилась с ошибкой.'
    }

    if (-not (Test-Path -LiteralPath $dllPath)) {
        throw "DLL не найдена после сборки: $dllPath"
    }

    foreach ($interopDll in $solidWorksInteropDlls) {
        Copy-Item -LiteralPath (Join-Path $solidWorksRedistPath $interopDll) -Destination (Join-Path $outputDir $interopDll) -Force
    }

    & $regAsmPath $dllPath /codebase
    if ($LASTEXITCODE -ne 0) {
        throw 'Регистрация DLL завершилась с ошибкой.'
    }

    $addinsRegistryKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($addinsSubKey)
    $startupRegistryKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($startupSubKey)
    try {
        $addinsRegistryKey.SetValue('', 1, [Microsoft.Win32.RegistryValueKind]::DWord)
        $addinsRegistryKey.SetValue('Title', $addinTitle, [Microsoft.Win32.RegistryValueKind]::String)
        $addinsRegistryKey.SetValue('Description', $addinDescription, [Microsoft.Win32.RegistryValueKind]::String)
        $startupRegistryKey.SetValue('', 0, [Microsoft.Win32.RegistryValueKind]::DWord)
    }
    finally {
        $addinsRegistryKey.Close()
        $startupRegistryKey.Close()
    }

    Write-Host 'Готово. Перезапустите SolidWorks.'
}
finally {
    Pop-Location
}
