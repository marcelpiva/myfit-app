# Plano de Publicação no TestFlight

## Informações do App
- **Bundle ID:** `com.marcelpiva.myfitplatform`
- **Team ID:** `9A8VXV8G83`
- **Nome:** My Fit
- **Versão:** 1.0.0 (Build 1)

---

## Pré-requisitos

### 1. Apple Developer Program
- [ ] Confirmar que você está inscrito no Apple Developer Program ($99/ano)
- [ ] Acessar https://developer.apple.com e verificar status da conta

### 2. Certificados e Provisioning Profiles
- [ ] Verificar se existe um **Distribution Certificate** válido
- [ ] Criar **App ID** no Apple Developer Portal (se não existir)
- [ ] Criar **Distribution Provisioning Profile**

---

## Etapas de Implementação

### Fase 1: Configuração no Apple Developer Portal

1. **Acessar** https://developer.apple.com/account
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. **Criar App ID** (se não existir):
   - Platform: iOS
   - Bundle ID: `com.marcelpiva.myfitplatform`
   - Capabilities: Push Notifications (opcional), Face ID, etc.

4. **Criar Distribution Certificate** (se não existir):
   - Certificates → + → Apple Distribution
   - Seguir instruções para gerar CSR no Keychain

5. **Criar Provisioning Profile**:
   - Profiles → + → App Store Connect
   - Selecionar App ID e Certificate
   - Download e instalar

### Fase 2: Configuração no App Store Connect

1. **Acessar** https://appstoreconnect.apple.com
2. **My Apps** → **+** → **New App**
3. **Preencher informações:**
   - Platform: iOS
   - Name: My Fit (ou MyFit Platform)
   - Primary Language: Portuguese (Brazil)
   - Bundle ID: com.marcelpiva.myfitplatform
   - SKU: myfit-platform-2026
   - User Access: Full Access

4. **App Information:**
   - Categoria: Health & Fitness
   - Subcategoria: Fitness (opcional)
   - Content Rights: Não contém material de terceiros
   - Age Rating: 4+

### Fase 3: Build e Upload

1. **Incrementar versão** (se necessário):
   ```bash
   # pubspec.yaml: version: 1.0.0+1
   # O +1 é o build number que deve incrementar a cada upload
   ```

2. **Build IPA para distribuição:**
   ```bash
   cd /Users/marcelpiva/Projects/myfit/myfit-app
   flutter build ipa --release --dart-define=ENV=prod
   ```

3. **Upload via Xcode:**
   - Abrir `build/ios/archive/Runner.xcarchive` no Xcode
   - Window → Organizer → Distribute App
   - Selecionar "App Store Connect" → Upload

   **OU usando linha de comando:**
   ```bash
   xcrun altool --upload-app -f build/ios/ipa/myfit_app.ipa \
     -t ios \
     -u SEU_APPLE_ID \
     -p "app-specific-password"
   ```

### Fase 4: Configuração do TestFlight

1. **No App Store Connect:**
   - Selecionar o app → TestFlight
   - Aguardar processamento do build (5-30 min)

2. **Test Information (obrigatório para External Testing):**
   - Beta App Description: Descrever o que o app faz
   - Feedback Email: seu-email@exemplo.com
   - What to Test: "Teste as funcionalidades de check-in, treinos e gamificação"

3. **Testers:**
   - **Internal Testing:** Até 100 membros da equipe (sem review)
   - **External Testing:** Até 10.000 testers (requer Beta Review)

4. **Adicionar Testers:**
   - TestFlight → Internal Testing → + → Adicionar emails
   - Ou criar link público (External Testing)

---

## Checklist Final

### Antes do Upload
- [ ] Remover `NSAllowsArbitraryLoads` do Info.plist (ou justificar)
- [ ] Verificar se ícones estão configurados corretamente
- [ ] Testar build release no dispositivo físico
- [ ] Incrementar build number se for re-upload

### Metadados do App Store Connect
- [ ] Screenshots (6.5" e 5.5" obrigatórios)
- [ ] Descrição do app
- [ ] Keywords
- [ ] URL de suporte
- [ ] URL de política de privacidade

### Permissões (já configuradas)
- [x] NSCameraUsageDescription
- [x] NSPhotoLibraryUsageDescription
- [x] NSLocationWhenInUseUsageDescription
- [x] NSFaceIDUsageDescription

---

## Comandos Rápidos

```bash
# Build para TestFlight
flutter build ipa --release --dart-define=ENV=prod

# Abrir Xcode Organizer
open /Users/marcelpiva/Projects/myfit/myfit-app/build/ios/archive/Runner.xcarchive

# Verificar provisioning profiles instalados
security find-identity -v -p codesigning

# Listar apps no App Store Connect (via fastlane)
fastlane pilot list
```

---

## Timeline Estimado

| Etapa | Tempo |
|-------|-------|
| Configuração Apple Developer | 10-30 min |
| Configuração App Store Connect | 15-30 min |
| Build IPA | 5-10 min |
| Upload | 5-15 min |
| Processamento Apple | 5-30 min |
| Beta App Review (external) | 24-48h |

**Total para Internal Testing:** ~1-2 horas
**Total para External Testing:** +24-48 horas (review)

---

## Próximos Passos

1. Confirme se você tem Apple Developer Program ativo
2. Me avise e eu executo os comandos de build
3. Você faz o upload via Xcode (mais simples) ou me dá credenciais para automatizar
