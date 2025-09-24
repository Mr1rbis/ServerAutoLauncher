#!/bin/bash

echo -e "███╗░░░███╗██████╗░██╗██████╗░██████╗░██╗░██████╗"
echo -e "████╗░████║██╔══██╗██║██╔══██╗██╔══██╗██║██╔════╝"
echo -e "██╔████╔██║██████╔╝██║██████╔╝██████╦╝██║╚█████╗░"
echo -e "██║╚██╔╝██║██╔══██╗██║██╔══██╗██╔══██╗██║░╚═══██╗"
echo -e "██║░╚═╝░██║██║░░██║██║██║░░██║██████╦╝██║██████╔╝"
echo -e "╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═════╝░╚═╝╚═════╝░"
echo -e "░██████╗███████╗██████╗░██╗░░░██╗███████╗██████╗░  ░██████╗████████╗░█████╗░██████╗░████████╗███████╗██████╗░"
echo -e "██╔════╝██╔════╝██╔══██╗██║░░░██║██╔════╝██╔══██╗  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗"
echo -e "╚█████╗░█████╗░░██████╔╝╚██╗░██╔╝█████╗░░██████╔╝  ╚█████╗░░░░██║░░░███████║██████╔╝░░░██║░░░█████╗░░██████╔╝"
echo -e "░╚═══██╗██╔══╝░░██╔══██╗░╚████╔╝░██╔══╝░░██╔══██╗  ░╚═══██╗░░░██║░░░██╔══██║██╔══██╗░░░██║░░░██╔══╝░░██╔══██╗"
echo -e "██████╔╝███████╗██║░░██║░░╚██╔╝░░███████╗██║░░██║  ██████╔╝░░░██║░░░██║░░██║██║░░██║░░░██║░░░███████╗██║░░██║"
echo -e "╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝  ╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝"

# Настройки
while true; do
    JDK_URL="https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz"
    JDK_FOLDER="jdk-21"
    SERVER_URL="https://fill-data.papermc.io/v1/objects/8de7c52c3b02403503d16fac58003f1efef7dd7a0256786843927fa92ee57f1e/paper-1.21.8-60.jar"
    SERVER_FILE="Paper.jar"

    # Проверка наличия JDK
    if [ ! -d "$JDK_FOLDER" ]; then
        echo "[INFO] Локальная Java не найдена. Скачиваю JDK 21..."
        curl -L -o jdk.tar.gz $JDK_URL
        if [ ! -f jdk.tar.gz ]; then
            echo "[ERROR] Ошибка скачивания JDK. Завершение."
            exit 1
        fi
        echo "[INFO] Распаковываю JDK..."
        tar -xzf jdk.tar.gz
        rm jdk.tar.gz
        JDK_EXTRACTED=$(ls -d jdk-*/)
        echo "[INFO] Найдена распакованная папка $JDK_EXTRACTED. Переименовываю..."
        mv "$JDK_EXTRACTED" "$JDK_FOLDER"
        if [ ! -d "$JDK_FOLDER" ]; then
            echo "[ERROR] Ошибка переименования папки JDK. Завершение."
            exit 1
        fi
        echo "[INFO] Локальная Java установлена."
    fi

    # Установка пути к локальной Java
    JAVA_CMD="$(pwd)/$JDK_FOLDER/bin/java"

    # Проверка наличия сервера
    if [ ! -f "$SERVER_FILE" ]; then
        echo "[INFO] Сервер не найден. Скачиваю последнюю версию Purpur..."
        curl -L -o $SERVER_FILE $SERVER_URL
        if [ ! -f $SERVER_FILE ]; then
            echo "[ERROR] Ошибка скачивания сервера. Завершение."
            exit 1
        fi
        echo "[INFO] Сервер успешно скачан: $SERVER_FILE."
    fi

    # Проверка наличия файла с аргументами Java
    JAVA_ARGS_FILE="java_args.txt"
    if [ ! -f "$JAVA_ARGS_FILE" ]; then
        echo "[INFO] Файл с аргументами Java не найден. Создаю файл с аргументами по умолчанию..."
        echo "-Xms1000M -Xmx3000M" > "$JAVA_ARGS_FILE"
        echo "[INFO] Файл $JAVA_ARGS_FILE создан с аргументами по умолчанию."
    fi

    # Чтение аргументов Java из файла
    JAVA_ARGS=$(cat "$JAVA_ARGS_FILE")

    # Запуск сервера с использованием аргументов из файла
    echo -e "██████╗░░█████╗░██████╗░███████╗██████╗░"
    echo -e "██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗"
    echo -e "██████╔╝███████║██████╔╝█████╗░░██████╔╝"
    echo -e "██╔═══╝░██╔══██║██╔═══╝░██╔══╝░░██╔══██╗"
    echo -e "██║░░░░░██║░░██║██║░░░░░███████╗██║░░██║"
    echo -e "╚═╝░░░░░╚═╝░░╚═╝╚═╝░░░░░╚══════╝╚═╝░░╚═╝"
    echo -e "$JAVA_CMD $JAVA_ARGS -jar $SERVER_FILE nogui"
    "$JAVA_CMD" $JAVA_ARGS -jar "$SERVER_FILE" nogui

    # Проверка наличия папки world
    if [ -d "world" ]; then
        while true; do
            read -p "Папка 'world' найдена. Вы хотите остановить сервер (q) или перезапустить сервер (r)? " choice
            case "$choice" in
                r|R) echo "[INFO] Перезапуск сервера."; break ;;
                q|Q) echo "[INFO] Завершение программы."; exit 0 ;;
                *) echo "Пожалуйста, введите r для перезапуска или q для выхода." ;;
            esac
        done
    else
        echo "[INFO] Папка world не найдена. Изменяю eula.txt..."
        if [ -f "eula.txt" ]; then
            sed -i 's/eula=false/eula=true/' eula.txt
            echo "[INFO] eula.txt успешно обновлён."
        fi
    fi
done
