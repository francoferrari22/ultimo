# Configuración sencilla de GitHub

1. Crear un repositorio nuevo llamado `FerrariPOS-Mobile`.
2. Subir todo el contenido de esta carpeta.
3. Abrir la pestaña **Actions**.
4. Ejecutar **Android APK** con **Run workflow**.
5. Esperar a que termine.
6. Entrar en la ejecución y descargar el artefacto **FerrariPOS-Android**.
7. Dentro estará `app-release.apk`.

No hace falta Android Studio.

## Conexión por Wi-Fi local

En la PC del POS, ejecutar `scripts/INICIAR_BRIDGE.bat`. Averiguar la IP local con `ipconfig` y usar en Android algo como:

`http://192.168.1.50:5077`

La PC y el teléfono deben estar en la misma red Wi-Fi.

## Seguridad

Cambiar la API Key. Para Internet público usar HTTPS/túnel. No abrir el puerto 5077 directamente en el router.
