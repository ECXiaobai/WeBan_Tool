@echo off
REM WeBan-merged Windows build script (offline distribution build)
REM Requires: Python 3.12+ and pyinstaller (pip install pyinstaller)
cd /d "%~dp0"

python -m py_compile main.py client.py api.py captcha.py || (echo SYNTAX CHECK FAILED & exit /b 1)

pyinstaller --noconfirm --onefile ^
  --name "WeBan-windows-x64.exe" ^
  --add-data "captcha_model.onnx;." ^
  --add-data "answer/answer.json;answer/answer.json" ^
  --add-data "config.example.toml;." ^
  --add-data "pyproject.toml;." ^
  --hidden-import nodriver ^
  --hidden-import loguru ^
  --hidden-import numpy ^
  --hidden-import cv2 ^
  --collect-submodules nodriver ^
  main.py

echo.
echo BUILD DONE: dist\WeBan-windows-x64.exe
