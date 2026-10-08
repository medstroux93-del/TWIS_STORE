@echo off
chcp 65001 > nul
title متجر تويس للتسوق - Twis Store
echo ========================================================
echo          جاري تشغيل متجر تويس للتسوق...
echo ========================================================
echo.
echo سيتم تشغيل الخادم المحلي وفتح المتجر تلقائياً في متصفحك.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
