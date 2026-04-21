# Подключение SWKMA к SolidWorks

Инструкция специально для проекта SWKMA. Содержит конкретные пути, GUID и команды — без подстановок.

---

## Данные проекта

```text
Название:     SWKMA
GUID add-in:  {64D84459-B29E-495C-9DD2-25F8E7A5EEF1}
ProgId:       SWKMA.SwAddin
Namespace:    SWKMA
DLL (Debug):  C:\Users\MishG\Documents\SWKMA\src\SWKMA\bin\x64\Debug\SWKMA.dll
DLL (Release):C:\Users\MishG\Documents\SWKMA\src\SWKMA\bin\x64\Release\SWKMA.dll
```

---

## Что уже сделано

- [x] Проект создан: `Class Library`, `.NET Framework 4.8.1`, `x64`
- [x] Добавлены ссылки на SolidWorks 2026 DLL
- [x] Класс `SwAddin` с `[ComVisible(true)]` и правильным GUID
- [x] Реализован интерфейс `ISwAddin`
- [x] Проект компилируется без ошибок

## Что нужно добавить в код

### 1. ProgId в SwAddin.cs

Добавить атрибут `[ProgId]` к классу:

```csharp
[ComVisible(true)]
[Guid("64D84459-B29E-495C-9DD2-25F8E7A5EEF1")]
[ProgId("SWKMA.SwAddin")]   // <- добавить эту строку
public class SwAddin : ISwAddin
```

### 2. SetAddinCallbackInfo2 в ConnectToSW

SolidWorks требует этот вызов при подключении:

```csharp
public bool ConnectToSW(object ThisSW, int Cookie)
{
    _solidWorks = (SldWorks)ThisSW;
    _addinCookie = Cookie;

    _solidWorks.SetAddinCallbackInfo2(0, this, _addinCookie);  // <- добавить

    return true;
}
```

---

## Сборка

Debug (для разработки):
```text
Конфигурация: Debug | x64
```

Release (для установки):
```text
Конфигурация: Release | x64
```

---

## Установка (install.ps1)

Скрипт находится в `scripts\install.ps1`. Запускать от имени **администратора**.

Что делает:
1. Проверяет, закрыт ли SolidWorks
2. Собирает проект в Release x64
3. Копирует 3 SolidWorks interop DLL рядом с `SWKMA.dll`
4. Регистрирует DLL через RegAsm
5. Создаёт ключи реестра для SolidWorks:
   - список надстроек: `HKEY_LOCAL_MACHINE\SOFTWARE\SolidWorks\AddIns\{GUID}`
   - автозагрузка: `HKEY_CURRENT_USER\Software\SolidWorks\AddInsStartup\{GUID}`

Запуск:
```powershell
cd C:\Users\MishG\Documents\SWKMA
.\scripts\install.ps1
```

---

## Удаление (uninstall.ps1)

```powershell
cd C:\Users\MishG\Documents\SWKMA
.\scripts\uninstall.ps1
```

---

## Ручная установка (если скрипт не работает)

### Шаг 1. Собрать проект

Открыть Visual Studio → собрать `Release | x64`.

Или через командную строку (администратор):
```text
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe
  src\SWKMA\SWKMA.csproj
  /p:Configuration=Release /p:Platform=x64 /p:RegisterForComInterop=false
```

### Шаг 2. Зарегистрировать DLL

Перед регистрацией рядом с `SWKMA.dll` должны лежать:
```text
SolidWorks.Interop.sldworks.dll
SolidWorks.Interop.swconst.dll
SolidWorks.Interop.swpublished.dll
```

Командная строка от **администратора**:
```text
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe
  "C:\Users\MishG\Documents\SWKMA\src\SWKMA\bin\x64\Release\SWKMA.dll"
  /codebase
```

### Шаг 3. Создать ключи реестра

Создать файл `swkma.reg` и запустить двойным кликом:

```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\SolidWorks\AddIns\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}]
@=dword:00000001
"Title"="SWKMA"
"Description"="Автоматизация рутины инженера-конструктора"

[HKEY_CURRENT_USER\Software\SolidWorks\AddInsStartup\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}]
@=dword:00000000
```

Автозагрузка выключена (`dword:00000000`) — включать вручную через `Инструменты → Надстройки`.

### Шаг 4. Перезапустить SolidWorks

### Шаг 5. Проверить

```text
Инструменты → Надстройки → найти SWKMA → поставить галочку
```

---

## Удаление вручную

Командная строка от **администратора**:
```text
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe
  "C:\Users\MishG\Documents\SWKMA\src\SWKMA\bin\x64\Release\SWKMA.dll"
  /unregister
```

Затем удалить ключи реестра:
```text
HKEY_LOCAL_MACHINE\SOFTWARE\SolidWorks\AddIns\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}
HKEY_CURRENT_USER\Software\SolidWorks\AddInsStartup\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}
```

---

## Add-in не появился в списке — чеклист

- [ ] GUID в коде совпадает с GUID в реестре: `64D84459-B29E-495C-9DD2-25F8E7A5EEF1`
- [ ] DLL зарегистрирована через `RegAsm Framework64` (не Framework32)
- [ ] Проект собран как `x64`
- [ ] Используется `.NET Framework 4.8.1`
- [ ] SolidWorks перезапущен после установки
- [ ] Ключ `HKLM\SOFTWARE\SolidWorks\AddIns\{GUID}` существует

## Add-in появился, но не включается — чеклист

- [ ] `ConnectToSW` возвращает `true`
- [ ] `SetAddinCallbackInfo2` вызван в `ConnectToSW`
- [ ] В `ConnectToSW` нет тяжёлой работы (окна, файлы, расчёты)
- [ ] SolidWorks DLL взяты от версии 2026

---

## Порядок разработки

```text
1. Add-in появился в списке SolidWorks
2. Add-in включается без ошибки           <- сейчас здесь
3. Add-in отключается без ошибки
4. Добавлена кнопка в меню
5. Кнопка открывает окно Mprop (WPF)
6. Окно читает свойства из модели SW
7. Окно записывает свойства в модель SW
```
