@echo off
title La Cripta Gamer - Launcher
echo ========================================================
echo         INICIANDO LA CRIPTA GAMER
echo ========================================================
echo.
echo 1. Iniciando monitor de juegos de Windows en segundo plano...
start /B python monitor_pc.py
timeout /t 1 /nobreak >nul
echo.
echo 2. Lanzando aplicacion en Microsoft Edge...
echo (Presiona 'r' para Hot Reload o 'q' para salir)
echo.
flutter run -d edge
