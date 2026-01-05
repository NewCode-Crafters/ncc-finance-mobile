# Bytebank (NCC Finance Mobile)

Um aplicativo móvel Flutter para gestão financeira pessoal. O Bytebank (nome do pacote: `bytebank`) é um app educacional/demonstrativo que mostra recursos comuns de finanças: autenticação, transações, controle de saldo, investimentos, gerenciamento de perfil, gráficos e integração com Firebase.

## Principais recursos

- Autenticação por e-mail/senha (Firebase Auth)
- Perfis de usuário com upload de imagem (Firebase Storage + Firestore)
- Transações: criar, editar, listar e visualizar em gráficos (Cloud Firestore)
- Dashboard com saldo e gráficos de visão geral (fl_chart)
- Investimentos: criação e listagem
- Localização em português do Brasil (`pt_BR`)
- Gerenciamento de estado usando `provider`

## Sumário

- [Testando no seu dispositivo](#testando-no-seu-dispositivo)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Primeiros passos](#primeiros-passos)
- [CI/CD](#ci-cd)
- [Comandos disponíveis](#comandos-disponíveis)
- [Notas de desenvolvimento](#notas-de-desenvolvimento)
- [Pacotes principais](#pacotes-principais)
- [Resolução de problemas](#resolução-de-problemas)
- [Testes unitários](#testes-unitários)
- [Autores](#autores)
- [Links externos](#links-externos)

## Testando no seu dispositivo

Prefere testar o aplicativo diretamente em seu dispositivo ou emulador? Tornamos isso fácil para avaliadores e revisores:

- Último APK: um APK Android pronto para instalação está disponível na pasta `app-artifacts/` do repositório. Use esse APK para instalar rapidamente o app em dispositivos físicos ou emuladores.
- ⚠️ Arquivos de configuração sensíveis: para conveniência durante a avaliação, o repositório inclui os arquivos de configuração da plataforma Firebase (`android/app/google-services.json` e `ios/Runner/GoogleService-Info.plist`). Esses arquivos são fornecidos apenas para facilitar os testes locais e serão invalidados e substituídos após o período de avaliação.

Instalação rápida / exemplos de execução:

Instalar o APK em um dispositivo Android (via adb):

```bash
adb install -r app-artifact/app-release.apk
```

Executar diretamente do código-fonte (modo debug):

```bash
# listar dispositivos conectados
flutter devices

# Executar em um dispositivo (substitua <device-id>)
flutter run -d <device-id>
```

Onde colocar os arquivos de configuração do Firebase (caso tenha recebido separadamente):

```bash
cp ~/Downloads/google-services.json android/app/google-services.json
cp ~/Downloads/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
```

Notas:

- iOS: abra `ios/Runner.xcworkspace` no Xcode para ajustar assinatura e provisionamento se for rodar em um dispositivo real.
- Android: habilite a depuração USB em um dispositivo físico ou inicie um emulador AVD antes de executar `flutter run`.

## Estrutura do projeto

Visualização do repositório:

```
.
├── android/
├── ios/
├── lib/
│   ├── core/                # constantes, widgets, serviços, utilitários, validadores
│   ├── features/            # módulos de funcionalidades: autenticação, dashboard, transações, investimentos, perfil, splash, pokemons
│   │   ├── authentication/
│   │   ├── dashboard/
│   │   ├── transactions/
│   │   ├── investments/
│   │   ├── profile/
│   │   └── splash/
│   ├── firebase_options.dart # configuração gerada do Firebase
│   ├── main.dart             # ponto de entrada do app + registro do Provider
│   └── theme/
├── assets/
│   └── images/               # logos e telas de splash
├── pubspec.yaml
├── README.md
└── test/
```

Descrição resumida:

- `lib/core/` – utilitários, modelos, validadores e widgets compartilhados.
- `lib/features/` – pastas com funcionalidades contendo telas, serviços, notifiers e modelos.
- `lib/firebase_options.dart` – gerado pelo FlutterFire; mantenha em sincronia com seu projeto Firebase.

## Primeiros passos

Siga os passos abaixo para executar o aplicativo localmente.

### Pré-requisitos

- Flutter SDK (compatível com `sdk: ^3.8.1`). Instale em https://docs.flutter.dev/get-started/install
- Android Studio ou Xcode para emuladores/simuladores
- Um projeto Firebase com os arquivos de configuração (`google-services.json` e `GoogleService-Info.plist`)

### Clonar e instalar dependências

```bash
git clone git@github.com:NewCode-Crafters/ncc-finance-mobile.git
cd ncc-finance-mobile
flutter pub get
```

### Configurar Firebase (modo demonstração)

Para o ambiente de demonstração, os arquivos de configuração do Firebase são fornecidos para que professores possam executar o app rapidamente. Coloque os arquivos exatamente nestes caminhos:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

Não é necessário editar os arquivos. Após a fase de avaliação, as credenciais serão rotacionadas e o projeto voltará à configuração normal de produção.

Em caso de problemas, entre em contato com **joeltonmatos@gmail.com**.

### Executar o app

```bash
flutter devices
flutter run -d <device-id>
```

**Configurações**

- Localização: o app já suporta `pt_BR`. Para adicionar novos idiomas, edite `supportedLocales` em `lib/main.dart`.
- Firebase: usado para autenticação, Firestore e Storage. Ajuste as regras conforme o ambiente (dev/prod).

## CI/CD

O projeto usa **Codemagic** (https://codemagic.io) para integração e entrega contínua. Os pipelines validam PRs, constroem artefatos de homologação e geram builds de produção.

### Visão geral dos pipelines

| Workflow           | Gatilho                                                                  | Finalidade                                                                                                     |
| ------------------ | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| `DEV-WORKFLOW`     | Pull requests com prefixos `task/`, `fix/`, `enhancement/`              | Executa build/test para validar PRs antes da revisão.                                                          |
| `HOMOLOG-WORKFLOW` | Pull requests da branch `dev`                                           | Gera artefatos (.apk) para QA/Homolog e distribui via Firebase App Distribution.                              |
| `PROD-WORKFLOW`    | Pushes para `main` ou tags de release                                   | Cria builds de produção e inicia distribuição.                                                                |

## Comandos disponíveis

- Instalar dependências:

```bash
flutter pub get
```

- Analisar código:

```bash
flutter analyze
```

- Executar testes:

```bash
flutter test
```

- Executar no dispositivo:

```bash
flutter run -d <device-id>
```

## Notas de desenvolvimento

- Gerenciamento de estado: `provider` com `ChangeNotifier`.
- Persistência: Cloud Firestore para transações, perfis e investimentos.
- Gráficos: `fl_chart` para visualizações.
- Imagens: `image_picker` e `firebase_storage` para fotos de perfil.
- Localização: `intl` inicializado em `main.dart` para formato `pt_BR`.

## Pacotes principais

| Pacote                                                   | Finalidade                                                                   |
| -------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `firebase_core`                                          | Inicializa e configura o Firebase.                                            |
| `firebase_auth`                                          | Autenticação por e-mail/senha.                                                |
| `cloud_firestore`                                        | Banco de dados NoSQL principal.                                               |
| `firebase_storage`                                       | Armazena e serve imagens de usuários.                                         |
| `provider`                                               | Gerenciamento de estado.                                                      |
| `fl_chart`                                               | Renderiza gráficos no dashboard.                                              |
| `image_picker`                                           | Seleção de imagens da câmera/galeria.                                         |
| `intl`                                                   | Localização de datas e números.                                               |
| `flutter_localizations`                                  | Delegates nativos de localização do Flutter.                                  |
| `http`                                                   | Cliente HTTP para chamadas externas.                                          |
| `equatable`                                              | Comparação simplificada entre modelos.                                        |
| `flutter_native_splash`                                  | Gera telas de splash nativas.                                                |
| `flutter_launcher_icons`                                 | Gera ícones de inicialização.                                                |
| `mockito`, `fake_cloud_firestore`, `firebase_auth_mocks` | Utilitários para testes unitários.                                            |
| `build_runner`                                           | Ferramentas de geração de código.                                            |
| `flutter_lints`                                          | Regras de lint recomendadas.                                                 |

## Testes unitários

Os testes validam serviços e regras de negócio principais usando mocks e fakes do Firebase.

- `financial_transaction_service_test.dart` → cria, lista e edita transações.
- `balance_service_test.dart` → valida cálculos de saldo.
- `profile_service_test.dart` → verifica o mapeamento de dados do perfil.

## Boas Práticas de Segurança

O Bytebank segue práticas recomendadas de segurança para proteger dados e credenciais dos usuários:

### Autenticação

- **Firebase Authentication**: O app usa Firebase Auth para autenticação por e-mail/senha. Todos os fluxos de autenticação são processados no servidor do Firebase, garantindo que credenciais nunca sejam armazenadas no app.
- **Gerenciamento de sessão**: Firebase Auth gerencia sessões de forma segura com renovação automática de tokens. Sessões expiram conforme políticas padrão do Firebase.

### Segurança de transporte

- **Somente HTTPS**: Toda comunicação de rede com serviços Firebase (Auth, Firestore, Storage) usa HTTPS por padrão. O app não aceita conexões HTTP em texto plano com backends Firebase.
- **Validação de certificados**: Os SDKs do Firebase lidam automaticamente com validação de certificados.

### Armazenamento de dados sensíveis

- **Serviço SecureStorage**: O app implementa `ISecureStorage` (localizado em `lib/core/security/`) usando `flutter_secure_storage`. Este serviço armazena dados sensíveis usando:
  - **iOS**: Keychain com acessibilidade `kSecAttrAccessibleAfterFirstUnlock`.
  - **Android**: EncryptedSharedPreferences baseado em Keystore com criptografia AES256_GCM.
- **Casos de uso**: SecureStorage é projetado para dados sensíveis futuros como PINs de usuário, flags biométricas ou tokens de autenticação em cache. Atualmente, a autenticação é totalmente gerenciada pelo Firebase Auth.
- **Testes**: Uma implementação `FakeSecureStorage` (em `test/fakes/`) permite testes unitários sem dependências reais de plataforma.

### Configuração do Firebase e credenciais

- **Tratamento de arquivos de configuração**: Os arquivos `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) contêm identificadores do projeto Firebase e chaves de API. Estes arquivos:
  - Estão incluídos no repositório **apenas para fins de avaliação** para simplificar testes para revisores.
  - **Serão rotacionados** após o período de avaliação. Em produção, estes arquivos devem ser mantidos privados (ex: via secrets de CI/CD ou armazenamento seguro de artefatos).
- **Rotação de credenciais**: Após a avaliação, as chaves do projeto Firebase serão regeneradas e os arquivos de configuração públicos serão substituídos por templates placeholder.

### Regras de Segurança do Firestore

- **Configuração atual**: O app usa Firebase Firestore para armazenar transações, investimentos e perfis de usuário. As Regras de Segurança do Firestore controlam acesso de leitura/escrita no nível do banco de dados.
- **Localização das regras**: As Regras de Segurança são configuradas no Console do Firebase (Firestore > aba Rules) ou via arquivo `firestore.rules` se usar deploy via Firebase CLI.
- **Regras recomendadas**: Certifique-se de que:
  - Usuários possam ler/escrever apenas seus próprios dados (force verificações de `request.auth.uid`).
  - Coleções como `transactions`, `profiles` e `investments` sejam escopadas por ID de usuário.
  - Considere validação em nível de campo (ex: valores de transação devem ser não-negativos).
- **Exemplo de regra**:
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      }
      match /profiles/{userId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```
  Ajuste essas regras conforme seus requisitos específicos e teste-as no Rules Playground do Console Firebase.

### Tratamento de erros e logs

- **Sem dados sensíveis em logs**: O app evita registrar tokens de autenticação, senhas ou informações pessoais identificáveis (PII).
- **Erros para usuários**: Erros de autenticação (ex: credenciais inválidas) exibem mensagens genéricas para prevenir vazamento de informações.

### Recomendações adicionais

- **Atualizações de dependências**: Atualize regularmente pacotes relacionados ao Firebase e segurança para corrigir vulnerabilidades conhecidas.
- **Revisão de código**: Todo código de autenticação e acesso a dados deve ser revisado quanto a problemas de segurança antes do deploy em produção.
- **Testes de penetração**: Considere auditorias de segurança para releases de produção.

Para mais informações sobre segurança no Firebase:
- [Firebase Auth Security](https://firebase.google.com/docs/auth/admin/manage-sessions)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Documentação flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

## Resolução de problemas

- Erros no Firebase: confira se `google-services.json` / `GoogleService-Info.plist` estão corretos.
- Erros de build: rode `flutter pub upgrade` e valide versões dos plugins.

## Autores

| Nome              | Perfil GitHub                                      |
| ----------------- | -------------------------------------------------- |
| Carlos Ferreira   | [@carlosrfjrdev](https://github.com/carlosrfjrdev) |
| Joelton Matos     | [@joeltonmats](https://github.com/joeltonmats)     |
| Larissa Rocha     | [@larisr](https://github.com/larisr)               |
| Leonardo Medeiros | [@leomartinsm](https://github.com/leomartinsm)     |
| Ricardo Momberg   | [@ricardomomberg](https://github.com/RicardoMomberg) |

## Links externos

- **Demo em vídeo:** https://youtu.be/MaEYtsVCi0Y
- **Protótipo Figma:** https://www.figma.com/design/gB5nE8V4Le026J3y4FJxDQ/NCC-TC-3-prototipo?node-id=12085-1622
