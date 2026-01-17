# Week 3: Alert System with FCM Push Notifications

## Implementação Completa

### ✅ Funcionalidades Implementadas

1. **Alert Rules Padrão (7, 3, 1, 0 dias)**
   - Criados automaticamente na criação de usuário
   - Implementado em `AuthService.register()`

2. **Scheduler A: Geração de Alertas**
   - Executa diariamente às 03:00 (timezone: America/Sao_Paulo)
   - Cria alertas futuros para renovações nos próximos 30 dias
   - Idempotente: evita duplicatas

3. **Scheduler B: Envio de Alertas**
   - Executa a cada 5 minutos
   - Envia alertas pendentes que estão vencidos
   - Processa um por um para garantir idempotência

4. **Integração FCM Real**
   - PushSender melhorado com logging e tratamento de erros
   - Suporte a deep linking no payload
   - Tratamento de tokens inválidos

5. **Deep Linking**
   - Payload inclui `deepLink` e `subscriptionId`
   - Flutter implementa navegação para detalhes da subscription

---

## Configuração Backend

### 1. Firebase Service Account

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie/Selecione seu projeto
3. Vá em **Project Settings** > **Service Accounts**
4. Clique em **Generate New Private Key**
5. Salve o JSON como `firebase-service-account.json`
6. Coloque em `backend/src/main/resources/firebase-service-account.json`

### 2. application.yml

```yaml
app:
  firebase:
    enabled: true  # Mude para true quando tiver o service account
    serviceAccountPath: "classpath:firebase-service-account.json"
  deepLink:
    baseUrl: "subscriptionmanager://subscription"
```

### 3. Verificar Alert Rules Padrão

Os alert rules (7, 3, 1, 0 dias) são criados automaticamente no registro:

```java
// AuthService.java linha 47-55
List<Integer> defaults = List.of(7, 3, 1, 0);
for (Integer d : defaults) {
    AlertRule r = new AlertRule();
    r.setUserId(user.getId());
    r.setDaysBefore(d);
    r.setEnabled(true);
    alertRuleRepo.save(r);
}
```

---

## Configuração Flutter

### 1. Instalar Dependências

```bash
cd flutter_app
flutter pub get
```

### 2. Firebase Setup

#### iOS:
1. Baixe `GoogleService-Info.plist` do Firebase Console
2. Adicione em `ios/Runner/GoogleService-Info.plist`
3. Configure deep linking em `ios/Runner/Info.plist`:

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

#### Android:
1. Baixe `google-services.json` do Firebase Console
2. Adicione em `android/app/google-services.json`
3. Configure deep linking em `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="subscriptionmanager" />
</intent-filter>
```

### 3. Inicialização

O FCM é inicializado automaticamente após login em `main.dart`.

---

## Exemplo de Payload FCM

```json
{
  "token": "FCM_TOKEN_DO_DEVICE",
  "notification": {
    "title": "Renovação em 7 dias",
    "body": "Netflix renova em 7 dias (29.90 BRL)"
  },
  "data": {
    "type": "subscription_renewal",
    "subscriptionId": "550e8400-e29b-41d4-a716-446655440000",
    "deepLink": "subscriptionmanager://subscription/550e8400-e29b-41d4-a716-446655440000",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

### Estrutura do Payload

- **notification**: Exibido na barra de notificações
- **data.type**: Tipo da notificação (`subscription_renewal`)
- **data.subscriptionId**: ID da subscription para navegação
- **data.deepLink**: URL de deep link completo
- **data.click_action**: Ação para Android

---

## Checklist de Testes

### Backend

#### 1. Testar Criação de Alert Rules Padrão
- [ ] Registrar novo usuário via API
- [ ] Verificar no banco: `SELECT * FROM alert_rules WHERE user_id = 'USER_ID'`
- [ ] Deve ter 4 regras: 7, 3, 1, 0 dias (todas enabled=true)

#### 2. Testar Scheduler A (Geração de Alertas)
- [ ] Criar subscription com `nextRenewalAt` nos próximos 30 dias
- [ ] Executar manualmente: `generateUpcomingAlerts()`
- [ ] Verificar logs: deve criar alertas baseados nas regras
- [ ] Verificar no banco: `SELECT * FROM alerts WHERE subscription_id = 'SUB_ID'`
- [ ] Testar idempotência: executar 2x, deve criar apenas uma vez

#### 3. Testar Scheduler B (Envio de Alertas)
- [ ] Criar alert manual com `scheduled_at` no passado e `status='PENDING'`
- [ ] Executar manualmente: `dispatchPendingAlerts()`
- [ ] Verificar logs: deve tentar enviar via FCM
- [ ] Verificar no banco: `status` deve mudar para 'SENT' ou 'FAILED'
- [ ] Se FCM disabled: verificar log "[FCM disabled] would send..."

#### 4. Testar Device Registration (Idempotência)
- [ ] POST `/v1/devices` com token T1
- [ ] POST `/v1/devices` novamente com mesmo token T1
- [ ] Verificar: deve atualizar device existente, não criar duplicado
- [ ] POST `/v1/devices` com token T2 diferente
- [ ] Verificar: deve criar novo device

#### 5. Testar PushSender
- [ ] Com FCM enabled: verificar envio real
- [ ] Com FCM disabled: verificar logs
- [ ] Testar com token inválido: verificar tratamento de erro
- [ ] Verificar deep link no payload

### Flutter

#### 6. Testar FCM Token Registration
- [ ] Fazer login no app
- [ ] Verificar logs: "FCM token registered successfully"
- [ ] Verificar no backend: device deve estar registrado
- [ ] Testar refresh token: desinstalar/reinstalar app

#### 7. Testar Notificações Foreground
- [ ] App aberto
- [ ] Enviar push via Firebase Console
- [ ] Verificar logs no console Flutter
- [ ] Verificar que notificação aparece (se implementado UI)

#### 8. Testar Notificações Background
- [ ] App em background
- [ ] Enviar push via Firebase Console
- [ ] Verificar que notificação aparece
- [ ] Tocar na notificação
- [ ] Verificar que app abre e navega para subscription

#### 9. Testar Deep Linking
- [ ] App fechado
- [ ] Enviar push com deep link
- [ ] Tocar na notificação
- [ ] Verificar que app abre na tela de detalhes da subscription
- [ ] Testar deep link direto: `subscriptionmanager://subscription/SUBSCRIPTION_ID`

#### 10. Testar Navegação
- [ ] Receber push enquanto app está aberto
- [ ] Tocar na notificação
- [ ] Verificar navegação para `SubscriptionDetailScreen`
- [ ] Verificar que subscriptionId está correto

---

## Comandos Úteis

### Backend

```bash
# Verificar alertas criados
psql -d subsdb -c "SELECT id, subscription_id, days_before, scheduled_at, status FROM alerts ORDER BY created_at DESC LIMIT 10;"

# Verificar alert rules
psql -d subsdb -c "SELECT user_id, days_before, enabled FROM alert_rules;"

# Verificar devices registrados
psql -d subsdb -c "SELECT user_id, platform, LEFT(fcm_token, 20) as token_preview FROM user_devices;"

# Forçar execução do scheduler (via código ou teste)
# Criar teste unitário ou usar actuator endpoint
```

### Flutter

```bash
# Ver logs do Flutter
flutter logs

# Testar deep link (iOS Simulator)
xcrun simctl openurl booted "subscriptionmanager://subscription/SUBSCRIPTION_ID"

# Testar deep link (Android)
adb shell am start -a android.intent.action.VIEW -d "subscriptionmanager://subscription/SUBSCRIPTION_ID"
```

---

## Troubleshooting

### Backend

**Problema**: FCM não inicializa
- Verificar: `app.firebase.enabled=true` em `application.yml`
- Verificar: arquivo `firebase-service-account.json` existe em `src/main/resources/`
- Verificar logs: deve aparecer "Firebase initialized successfully"

**Problema**: Alertas não são criados
- Verificar: subscription está `is_active=true`
- Verificar: `nextRenewalAt` está dentro do horizonte (30 dias)
- Verificar: user tem alert rules enabled
- Verificar logs do scheduler

**Problema**: Push não é enviado
- Verificar: device está registrado no banco
- Verificar: FCM token é válido
- Verificar logs: erros do Firebase
- Testar com FCM disabled primeiro para ver logs

### Flutter

**Problema**: Token não é registrado
- Verificar: usuário está logado
- Verificar: permissões de notificação foram concedidas
- Verificar logs: "FCM token registered successfully"
- Verificar: API `/v1/devices` está acessível

**Problema**: Notificações não aparecem
- Verificar: permissões foram concedidas
- Verificar: Firebase está configurado corretamente
- Verificar: `GoogleService-Info.plist` (iOS) ou `google-services.json` (Android)
- Testar via Firebase Console diretamente

**Problema**: Deep link não funciona
- Verificar: URL scheme configurado em `Info.plist` (iOS) e `AndroidManifest.xml` (Android)
- Verificar: formato do deep link: `subscriptionmanager://subscription/{id}`
- Verificar logs: "Deep link received: ..."

---

## Arquivos Modificados/Criados

### Backend
- ✅ `AlertScheduler.java` - Melhorado com logging e idempotência
- ✅ `AlertService.java` - Melhorado com validação e formatação
- ✅ `PushSender.java` - FCM real com deep linking
- ✅ `DeviceController.java` - Idempotência para tokens
- ✅ `FirebaseConfig.java` - Melhorado com logging
- ✅ `application.yml` - Adicionado `deepLink.baseUrl`

### Flutter
- ✅ `pubspec.yaml` - Adicionado firebase_core, firebase_messaging, uni_links
- ✅ `lib/services/fcm_service.dart` - Novo serviço FCM
- ✅ `lib/services/deep_link_service.dart` - Novo serviço deep linking
- ✅ `lib/main.dart` - Inicialização FCM e deep links
- ✅ `lib/screens/subscription_detail_screen.dart` - Nova tela para deep linking

---

## Próximos Passos

1. **Configurar Firebase no Flutter**:
   - Adicionar `GoogleService-Info.plist` (iOS)
   - Adicionar `google-services.json` (Android)
   - Configurar URL schemes

2. **Testar End-to-End**:
   - Criar subscription
   - Aguardar scheduler criar alertas
   - Aguardar scheduler enviar push
   - Verificar deep linking

3. **Produção**:
   - Habilitar FCM: `app.firebase.enabled=true`
   - Configurar timezone do scheduler se necessário
   - Monitorar logs e métricas

---

## Notas Importantes

- **Idempotência**: Sistema garante que alertas não são duplicados
- **Timezone**: Scheduler A usa `America/Sao_Paulo`, ajuste se necessário
- **Horizonte**: Alertas são criados para próximos 30 dias (configurável)
- **FCM Disabled**: Por padrão FCM está desabilitado, habilite após configurar Firebase
- **Deep Link**: Formato `subscriptionmanager://subscription/{subscriptionId}`
