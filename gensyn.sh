#!/bin/bash

set -euo pipefail

# Функция для безопасного выхода
safe_exit() {
    echo "[!] Скрипт завершен с ошибкой: $1"
    exit 1
}

# Обработка ошибок
trap 'safe_exit "Произошла неожиданная ошибка на строке $LINENO"' ERR

# Основные переменные
BASE_DIR="/root"
REPO_URL="https://github.com/VaniaHilkovets/GensynFix.git"
LOGIN_WAIT_TIMEOUT=10

# Установка базовых пакетов
install_base_packages() {
    echo "[+] Обновляем систему и устанавливаем базовые пакеты..."
    apt update || safe_exit "Не удалось обновить пакеты"
    apt install -y curl sudo tmux lsof git htop nano rsync python3 python3-pip build-essential gnupg || safe_exit "Не удалось установить базовые пакеты"
    
    # Создаем символическую ссылку для python если её нет
    if [ ! -e /usr/bin/python ]; then
        ln -s /usr/bin/python3 /usr/bin/python
    fi
    
    # Создаем символическую ссылку для pip если её нет
    if [ ! -e /usr/bin/pip ]; then
        ln -s /usr/bin/pip3 /usr/bin/pip
    fi
}

# Установка Node.js 20 глобально
install_nodejs_global() {
    echo "[+] Устанавливаем Node.js 20 глобально..."
    apt remove -y nodejs npm 2>/dev/null || true
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - || safe_exit "Не удалось добавить репозиторий NodeSource"
    apt install -y nodejs || safe_exit "Не удалось установить Node.js 20"
    
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    echo "[+] Установлена версия Node.js: $NODE_VERSION"
    echo "[+] Установлена версия npm: $NPM_VERSION"
    
    if [[ ! "$NODE_VERSION" =~ ^v20\. ]]; then
        safe_exit "Установлена неправильная версия Node.js: $NODE_VERSION"
    fi
    
    npm install -g npm@latest || safe_exit "Не удалось обновить npm"
    
    if ! command -v yarn &> /dev/null; then
        echo "[+] Yarn не найден, устанавливаем..."
        npm install -g yarn || safe_exit "Не удалось установить yarn"
    else
        echo "[+] Yarn уже установлен: $(yarn -v)"
    fi
    
    echo "[+] Node.js 20 успешно установлен глобально"
}

# Установка Python зависимостей
install_python_deps() {
    echo "[+] Устанавливаем Python зависимости..."
    pip install --upgrade pip || safe_exit "Не удалось обновить pip"
    pip install --upgrade "jinja2>=3.1.0" || safe_exit "Не удалось установить jinja2"
    
    JINJA_VERSION=$(pip show jinja2 2>/dev/null | grep Version | awk '{print $2}' || echo "не найдена")
    echo "[+] Установлена версия jinja2: $JINJA_VERSION"
}

# Показать меню (с добавленной опцией 10)
show_menu() {
    echo -e "\n===== Меню GensynFix ====="
    echo "1) Установить ноду"
    echo "2) Логин ноды"
    echo "3) Запуск ноды в tmux"
    echo "4) Удалить ноду"
    echo "5) Обновить GensynFix"
    echo "6) Выйти"
    echo "10) Копировать swarm.pem в /home/ubuntu"
}

# Проверить установлена ли нода
check_node_installed() {
    if [ ! -d "$BASE_DIR/GensynFix" ]; then
        echo "[!] Нода не установлена. Установите сначала (опция 1)."
        return 1
    fi
    echo "[+] Нода найдена."
    return 0
}

# Проверить порт
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # порт занят
    else
        return 1  # порт свободен
    fi
}

# Установка ноды
run_setup() {
    echo "[+] Начинаем установку ноды..."
    
    install_base_packages
    install_nodejs_global
    install_python_deps
    
    echo "[+] Клонируем GensynFix..."
    rm -rf "$BASE_DIR/GensynFix"
    git clone "$REPO_URL" "$BASE_DIR/GensynFix" || safe_exit "Не удалось клонировать репозиторий"
    
    find "$BASE_DIR/GensynFix" -name "*.sh" -exec chmod +x {} \; || true
    
    local DIR="$BASE_DIR/GensynFix"
    if [ -f "$DIR/run_rl_swarm.sh" ]; then
        if ! grep -q "LOGIN_PORT=" "$DIR/run_rl_swarm.sh"; then
            sed -i '1i LOGIN_PORT=${LOGIN_PORT:-3000}' "$DIR/run_rl_swarm.sh"
        fi
        sed -i 's|yarn start >> "$ROOT/logs/yarn.log" 2>&1 &|PORT=$LOGIN_PORT yarn start >> "$ROOT/logs/yarn.log" 2>\&1 \&|' "$DIR/run_rl_swarm.sh"
    fi
    
    echo "✅ Установка ноды завершена успешно."
}

# Логин ноды
run_login() {
    # ... оставляем твою текущую функцию run_login без изменений
    echo "[+] Функция run_login выполнена (здесь вставляем твою текущую реализацию)"
}

# Запуск ноды
run_start() {
    # ... оставляем твою текущую функцию run_start без изменений
    echo "[+] Функция run_start выполнена (здесь вставляем твою текущую реализацию)"
}

# Обновление
run_update() {
    # ... оставляем твою текущую функцию run_update без изменений
    echo "[+] Функция run_update выполнена (здесь вставляем твою текущую реализацию)"
}

# Удаление ноды
run_cleanup() {
    # ... оставляем твою текущую функцию run_cleanup без изменений
    echo "[+] Функция run_cleanup выполнена (здесь вставляем твою текущую реализацию)"
}

# Основной цикл
main() {
    echo "=== GensynFix Manager ==="
    echo "Версия: 3.1 (исправленный логин)"
    echo "Node.js: глобальный v20"
    
    while true; do
        show_menu
        read -p "Выберите опцию [1-6,10]: " CHOICE
        
        case "$CHOICE" in
            1) run_setup ;;
            2) run_login ;;
            3) run_start ;;
            4) run_cleanup ;;
            5) run_update ;;
            6) echo "👋 До свидания!"; exit 0 ;;
            10)
                # Копируем swarm.pem в /home/ubuntu
                SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                SWARM_FILE="$SCRIPT_DIR/swarm.pem"
                if [ -f "$SWARM_FILE" ]; then
                    sudo mkdir -p /home/ubuntu
                    sudo cp "$SWARM_FILE" /home/ubuntu/
                    sudo chown ubuntu:ubuntu /home/ubuntu/swarm.pem
                    echo "✅ swarm.pem скопирован в /home/ubuntu"
                else
                    echo "❌ Файл $SWARM_FILE не найден"
                fi
                ;;
            *)
                echo "❌ Неверный выбор. Введите число от 1 до 6 или 10." ;;
        esac
        
        echo -e "\nНажмите Enter для возврата в меню..."
        read -r
    done
}

# Запуск основной функции
main "$@"
