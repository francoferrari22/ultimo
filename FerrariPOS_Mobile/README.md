# FerrariPOS Mobile

Aplicación Android de consulta para Ferrari's Punto de Venta V72.2.24.

## Arquitectura sencilla

- `mobile/`: aplicación Flutter Android.
- `api/`: puente ASP.NET Core .NET 8 que lee la SQLite local de FerrariPOS en modo lectura.
- `.github/workflows/android.yml`: genera el APK automáticamente en GitHub Actions.

La app no modifica la base de datos del POS. El puente expone únicamente consultas de ventas, créditos, clientes, productos, caja y dashboard.

## Flujo

FerrariPOS Windows -> SQLite local -> FerrariPOS Mobile Bridge -> Android

## Configuración rápida

1. Instalar .NET 8 Runtime/Desktop Runtime en la PC donde está FerrariPOS.
2. Copiar `api/appsettings.json` a `api/appsettings.Local.json` y cambiar `ApiKey`.
3. Ejecutar `scripts/INICIAR_BRIDGE.bat`.
4. Para probar desde el mismo PC: abrir `http://localhost:5077/health`.
5. Para el teléfono en la misma Wi-Fi usar la IP de la PC, por ejemplo `http://192.168.1.50:5077`.
6. En la app introducir esa dirección y la misma API Key.

Para acceso fuera de la casa/local, usar un túnel HTTPS (Cloudflare Tunnel, Tailscale Funnel o similar). No exponer el puerto HTTP directamente a Internet.

## GitHub sin Android Studio

Subir este repositorio a GitHub. El workflow `Android APK` crea el proyecto Android con Flutter, instala dependencias y compila `app-release.apk`. El APK aparece como artefacto de la ejecución.
