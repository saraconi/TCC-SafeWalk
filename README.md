# 🛡️ Safe Walk
> O seu segurança virtual

Aplicativo Flutter com as primeiras telas de login/cadastro e calculadora de IMC, desenvolvido como TCC.

---

## 📋 Pré-requisitos

Antes de rodar o projeto, você precisará ter instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) (para emulador)
- [XAMPP](https://www.apachefriends.org/) (Apache)
- [MySQL](https://dev.mysql.com/downloads/installer/) + [MySQL Workbench](https://www.mysql.com/products/workbench/)

---

## 🚀 Como configurar o ambiente

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/safewalk.git
cd safewalk
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
safewalk/
├── lib/
│   ├── main.dart            # Calculadora IMC (tela principal)
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

## 🔧 Funcionalidades

- ✅ Calculadora de IMC (Adulto e Idoso)
- ✅ Gráfico gauge animado
- ✅ Tela de boas-vindas
- ✅ Cadastro de usuário com validação
- ✅ Login com verificação de senha (bcrypt)
- ✅ API REST em PHP com PDO

---

## ⚠️ Observações de segurança

- **Nunca suba o `auth.php` com sua senha real para o Git**
- O arquivo `auth.php` já está no `.gitignore` por padrão
- As senhas são armazenadas com hash bcrypt (nunca em texto puro)

---

## 👨‍💻 Autor

Desenvolvido por **João** como Trabalho de Conclusão de Curso (TCC).