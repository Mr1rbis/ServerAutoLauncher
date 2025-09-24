@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: Настройки
set JSON_URL=https://raw.githubusercontent.com/Mr1rbis/ServerAutoLauncher/refs/heads/main/minecraft_server.json
set TEMP_JSON=temp_minecraft_server.json
set CONFIG_FILE=server_config.txt

:: Настройки для скачивания JDK
set JDK_FOLDER=jdk21
set JDK_URL=https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.zip

echo ========================================
echo    Автозапуск Minecraft сервера
echo ========================================
echo.

:: Проверка существования конфигурации
if exist "%CONFIG_FILE%" (
    goto load_config
)

:: Скачивание JSON файла
echo [INFO] Загружаю список доступных серверов...
curl -s -L -o "%TEMP_JSON%" "%JSON_URL%"
if not exist "%TEMP_JSON%" (
    echo [ERROR] Не удалось скачать файл конфигурации. Проверьте соединение с интернетом.
    pause
    exit /b 1
)

:select_server
:: Получение списка типов серверов
echo [INFO] Доступные типы серверов:
echo.
powershell -Command ^
    "$json = Get-Content -Raw '%TEMP_JSON%' | ConvertFrom-Json; " ^
    "$counter = 1; " ^
    "$json.core.PSObject.Properties | ForEach-Object { " ^
        "Write-Host \"$counter. $($_.Name)\"; " ^
        "$counter++ " ^
    "}"

echo.
set /p SERVER_CHOICE="Выберите номер типа сервера: "

:: Получение выбранного типа сервера
for /f "tokens=*" %%t in ('powershell -Command ^
    "$json = Get-Content -Raw '%TEMP_JSON%' | ConvertFrom-Json; " ^
    "$types = $json.core.PSObject.Properties.Name; " ^
    "$types[%SERVER_CHOICE% - 1]"') do (
    set SERVER_TYPE=%%t
)

if "!SERVER_TYPE!"=="" (
    echo [ERROR] Неверный выбор типа сервера.
    goto select_server
)

echo [INFO] Выбран тип сервера: !SERVER_TYPE!
echo.

:select_version
:: Получение списка версий для выбранного типа
echo [INFO] Доступные версии для !SERVER_TYPE!:
echo.
powershell -Command ^
    "$json = Get-Content -Raw '%TEMP_JSON%' | ConvertFrom-Json; " ^
    "$counter = 1; " ^
    "$json.core.'!SERVER_TYPE!'.PSObject.Properties | ForEach-Object { " ^
        "Write-Host \"$counter. $($_.Name)\"; " ^
        "$counter++ " ^
    "}"

echo.
set /p VERSION_CHOICE="Выберите номер версии: "

:: Получение выбранной версии
for /f "tokens=*" %%v in ('powershell -Command ^
    "$json = Get-Content -Raw '%TEMP_JSON%' | ConvertFrom-Json; " ^
    "$versions = $json.core.'!SERVER_TYPE!'.PSObject.Properties.Name; " ^
    "$versions[%VERSION_CHOICE% - 1]"') do (
    set SERVER_VERSION=%%v
)

if "!SERVER_VERSION!"=="" (
    echo [ERROR] Неверный выбор версии.
    goto select_version
)

echo [INFO] Выбрана версия: !SERVER_VERSION!
echo.

:: Сохранение конфигурации
echo [INFO] Сохраняю настройки...
(
    echo Тип сервера: !SERVER_TYPE!
    echo Версия: !SERVER_VERSION!
    echo Дата создания: %DATE% %TIME%
    echo SERVER_TYPE=!SERVER_TYPE!
    echo SERVER_VERSION=!SERVER_VERSION!
) > "%CONFIG_FILE%"
echo [INFO] Настройки сохранены в %CONFIG_FILE%
echo.

goto download_setup

:load_config
:: Загрузка сохранённой конфигурации
echo [INFO] Загружаю сохранённые настройки...
for /f "tokens=2 delims==" %%a in ('findstr "SERVER_TYPE=" "%CONFIG_FILE%"') do set SERVER_TYPE=%%a
for /f "tokens=2 delims==" %%a in ('findstr "SERVER_VERSION=" "%CONFIG_FILE%"') do set SERVER_VERSION=%%a

if "!SERVER_TYPE!"=="" (
    echo [ERROR] Ошибка чтения конфигурации. Создаю новую...
    del "%CONFIG_FILE%" 2>nul
    goto select_server
)

if "!SERVER_VERSION!"=="" (
    echo [ERROR] Ошибка чтения конфигурации. Создаю новую...
    del "%CONFIG_FILE%" 2>nul
    goto select_server
)

echo [INFO] Загружены настройки: !SERVER_TYPE! !SERVER_VERSION!
echo.

:: Скачивание JSON для получения ссылки
echo [INFO] Получаю информацию о сервере...
curl -s -L -o "%TEMP_JSON%" "%JSON_URL%"
if not exist "%TEMP_JSON%" (
    echo [ERROR] Не удалось скачать файл конфигурации.
    pause
    exit /b 1
)

:download_setup
:: Получение ссылки на скачивание
for /f "tokens=*" %%u in ('powershell -Command ^
    "$json = Get-Content -Raw '%TEMP_JSON%' | ConvertFrom-Json; " ^
    "$json.core.'!SERVER_TYPE!'.'!SERVER_VERSION!'.download_url"') do (
    set SERVER_URL=%%u
)

if "!SERVER_URL!"=="" (
    echo [ERROR] Не удалось получить ссылку на серверный файл.
    echo [ERROR] Возможно, выбранная версия больше недоступна.
    set /p RESELECT="Выбрать заново? (Y/n): "
    if /i not "!RESELECT!"=="n" (
        del "%CONFIG_FILE%" 2>nul
        goto select_server
    )
    goto cleanup
)

:: Формирование имени файла сервера
set SERVER_FILE=!SERVER_TYPE!-!SERVER_VERSION!.jar

:: Проверка существования файла сервера
if exist "!SERVER_FILE!" (
    goto setup_java_args
) else (
    goto download_server
)

:download_server
echo [INFO] Скачиваю серверный файл...
echo [INFO] URL: !SERVER_URL!
curl -L --progress-bar -o "!SERVER_FILE!" "!SERVER_URL!"

if not exist "!SERVER_FILE!" (
    echo [ERROR] Ошибка скачивания серверного файла.
    goto cleanup
)

echo [INFO] Серверный файл успешно скачан: !SERVER_FILE!
echo.
if exist "%TEMP_JSON%" del "%TEMP_JSON%"

:setup_java_args
:: Удаление старого файла java_args.txt если он существует
if exist "java_args.txt" (
    echo [INFO] Удаляю старый файл java_args.txt...
    del "java_args.txt" 2>nul
)

:: Создание нового файла java_args.txt
echo [INFO] Создаю файл с Java аргументами...
echo -Xms1G -Xmx3G > java_args.txt
echo [INFO] Файл java_args.txt создан успешно.

:: Простая загрузка Java аргументов
set JAVA_ARGS=-Xms1G -Xmx3G
echo [DEBUG] Java аргументы установлены: !JAVA_ARGS!

:: Проверка наличия системной Java
java -version >nul 2>&1
if not errorlevel 1 (
    echo [INFO] Найдена системная Java.
    set JAVA_CMD=java
    goto java_ready
)

:: Проверка наличия локальной JDK
if not exist "%JDK_FOLDER%\" (
    echo [INFO] Java не найдена в системе. Скачиваю JDK 21...
    curl -L -o jdk.zip "%JDK_URL%"
    if not exist jdk.zip (
        echo [ERROR] Ошибка скачивания JDK. Проверьте соединение с интернетом.
        goto cleanup
    )
    echo [INFO] Распаковываю JDK...
    powershell -Command "Expand-Archive -Path jdk.zip -DestinationPath . -Force"
    for /d %%d in ("jdk-*") do (
        echo [INFO] Найдена распакованная папка %%d. Переименовываю...
        ren "%%d" "%JDK_FOLDER%"
    )
    if not exist "%JDK_FOLDER%\" (
        echo [ERROR] Ошибка переименования папки JDK.
        goto cleanup
    )
    del jdk.zip
    echo [INFO] Локальная Java успешно установлена.
)

:: Установка пути к локальной Java
set JAVA_CMD=%~dp0%JDK_FOLDER%\bin\java.exe
echo [INFO] Использую локальную Java: %JAVA_CMD%

:java_ready

echo ========================================
echo [INFO] Запускаю сервер...
echo [INFO] Тип: !SERVER_TYPE!
echo [INFO] Версия: !SERVER_VERSION!
echo [INFO] Файл: !SERVER_FILE!
echo ========================================
echo.

:: Проверка размера файла
echo [DEBUG] Размер серверного файла: 
for %%A in ("!SERVER_FILE!") do echo %%~zA байт
echo.

:: Запуск сервера
echo [INFO] Запускаю команду: "%JAVA_CMD%" !JAVA_ARGS! -jar "!SERVER_FILE!" nogui
echo.
"%JAVA_CMD%" !JAVA_ARGS! -jar "!SERVER_FILE!" nogui

:: Автоматическое принятие EULA и перезапуск
if not exist "world\" (
    if exist "eula.txt" (
        echo.
        echo [INFO] Принимаю EULA и перезапускаю сервер...
        powershell -Command "(Get-Content -Path 'eula.txt') -replace 'eula=false', 'eula=true' | Set-Content -Path 'eula.txt'"
        echo.
        goto setup_java_args
    )
)

:cleanup
:: Очистка временных файлов
if exist "%TEMP_JSON%" del "%TEMP_JSON%"

echo.
echo [INFO] Сервер остановлен.
echo.

pause
goto setup_java_args