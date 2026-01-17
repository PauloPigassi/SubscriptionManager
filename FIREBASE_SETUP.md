# Firebase Setup Guide

## Backend Setup

### 1. Obter Service Account JSON

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione ou crie um projeto
3. Vá em **⚙️ Project Settings** > **Service Accounts**
4. Clique em **Generate New Private Key**
5. Baixe o arquivo JSON

### 2. Configurar no Backend

1. Renomeie o arquivo para `firebase-service-account.json`
2. Coloque em: `backend/src/main/resources/firebase-service-account.json`
3. Atualize `application.yml`:

```yaml
app:
  firebase:
    enabled: true
    serviceAccountPath: "classpath:firebase-service-account.json"
```

### 3. Verificar

Ao iniciar o backend, deve aparecer no log:
```
Firebase initialized successfully
```

---

## Flutter Setup

### iOS

1. **Baixar GoogleService-Info.plist**
   - Firebase Console > Project Settings > Your apps > iOS app
   - Baixe `GoogleService-Info.plist`

2. **Adicionar ao projeto**
   - Coloque em `flutter_app/ios/Runner/GoogleService-Info.plist`
   - Adicione ao Xcode: File > Add Files to "Runner"

3. **Configurar Deep Linking**
   - Abra `ios/Runner/Info.plist`
   - Adicione:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>subscriptionmanager</string>
        </array>
    </dict>
</array>
```

### Android

1. **Baixar google-services.json**
   - Firebase Console > Project Settings > Your apps > Android app
   - Baixe `google-services.json`

2. **Adicionar ao projeto**
   - Coloque em `flutter_app/android/app/google-services.json`

3. **Atualizar build.gradle**
   - `android/build.gradle` (project level):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

   - `android/app/build.gradle` (app level):
```gradle
apply plugin: 'com.google.gms.google-services'
```

4. **Configurar Deep Linking**
   - Abra `android/app/src/main/AndroidManifest.xml`
   - Dentro de `<activity>` principal, adicione:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="subscriptionmanager" />
</intent-filter>
```

---

## Testar Configuração

### Backend

```bash
# Verificar se Firebase inicializa
mvn spring-boot:run
# Deve aparecer: "Firebase initialized successfully"
```

### Flutter

```bash
cd flutter_app
flutter pub get
flutter run
# Verificar logs: "FCM token registered successfully"
```

---

## Troubleshooting

**iOS**: Se `GoogleService-Info.plist` não é encontrado, verifique se está no target "Runner" no Xcode.

**Android**: Se build falha, verifique se `google-services.json` está em `android/app/` e se o plugin está aplicado.

**FCM Token**: Se token não é registrado, verifique permissões de notificação e se usuário está logado.
