@echo off
setlocal
cd /d "%~dp0.."
if not exist api\appsettings.Local.json (
  copy /Y api\appsettings.json api\appsettings.Local.json >nul
  echo.
  echo Edita api\appsettings.Local.json y cambia ApiKey por una clave secreta.
  echo Luego vuelve a ejecutar este archivo.
  pause
  exit /b 1
)
where dotnet >nul 2>&1 || (echo Falta .NET 8. Instala el runtime de .NET 8 y vuelve a intentar.&pause&exit /b 1)
dotnet run --project api\FerrariPOS.MobileBridge.csproj --configuration Release
pause
