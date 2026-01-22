# Guia de Deploy - Subscription Manager

Este guia explica como fazer deploy do backend Spring Boot em plataformas como Render, Railway ou Fly.io.

## 📋 Variáveis de Ambiente Necessárias

### Banco de Dados (PostgreSQL)
```
SPRING_DATASOURCE_URL=jdbc:postgresql://host:port/database
SPRING_DATASOURCE_USERNAME=usuario
SPRING_DATASOURCE_PASSWORD=senha
```

### JWT
```
APP_JWT_SECRET=uma_string_longa_e_aleatoria_com_pelo_menos_64_caracteres
APP_JWT_ISSUER=subs-app
APP_JWT_ACCESS_TOKEN_MINUTES=60
```

### Firebase (Opcional - para notificações push)
```
APP_FIREBASE_ENABLED=true
APP_FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"...","private_key_id":"...","private_key":"...","client_email":"...","client_id":"...","auth_uri":"...","token_uri":"...","auth_provider_x509_cert_url":"...","client_x509_cert_url":"..."}
```

**Importante:** O `APP_FIREBASE_SERVICE_ACCOUNT_JSON` deve conter o JSON completo do service account, como uma única string (sem quebras de linha). O entrypoint.sh criará o arquivo automaticamente.

### Scheduler (Opcional)
```
APP_SCHEDULER_HORIZON_DAYS=30
APP_SCHEDULER_BATCH_SIZE=500
```

## 🚀 Deploy no Render

1. **Criar um novo Web Service**
   - Conecte seu repositório GitHub
   - Build Command: (deixe vazio, o Dockerfile faz o build)
   - Start Command: (deixe vazio, o entrypoint.sh inicia)

2. **Adicionar PostgreSQL**
   - No dashboard do Render, crie um PostgreSQL database
   - Copie a Internal Database URL
   - Use como `SPRING_DATASOURCE_URL`

3. **Configurar Variáveis de Ambiente**
   - Vá em Environment
   - Adicione todas as variáveis listadas acima
   - Para `APP_FIREBASE_SERVICE_ACCOUNT_JSON`, cole o JSON completo do Firebase

4. **Deploy**
   - Render detectará o Dockerfile automaticamente
   - O build e deploy serão automáticos

## 🚂 Deploy no Railway

1. **Criar novo projeto**
   - Conecte seu repositório
   - Railway detectará o Dockerfile

2. **Adicionar PostgreSQL**
   - No dashboard, adicione PostgreSQL service
   - Railway criará automaticamente as variáveis `DATABASE_URL`
   - Configure `SPRING_DATASOURCE_URL` usando o formato:
     ```
     SPRING_DATASOURCE_URL=jdbc:postgresql://host:port/database
     ```

3. **Configurar Variáveis**
   - Vá em Variables
   - Adicione todas as variáveis necessárias

## ✈️ Deploy no Fly.io

1. **Instalar Fly CLI**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login e criar app**
   ```bash
   fly auth login
   fly launch
   ```

3. **Criar PostgreSQL**
   ```bash
   fly postgres create --name subscription-manager-db
   fly postgres attach subscription-manager-db
   ```

4. **Configurar secrets**
   ```bash
   fly secrets set APP_JWT_SECRET="sua_chave_secreta_aqui"
   fly secrets set APP_FIREBASE_ENABLED="true"
   fly secrets set APP_FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
   ```

5. **Deploy**
   ```bash
   fly deploy
   ```

## 🔐 Como obter o Firebase Service Account JSON

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione seu projeto
3. Vá em **Project Settings** > **Service Accounts**
4. Clique em **Generate New Private Key**
5. Baixe o JSON
6. Copie o conteúdo completo e cole na variável `APP_FIREBASE_SERVICE_ACCOUNT_JSON` (como uma única linha, sem quebras)

**Nota:** Em algumas plataformas, você pode precisar escapar aspas ou usar formato base64. O entrypoint.sh suporta JSON direto.

## 🧪 Teste Local com Docker

Para testar o build localmente antes de fazer deploy:

```bash
# 1. Build da imagem
docker build -t subscription-manager .

# 2. Executar o container (sem Firebase)
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/subsdb \
  -e SPRING_DATASOURCE_USERNAME=subs \
  -e SPRING_DATASOURCE_PASSWORD=subs \
  -e APP_JWT_SECRET=sua_chave_secreta_aqui \
  subscription-manager

# 3. Executar com Firebase (substitua {...} pelo JSON completo)
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/subsdb \
  -e SPRING_DATASOURCE_USERNAME=subs \
  -e SPRING_DATASOURCE_PASSWORD=subs \
  -e APP_JWT_SECRET=sua_chave_secreta_aqui \
  -e APP_FIREBASE_ENABLED=true \
  -e APP_FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}' \
  subscription-manager
```

**Nota:** Para conectar ao PostgreSQL local, use `host.docker.internal` no lugar de `localhost`.

## ✅ Verificação

Após o deploy, verifique os logs:
- Deve aparecer: `[FirebaseConfig] ✅ Firebase initialized successfully!` (se habilitado)
- Deve aparecer: `[Entrypoint] ✅ Firebase service account file created` (se configurado)
- A aplicação deve iniciar na porta 8080

## 🐛 Troubleshooting

- **Firebase não inicializa:** Verifique se `APP_FIREBASE_ENABLED=true` e se o JSON está correto
- **Erro de conexão com DB:** Verifique `SPRING_DATASOURCE_URL` (deve usar o host interno da plataforma)
- **Build falha:** Verifique se o Dockerfile está na raiz do projeto
