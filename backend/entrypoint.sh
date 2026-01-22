#!/usr/bin/env sh
set -e

# Se Firebase está habilitado e temos o JSON como env var, criar arquivo
if [ "${APP_FIREBASE_ENABLED}" = "true" ] && [ -n "${APP_FIREBASE_SERVICE_ACCOUNT_JSON}" ]; then
  echo "[Entrypoint] Creating Firebase service account file from env var..."
  # Usa printf para evitar problemas com aspas no JSON
  printf '%s\n' "${APP_FIREBASE_SERVICE_ACCOUNT_JSON}" > /app/firebase-service-account.json
  export APP_FIREBASE_SERVICE_ACCOUNT_PATH="/app/firebase-service-account.json"
  echo "[Entrypoint] ✅ Firebase service account file created at /app/firebase-service-account.json"
fi

# Executar a aplicação
exec java -jar /app/app.jar
