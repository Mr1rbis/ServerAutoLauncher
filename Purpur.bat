@echo off
chcp 65001 >nul

echo ███╗░░░███╗██████╗░██╗██████╗░██████╗░██╗░██████╗
echo ████╗░████║██╔══██╗██║██╔══██╗██╔══██╗██║██╔════╝
echo ██╔████╔██║██████╔╝██║██████╔╝██████╦╝██║╚█████╗░
echo ██║╚██╔╝██║██╔══██╗██║██╔══██╗██╔══██╗██║░╚═══██╗
echo ██║░╚═╝░██║██║░░██║██║██║░░██║██████╦╝██║██████╔╝
echo ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═════╝░╚═╝╚═════╝░
echo ░██████╗███████╗██████╗░██╗░░░██╗███████╗██████╗░  ░██████╗████████╗░█████╗░██████╗░████████╗███████╗██████╗░
echo ██╔════╝██╔════╝██╔══██╗██║░░░██║██╔════╝██╔══██╗  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
echo ╚█████╗░█████╗░░██████╔╝╚██╗░██╔╝█████╗░░██████╔╝  ╚█████╗░░░░██║░░░███████║██████╔╝░░░██║░░░█████╗░░██████╔╝
echo ░╚═══██╗██╔══╝░░██╔══██╗░╚████╔╝░██╔══╝░░██╔══██╗  ░╚═══██╗░░░██║░░░██╔══██║██╔══██╗░░░██║░░░██╔══╝░░██╔══██╗
echo ██████╔╝███████╗██║░░██║░░╚██╔╝░░███████╗██║░░██║  ██████╔╝░░░██║░░░██║░░██║██║░░██║░░░██║░░░███████╗██║░░██║
echo ╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝  ╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝

:: Настройки
:file
set JDK_URL=https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.zip
set JDK_FOLDER=jdk-21
set SERVER_URL=https://api.purpurmc.org/v2/purpur/1.21.8/2497/download
set SERVER_FILE=Purpur.jar


:: Проверка наличия JDK
if not exist "%JDK_FOLDER%\" (
    echo [INFO] Локальная Java не найдена. Скачиваю JDK 21...
    curl -L -o jdk.zip %JDK_URL%
    if not exist jdk.zip (
        echo [ERROR] Ошибка скачивания JDK. Завершение.
        exit /b
    )
    echo [INFO] Распаковываю JDK...
    powershell -Command "Expand-Archive -Path jdk.zip -DestinationPath ."
    for /d %%d in ("jdk-*") do (
        echo [INFO] Найдена распакованная папка %%d. Переименовываю...
        ren "%%d" "%JDK_FOLDER%"
    )
    if not exist "%JDK_FOLDER%\" (
        echo [ERROR] Ошибка переименования папки JDK. Завершение.
        exit /b
    )
    del jdk.zip
    echo [INFO] Локальная Java установлена.
)

:: Установка пути к локальной Java
set JAVA_CMD=%~dp0%JDK_FOLDER%\bin\java.exe

:: Проверка наличия сервера
if not exist "%SERVER_FILE%" (
    echo [INFO] Сервер не найден. Скачиваю последнюю версию Purpur...
    curl -L -o %SERVER_FILE% %SERVER_URL%
    if not exist %SERVER_FILE% (
        echo [ERROR] Ошибка скачивания сервера. Завершение.
        exit /b
    )
    echo [INFO] Сервер успешно скачан: %SERVER_FILE%.
)

:: Проверка наличия файла с аргументами Java
set JAVA_ARGS_FILE=java_args.txt
if not exist "%JAVA_ARGS_FILE%" (
    echo [INFO] Файл с аргументами Java не найден. Создаю файл с аргументами по умолчанию...
    echo -Xms1000M -Xmx3000M > "%JAVA_ARGS_FILE%"
    echo [INFO] Файл %JAVA_ARGS_FILE% создан с аргументами по умолчанию.
)

:: Чтение аргументов Java из файла
set /p JAVA_ARGS=<%JAVA_ARGS_FILE%

:: Запуск сервера
echo [INFO] Запускаю сервер с использованием локальной Java...

echo ██████╗░██╗░░░██╗██████╗░██████╗░██╗░░░██╗██████╗░
echo ██╔══██╗██║░░░██║██╔══██╗██╔══██╗██║░░░██║██╔══██╗
echo ██████╔╝██║░░░██║██████╔╝██████╔╝██║░░░██║██████╔╝
echo ██╔═══╝░██║░░░██║██╔══██╗██╔═══╝░██║░░░██║██╔══██╗
echo ██║░░░░░╚██████╔╝██║░░██║██║░░░░░╚██████╔╝██║░░██║
echo ╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝
echo "%JAVA_CMD%" %JAVA_ARGS% -jar %SERVER_FILE% nogui

"%JAVA_CMD%" %JAVA_ARGS% -jar %SERVER_FILE% nogui



if not exist "world\" (
echo [INFO] Папка world не найдена. Изменяю eula.txt...
if exist "eula.txt" (
        powershell -Command "(Get-Content -Path 'eula.txt') -replace 'eula=false', 'eula=true' | Set-Content -Path 'eula.txt'"
        echo [INFO] eula.txt успешно обновлён.
    )
goto file
)


pause
goto file