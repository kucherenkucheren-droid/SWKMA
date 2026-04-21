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
- Для запуска COM-класса установочный скрипт копирует 3 SolidWorks interop DLL рядом с `SWKMA.dll`. В проекте при этом сохранено `<Private>false</Private>`, то есть сборка сама их не копирует.
- Скрипты не запускались на установку/удаление, чтобы не менять регистрацию и реестр без отдельной команды пользователя.
- Проверка Release-сборки прошла успешно без ошибок командой MSBuild с `/p:RegisterForComInterop=false`.
- Синтаксис `install.ps1` и `uninstall.ps1` проверен через PowerShell parser без ошибок.

---

## 2026-04-21 | Codex (gpt-5.3)
### Проверка загрузки SWKMA в SolidWorks 2026

#### Дневник шагов
- Шаг 1. Повторно прочитаны AGENTS.md и ADDIN_SETUP.md.
- Шаг 2. Проверена Release-сборка `SWKMA.dll`.
- Шаг 3. Проверены кодировки `.cs`, `.ps1` и `.md`.
- Шаг 4. Проверена COM-регистрация `SWKMA.SwAddin`.
- Шаг 5. Найдена проблема: SolidWorks interop DLL не были рядом с `SWKMA.dll`, поэтому COM-загрузка могла падать.
- Шаг 6. `install.ps1` обновлён: теперь после сборки он копирует 3 SolidWorks interop DLL рядом с `SWKMA.dll`.
- Шаг 7. `uninstall.ps1` обновлён: теперь он удаляет эти установочные копии interop DLL.
- Шаг 8. Ключи SolidWorks AddIns и AddInsStartup записаны в профиль пользователя MishG.
- Шаг 9. Запущен SolidWorks 2026.
- Шаг 10. SWKMA загружен в текущий сеанс SolidWorks через `LoadAddIn` по полному пути к DLL.

### Что сделано
- В папке `src\SWKMA\bin\x64\Release` лежат:
  - `SWKMA.dll`
  - `SolidWorks.Interop.sldworks.dll`
  - `SolidWorks.Interop.swconst.dll`
  - `SolidWorks.Interop.swpublished.dll`
- COM-объект `SWKMA.SwAddin` создаётся успешно.
- В реестре пользователя MishG созданы ключи:
  - `Software\SolidWorks\AddIns\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}`
  - `Software\SolidWorks\AddInsStartup\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}`
- Проверка SolidWorks API вернула `LoadAddIn=0`, это успешная загрузка.
- `GetAddInObject` вернул объект add-in по ProgId и по GUID.

### Решения и причины
- SolidWorks interop DLL оставлены с `<Private>false</Private>` в `.csproj`, чтобы сборка проекта не копировала их автоматически.
- Копирование interop DLL перенесено в установочный скрипт, потому что это уже этап установки, а не обычной сборки.
- Для текущей проверки ключи реестра записаны напрямую в профиль MishG, потому что Codex работает из служебного пользователя `codexsandboxoffline`.

---

## 2026-04-21 | Codex (gpt-5.3)
### Исправление появления SWKMA в списке надстроек SolidWorks

#### Дневник шагов
- Шаг 1. Проверен скриншот окна `Инструменты -> Добавления`: SWKMA отсутствовал в списке.
- Шаг 2. Сравнены ветки реестра с уже видимыми надстройками SWCC MProp и SWPlus.
- Шаг 3. Найдена причина: `SWKMA` был записан в пользовательскую ветку `HKCU`, а список надстроек SolidWorks берётся из `HKLM\SOFTWARE\SolidWorks\AddIns`.
- Шаг 4. `install.ps1` исправлен: ключ списка надстроек теперь создаётся в `HKLM`.
- Шаг 5. `uninstall.ps1` исправлен: удаляет ключ списка надстроек из `HKLM`.
- Шаг 6. Установка запущена через UAC от администратора.
- Шаг 7. Проверено наличие ключа `HKLM\SOFTWARE\SolidWorks\AddIns\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}`.
- Шаг 8. Запущен SolidWorks 2026 и выполнена проверка загрузки через API.

### Что сделано
- Создан системный ключ SolidWorks:
  - `HKLM\SOFTWARE\SolidWorks\AddIns\{64D84459-B29E-495C-9DD2-25F8E7A5EEF1}`
- В ключе записаны:
  - default value `1`
  - `Title = SWKMA`
  - `Description = Автоматизация рутины инженера-конструктора`
- Повторно проверена COM-регистрация `SWKMA.SwAddin`.
- Проверена загрузка в SolidWorks 2026:
  - `LoadAddIn=0`
  - объект add-in найден по `SWKMA.SwAddin`
  - объект add-in найден по GUID
- После финальной сборки повторная проверка дала `LoadAddIn=2`, то есть SolidWorks сообщил, что SWKMA уже загружен.

### Решения и причины
- Для списка надстроек используется `HKLM`, потому что так зарегистрированы видимые в SolidWorks надстройки SWCC MProp и SWPlus.
- `HKCU\Software\SolidWorks\AddInsStartup` оставлен только для автозагрузки.
- Обычная запись в `HKLM` без UAC не проходит из-за прав Windows, поэтому установка должна запускаться от администратора.

---

## 2026-04-21 | Claude (Sonnet)
### Визуальное подтверждение — SWKMA в SolidWorks

- Пользователь открыл `Инструменты → Добавления` в SolidWorks 2026
- SWKMA виден в разделе "Другие добавления"
- Галочка слева: активен (загружен прямо сейчас)
- Галочка справа: автозапуск включён
- Время загрузки: < 1s

### Milestone
Add-in успешно установлен и работает в SolidWorks 2026.
Порядок разработки по ADDIN_SETUP.md: шаги 1–3 выполнены.

### Следующий шаг
- Шаг 4: добавить кнопку в меню SolidWorks
- Шаг 5: кнопка открывает окно Mprop (WPF)

---

## 2026-04-21 | Claude (Sonnet)
### Кнопка в меню SolidWorks

- Добавлен CommandManager с CommandGroup "SWKMA"
- Кнопка "Редактор свойств" появилась в меню SolidWorks
- Callback OpenMprop() показывает MessageBox — заглушка для следующего шага
- Пользователь подтвердил: кнопка работает, MessageBox открывается

### Что сделано в коде
- `SwAddin.cs`: добавлены `AddCommandMgr()`, `RemoveCommandMgr()`, `OpenMprop()`, `EnableMprop()`
- `SWKMA.csproj`: добавлена ссылка `System.Windows.Forms`

### Следующий шаг
- Шаг 5: заменить MessageBox на реальное WPF окно Mprop
