<div align="center">

<img src="assets/logo.png" alt="SafeWalk Logo" width="120"/>

# 🛡️ SafeWalk — Seu Segurança Virtual

**Trabalho de Conclusão de Curso — Técnico em Desenvolvimento de Sistemas**  
Etec Professor Camargo Aranha · São Paulo, SP · 2026

[![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![PHP](https://img.shields.io/badge/API-PHP-777BB4?style=flat&logo=php&logoColor=white)](https://php.net)
[![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=flat&logo=mysql&logoColor=white)](https://mysql.com)
[![XAMPP](https://img.shields.io/badge/Server-XAMPP-FB7A24?style=flat&logo=apachenetbeanside&logoColor=white)](https://apachefriends.org)

</div>

---

## 📌 Sobre o Projeto

O **SafeWalk** é um aplicativo mobile de segurança pessoal desenvolvido como Trabalho de Conclusão de Curso do curso Técnico em Desenvolvimento de Sistemas da **Etec Professor Camargo Aranha**.

O projeto nasceu da necessidade de proteger **grupos vulneráveis** — mulheres, idosos e a comunidade LGBT+ — da violência cotidiana. Com **88,9% da população brasileira acima de 10 anos possuindo celular** (IBGE, 2024), o smartphone se torna a ferramenta mais acessível e eficaz para oferecer segurança em tempo real.

O SafeWalk transforma o celular em um **dispositivo de segurança ativa**: ao detectar uma palavra-chave em segundo plano, o aplicativo automaticamente envia a localização do usuário para contatos de emergência, inicia gravação de áudio e aciona a polícia — tudo sem qualquer interação manual, e de forma discreta.

> 💡 O app possui um **modo disfarce** como Calculadora de IMC para não levantar suspeitas de possíveis agressores que monitorem o aparelho da vítima.

---

## 👥 Equipe

| Nome | GitHub |
|---|---|
| João Guilherme | [@joaopresser](https://github.com/joaopresser) |
| Sara Coni | [@saraconi](https://github.com/saraconi) |
| Thiago Ochoa | [@yungtl](https://github.com/yungtl) |

---

## 🔧 Funcionalidades

### Implementadas
- ✅ Calculadora de IMC (Adulto e Idoso)
- ✅ Gráfico gauge animado
- ✅ Tela de boas-vindas
- ✅ Cadastro de usuário com validação
- ✅ Login com verificação de senha (bcrypt)
- ✅ API REST em PHP com PDO

### Planejadas
- 🔜 Detecção de palavra-chave em segundo plano (wake word via Picovoice Porcupine)
- 🔜 Envio automático de localização para contatos de emergência
- 🔜 Gravação de áudio como prova, salva na nuvem e em servidor local
- 🔜 Ligação automática para a polícia com localização e situação de perigo
- 🔜 Autenticação por reconhecimento facial para acesso às gravações
- 🔜 Integração com Python no back-end para requisições e envio de alertas

---

## 🎨 Identidade Visual

O projeto possui duas identidades visuais distintas e intencionais:

### 🧮 Calculadora IMC — App Disfarce

| Cor | Hex | Motivo |
|---|---|---|
| Preto | `#000000` | Remete a apps de produtividade comuns |
| Amarelo Vibrante | `#FDC700` | Remete a apps de saúde/fitness |

> O preto e o amarelo são cores clássicas em apps de saúde. A combinação faz o ícone "sumir" entre outros aplicativos comuns no celular, não levantando suspeitas.

### 🛡️ SafeWalk — App Principal

| Cor | Hex | Motivo |
|---|---|---|
| Bordô Profundo | `#8C0368` | Autoridade, confiança e proteção |
| Magenta Escuro | `#BF04A0` | Empatia, acolhimento e identificação com o público-alvo |
| Branco | `#FFFFFF` | Legibilidade, clareza e harmonia visual |

---

## 📋 Pré-requisitos

Antes de rodar o projeto, você precisará ter instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) (para emulador)
- [XAMPP](https://www.apachefriends.org/) (Apache)
- [MySQL](https://dev.mysql.com/downloads/installer/) + [MySQL Workbench](https://www.mysql.com/products/workbench/)

### ⚙️ Configurando o Flutter no PATH (Variáveis de Ambiente)

Após baixar e extrair o Flutter SDK, é necessário adicionar a pasta `bin` ao PATH do sistema para que o comando `flutter` funcione em qualquer terminal.

> Exemplo: se você extraiu o Flutter em `C:\flutter`, a pasta a adicionar é `C:\flutter\bin`

#### Windows

1. Pressione **Windows + S** e pesquise por **"Variáveis de Ambiente"**
2. Clique em **"Editar as variáveis de ambiente do sistema"**
3. Na janela que abrir, clique em **"Variáveis de Ambiente..."** (canto inferior direito)
4. Na seção **"Variáveis do usuário"**, selecione a variável **`Path`** e clique em **"Editar..."**
5. Clique em **"Novo"** e cole o caminho completo até a pasta `bin` do Flutter:
   ```
   C:\flutter\bin
   ```
6. Clique em **OK** em todas as janelas para salvar
7. Feche e reabra o terminal, depois verifique com:
   ```bash
   flutter --version
   ```

#### macOS / Linux

Abra o terminal e edite o arquivo de configuração do seu shell:

```bash
# Se usa bash (~/.bashrc ou ~/.bash_profile)
echo 'export PATH="$PATH:/caminho/para/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Se usa zsh (~/.zshrc) — padrão no macOS
echo 'export PATH="$PATH:/caminho/para/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

Substitua `/caminho/para/flutter` pelo local onde você extraiu o SDK (ex: `$HOME/flutter`).

Verifique com:
```bash
flutter --version
```

> ✅ Se aparecer a versão do Flutter, o PATH está configurado corretamente.

---

## 🚀 Como configurar o ambiente

### 1. Clone o repositório

```bash
git clone https://github.com/saraconi/TCC-SafeWalk.git
cd TCC-SafeWalk
```

### 2. Instale as dependências Flutter

```bash
flutter pub get
```

### 3. Configure o banco de dados

Abra o **MySQL Workbench**, conecte com seu usuário root e execute o script:

```
File → Open SQL Script → selecione o arquivo banco.sql → clique no raio ⚡
```

Isso vai criar o banco `safewalk` e a tabela `usuarios`.

### 4. Configure a API PHP

- Copie a pasta `safewalk_api/` para dentro de `C:\xampp\htdocs\`
- Abra o arquivo `safewalk_api/auth.php` e edite as configurações do banco:

```php
define('DB_HOST', '127.0.0.1');
define('DB_USER', 'root');
define('DB_PASS', 'SUA_SENHA_AQUI'); // coloque sua senha do MySQL aqui
define('DB_NAME', 'safewalk');
```

- Abra o **XAMPP Control Panel** e inicie o **Apache**

### 5. Verifique se a API está funcionando

Acesse no navegador:

```
http://localhost/safewalk_api/auth.php
```

Deve aparecer:

```json
{"erro":"Método não permitido. Use POST."}
```

### 6. Configure a URL da API no Flutter

Abra `lib/auth_screens.dart` e verifique a linha:

```dart
const String kBaseUrl = 'http://10.0.2.2/safewalk_api/auth.php';
```

> ⚠️ `10.0.2.2` é o endereço do localhost visto pelo emulador Android.  
> Se for usar um **dispositivo físico**, troque pelo IP local da sua máquina (ex: `192.168.1.x`).

### 7. Rode o app

```bash
flutter run
```

---

## 📁 Estrutura do projeto

```
TCC-SafeWalk/
├── lib/
│   ├── main.dart            # Calculadora IMC (tela principal / app disfarce)
│   └── auth_screens.dart    # Telas de Login, Cadastro e Welcome
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml
├── safewalk_api/
│   └── auth.php             # API REST PHP (cadastro e login)
├── banco.sql                # Script de criação do banco MySQL
├── pubspec.yaml
└── README.md
```

---

## ⚠️ Observações de segurança

- **Nunca suba o `auth.php` com sua senha real para o Git**
- O arquivo `auth.php` já está no `.gitignore` por padrão
- As senhas são armazenadas com hash **bcrypt** (nunca em texto puro)
- O projeto foi desenvolvido em conformidade com a **LGPD (Lei nº 13.709/2018)** — dados de localização e áudios serão tratados com sigilo
- Todos os usuários assinarão um **Termo de Responsabilidade e Ciência Jurídica** no cadastro, vinculando sua identidade a cada alerta emitido

---

## ⚖️ Contexto Social e Legal

O SafeWalk foi desenvolvido para complementar o aparato legal brasileiro de proteção a grupos vulneráveis:

- **Lei Maria da Penha** (Lei nº 11.340) — proteção contra violência doméstica e familiar
- **Estatuto do Idoso** (Lei nº 10.741) — proteção aos direitos da pessoa idosa
- **Lei do Feminicídio** (Lei nº 13.104/2015) — qualificação do homicídio contra mulher
- **LGPD** (Lei nº 13.709/2018) — proteção de dados pessoais dos usuários

Enquanto essas leis atuam após o fato, o SafeWalk atua **no momento da agressão**, oferecendo resposta imediata que o aparato jurídico sozinho não consegue prover.

---

## 📚 Referências

- IBGE. *Pesquisa Nacional por Amostra de Domicílios Contínua: Acesso à Internet e à televisão e posse de telefone móvel celular para uso pessoal.* Rio de Janeiro: IBGE, 2024.
- BRASIL. *Lei nº 13.709, de 14 de agosto de 2018.* Lei Geral de Proteção de Dados Pessoais (LGPD).
- BRASIL. *Lei nº 13.104, de 9 de março de 2015.* Lei do Feminicídio.
- FÓRUM BRASILEIRO DE SEGURANÇA PÚBLICA. *Visível e Invisível: a Vitimização de Mulheres no Brasil.* 5. ed. São Paulo: FBSP, 2024.

---

<div align="center">

Desenvolvido com 💜 por **João Guilherme**, **Sara Coni** e **Thiago Ochoa**  
**Etec Professor Camargo Aranha — São Paulo, 2026**

</div>