# Дневник разработки SWKMA

## Формат записи
**Дата** | **Кто** | **Что сделано** | **Решения и причины**

---

## 2026-04-21 | Claude (Sonnet)
### Подготовка проекта
- Определён стек: C# + .NET Framework 4.8.1 + WPF + SOLIDWORKS API
- Созданы файлы правил: CLAUDE.md, AGENTS.md
- Инициализирован Git, создан репозиторий на GitHub
- Подключены MCP серверы: GitHub, Commit commands, csharp-lsp
- Подключён Chrome для браузерной автоматизации

### Решения
- WPF вместо WinForms — лучше для сложного UI, AI генерирует лучше
- AGENTS.md содержит полные правила (не ссылку) — надёжнее для Codex
- Один DEVLOG.md для обоих AI — единый источник истории проекта

### Следующий шаг
- UI макет окна спецификации в Claude Design

---

## 2026-04-21 | Claude (Opus 4.7)
### Решение о порядке переноса
- Начинаем с Mprop (редактор свойств), а не со SpecEditor — свойства фундамент для спеки
- Порядок разделов Mprop: Детали → Сборочные единицы → Стандартные изделия → Прочие → Материалы → Комплекты → Комплексы

### Изучение SWPlus
- Прочитан раздел Mprop "Детали" руководства SWPlus 2026 SP1
- Изучена структура UI: 2 панели — форма слева, превью основной надписи справа

### UI макет Mprop "Детали"
- Создан макет в Claude Design (https://claude.ai/design/p/35530b0e-a34d-416e-a78a-da96f9352ac1)
- Стиль: Windows 11 Fluent Design, тёмная тема по умолчанию
- Акцентный цвет — SolidWorks синий #1E88E5
- Основная надпись остаётся белой (как реальный чертёж)
- Добавлено: переключатель темы, индикатор связи с SolidWorks, панель свойств документа справа

### Следующий шаг
- Реализация макета в WPF (стандартные задачи — Sonnet или Codex gpt-5.3)
- Или: сначала макеты остальных разделов Mprop

---

## 2026-04-21 | Claude (Sonnet)
### Проверка макета Mprop — все 7 разделов

- Открыт макет в режиме Present: https://claude.ai/design/p/35530b0e-a34d-416e-a78a-da96f9352ac1?file=Mprop+Dialog.html
- Протестировано переключение дропдауна "Раздел" клавишами ArrowUp/ArrowDown
- Подтверждена работа всех 7 разделов:
  - **Детали** — основная надпись ГОСТ 2.104-2006 Форма 1, материал в основной надписи
  - **Сборочные единицы** — раздел "СПЕЦИФИКАЦИЯ - ПЕРЕЧЕНЬ ЭЛЕМЕНТОВ", поля компонента, материал недоступен
  - **Стандартные изделия** — 3 таблицы превью (Спека/Ведомость покупных/Перечень элементов), чекбоксы Разработка/Крепеж
  - **Прочие изделия** — как Стандартные + чекбокс "Деталь"
  - **Материалы** — как Стандартные + поле "Наименование из материала SW"
  - **Комплекты** — основная надпись + поле "Комплект" с выбором из списка
  - **Комплексы** — идентично Сборочным единицам

### Решения
- Макет реализован через JavaScript setMode() — при смене раздела меняется весь UI через data-show атрибуты
- Для взаимодействия с макетом из Claude Code нужен клавиатурный ввод (ArrowUp/ArrowDown), т.к. iframe cross-origin

### Следующий шаг
- Реализация Mprop в WPF (Sonnet или Codex gpt-5.3)
- Сначала создать структуру проекта Visual Studio для SolidWorks add-in

---

## 2026-04-21 | Codex (gpt-5.3)
### Создание структуры Visual Studio для SolidWorks add-in

#### Дневник шагов
- Шаг 1. Прочитаны правила проекта из AGENTS.md.
- Шаг 2. Проверена текущая папка проекта и наличие DEVLOG.md.
- Шаг 3. Проверено наличие DLL SolidWorks 2026 в `C:\Program Files\SOLIDWORKS Corp\SOLIDWORKS\api\redist`.
- Шаг 4. Создан solution `SWKMA.sln`.
- Шаг 5. Создан проект `src\SWKMA\SWKMA.csproj`.
- Шаг 6. Создан основной класс add-in `src\SWKMA\SwAddin.cs`.
- Шаг 7. Создан файл `src\SWKMA\Properties\AssemblyInfo.cs`.
- Шаг 8. Проверена компиляция проекта обычной сборкой с временно отключенной COM-регистрацией.

### Что сделано
- Создана структура проекта Visual Studio:
  - `SWKMA.sln`
  - `src\SWKMA\SWKMA.csproj`
  - `src\SWKMA\SwAddin.cs`
  - `src\SWKMA\Properties\AssemblyInfo.cs`
- Проект настроен как Class Library под `.NET Framework 4.8.1`.
- Платформа проекта: `x64`.
- Включена COM-регистрация через `<RegisterForComInterop>true</RegisterForComInterop>`.
- Добавлены ссылки на DLL SolidWorks 2026:
  - `SolidWorks.Interop.sldworks.dll`
  - `SolidWorks.Interop.swconst.dll`
  - `SolidWorks.Interop.swpublished.dll`
- Для всех DLL SolidWorks указано `<Private>false</Private>`, чтобы они не копировались в output.
- В `SwAddin.cs` создан класс `SwAddin` с `[ComVisible(true)]` и новым GUID.
- `SwAddin` реализует `SolidWorks.Interop.swpublished.ISwAddin`.
- Методы `ConnectToSW` и `DisconnectFromSW` пока сделаны заглушками и возвращают `true`.

### Решения и причины
- Использован старый формат `.csproj`, потому что он лучше подходит для `.NET Framework 4.8.1` и COM Interop.
- В solution оставлены только конфигурации `Debug|x64` и `Release|x64`, потому что SolidWorks add-in должен работать в 64-bit.
- Ссылки на SolidWorks DLL оставлены с `Private=false`, как требуется, чтобы не складывать библиотеки SolidWorks рядом с нашим add-in.
- Проверка обычной сборки прошла успешно без ошибок при временном параметре `/p:RegisterForComInterop=false`.
- Полная сборка с COM-регистрацией создала `SWKMA.dll`, но на этапе регистрации показала ошибку поиска `SolidWorks.Interop.swpublished.dll`. Это связано с тем, что DLL SolidWorks не копируются в output и не найдены загрузчиком COM-регистрации. На следующем этапе нужно отдельно настроить регистрацию add-in или путь поиска DLL.

---

## 2026-04-21 | Codex (gpt-5.3)
### Подготовка установки SolidWorks add-in

#### Дневник шагов
- Шаг 1. Прочитаны правила проекта из AGENTS.md и инструкция ADDIN_SETUP.md.
- Шаг 2. В `SwAddin.cs` добавлен `ProgId` для COM-регистрации.
- Шаг 3. В `ConnectToSW` добавлен вызов `SetAddinCallbackInfo2`.
- Шаг 4. Создан скрипт установки `scripts\install.ps1`.
- Шаг 5. Создан скрипт удаления `scripts\uninstall.ps1`.
- Шаг 6. Проверены кодировки: `.cs` и `.ps1` сохранены в UTF-8 with BOM, `DEVLOG.md` оставлен UTF-8 без BOM.
- Шаг 7. Проверены сборка Release x64 и синтаксис PowerShell-скриптов.

### Что сделано
- В `src\SWKMA\SwAddin.cs` добавлен атрибут `[ProgId("SWKMA.SwAddin")]`.
- В `ConnectToSW` добавлен вызов `_solidWorks.SetAddinCallbackInfo2(0, this, _addinCookie);`.
- `scripts\install.ps1` делает установку:
  - проверяет запуск от администратора;
  - проверяет, что SolidWorks закрыт;
  - собирает проект в `Release | x64`;
  - регистрирует DLL через `RegAsm.exe /codebase`;
  - передаёт `RegAsm` путь к DLL SolidWorks через `/asmpath`;
  - создаёт ключи SolidWorks AddIns и AddInsStartup для GUID `{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}`;
  - выводит сообщение `Готово. Перезапустите SolidWorks.`
- `scripts\uninstall.ps1` делает удаление:
  - проверяет запуск от администратора;
  - снимает регистрацию DLL через `RegAsm.exe /unregister`;
  - удаляет ключи SolidWorks AddIns и AddInsStartup;
  - выводит сообщение `SWKMA удалён.`

### Решения и причины
- Для записи значения реестра по умолчанию использован .NET Registry API, потому что так создаётся именно default value, который читает SolidWorks.
- Для `RegAsm` добавлен `/asmpath` на папку SolidWorks `api\redist`, потому что SolidWorks DLL не копируются в output.
- Скрипты не запускались на установку/удаление, чтобы не менять регистрацию и реестр без отдельной команды пользователя.
- Проверка Release-сборки прошла успешно без ошибок командой MSBuild с `/p:RegisterForComInterop=false`.
- Синтаксис `install.ps1` и `uninstall.ps1` проверен через PowerShell parser без ошибок.
