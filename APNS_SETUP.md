# Guia de Configuração APNS Token - iOS

## O que é APNS Token?

**APNS** (Apple Push Notification Service) é o serviço da Apple para enviar notificações push aos dispositivos iOS.

**Fluxo:**
1. App iOS registra no APNS → recebe **APNS Token**
2. Firebase usa o APNS Token → converte em **FCM Token** 
3. Backend usa o FCM Token → envia notificações via Firebase

**No iOS, você PRECISA do APNS Token antes de obter o FCM Token!**

---

## Como Configurar (Passo a Passo)

### 1. Configurar no Xcode

Abra o projeto no Xcode:

```bash
cd flutter_app/ios
open Runner.xcworkspace
```

#### Adicionar Capabilities:

1. No Xcode, selecione o target **"Runner"** (ícone azul no topo)
2. Vá na aba **"Signing & Capabilities"**
3. Clique em **"+ Capability"**
4. Adicione **"Push Notifications"**
5. Adicione **"Background Modes"** e marque:
   - ✅ Remote notifications
   - ✅ Background fetch

### 2. Verificar Entitlements

Após adicionar as capabilities, o Xcode deve criar um arquivo `Runner.entitlements`.

Verifique se contém:

```xml
<key>aps-environment</key>
<string>development</string>
```

(Ou `production` para builds de release)

### 3. Configurar APNs no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione seu projeto
3. Vá em **Project Settings** > **Cloud Messaging**
4. Na aba **"Apple app configuration"**:
   - Faça upload da **APNs Auth Key** (.p8)
   - Ou configure um **APNs Certificate**

**Como obter APNs Auth Key:**
- Acesse [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
- Clique em "+" para criar nova key
- Baixe o arquivo .p8
- Anote o **Key ID**
- Faça upload no Firebase Console

### 4. Verificar Bundle ID

O Bundle ID no Xcode deve ser o **mesmo** em:
- Xcode (Runner target)
- Apple Developer Portal
- Firebase Console

Atual: `com.example.subscriptionManagerFlutter`

---

## Por que não funciona?

### ❌ Simulador iOS
APNS Token **não funciona** no simulador. Use um **dispositivo físico**.

### ❌ Capabilities não configuradas
Se Push Notifications não estiver habilitado no Xcode, o APNS Token será `null`.

### ❌ APNs Key não configurada no Firebase
O Firebase precisa da chave APNs para conectar com a Apple.

### ❌ Permissões negadas
O usuário precisa aceitar notificações quando solicitado.

### ❌ Código assinado incorretamente
O provisioning profile precisa incluir Push Notifications.

---

## Testar se está funcionando

1. Execute no **iPhone físico** (não simulador)
2. Faça login/registro no app
3. Aceite as permissões de notificação
4. Verifique os logs:

```
FCM: Getting APNS token (required for iOS)...
FCM: ✅ APNS token obtained: ...
FCM: ✅ FCM token obtained: ...
FCM: ✅ Token registered successfully!
```

---

## Solução Rápida

Se o APNS Token ainda não aparecer:

1. ✅ Abra o Xcode: `open ios/Runner.xcworkspace`
2. ✅ Vá em Signing & Capabilities
3. ✅ Adicione "Push Notifications"
4. ✅ Adicione "Background Modes" > Remote notifications
5. ✅ Certifique-se de estar usando **dispositivo físico**
6. ✅ Reinicie o app completamente

---

## Nota Importante

O código atual **já tenta obter o APNS Token** antes do FCM Token, mas **só funciona** se:
- ✅ Xcode tiver Push Notifications habilitado
- ✅ Rodar em dispositivo físico (não simulador)
- ✅ Usuário aceitar permissões
- ✅ Firebase tiver APNs configurado
