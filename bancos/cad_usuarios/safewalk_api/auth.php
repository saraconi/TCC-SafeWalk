<?php
// =============================================
// Safe Walk - API REST de autenticação (PHP)
// Coloque esta pasta dentro do seu servidor
// local (ex: XAMPP/htdocs/safewalk_api/)
// Acesso: http://10.0.2.2/safewalk_api/auth.php
// (10.0.2.2 é o localhost visto pelo emulador Android)
// =============================================

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// ---------- Configurações do banco ----------
define('DB_HOST', '127.0.0.1');
define('DB_USER', 'root');
define('DB_PASS', '3028');
define('DB_NAME', 'safewalk');
define('DB_CHARSET', 'utf8mb4');


// ---------- Conexão PDO ----------
function getDB(): PDO {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    return new PDO($dsn, DB_USER, DB_PASS, $options);
}

// ---------- Helpers ----------
function responder(int $status, array $dados): void {
    http_response_code($status);
    echo json_encode($dados, JSON_UNESCAPED_UNICODE);
    exit;
}

function validarEmail(string $email): bool {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

// ---------- Roteamento por ?acao= ----------
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(405, ['erro' => 'Método não permitido. Use POST.']);
}

$body  = json_decode(file_get_contents('php://input'), true) ?? [];
$acao  = $body['acao'] ?? '';

switch ($acao) {

    // ==================== CADASTRO ====================
    case 'cadastrar':
        $email = trim($body['email'] ?? '');
        $senha = $body['senha'] ?? '';
        $confirma = $body['confirma_senha'] ?? '';

        if (!$email || !$senha || !$confirma) {
            responder(400, ['erro' => 'Preencha todos os campos.']);
        }
        if (!validarEmail($email)) {
            responder(400, ['erro' => 'E-mail inválido.']);
        }
        if (strlen($senha) < 6) {
            responder(400, ['erro' => 'A senha deve ter ao menos 6 caracteres.']);
        }
        if ($senha !== $confirma) {
            responder(400, ['erro' => 'As senhas não coincidem.']);
        }

        try {
            $db = getDB();

            // Verifica se e-mail já existe
            $stmt = $db->prepare("SELECT id FROM usuarios WHERE email = ?");
            $stmt->execute([$email]);
            if ($stmt->fetch()) {
                responder(409, ['erro' => 'E-mail já cadastrado.']);
            }

            // Salva com hash bcrypt (custo 12)
            $hash = password_hash($senha, PASSWORD_BCRYPT, ['cost' => 12]);
            $stmt = $db->prepare("INSERT INTO usuarios (email, senha_hash) VALUES (?, ?)");
            $stmt->execute([$email, $hash]);

            responder(201, [
                'sucesso'  => true,
                'mensagem' => 'Conta criada com sucesso!',
                'usuario'  => ['id' => (int) $db->lastInsertId(), 'email' => $email],
            ]);
        } catch (PDOException $e) {
            responder(500, ['erro' => 'Erro interno. Tente novamente.']);
        }
        break;

    // ==================== LOGIN ====================
    case 'login':
        $email = trim($body['email'] ?? '');
        $senha = $body['senha'] ?? '';

        if (!$email || !$senha) {
            responder(400, ['erro' => 'Preencha e-mail e senha.']);
        }

        try {
            $db = getDB();
            $stmt = $db->prepare("SELECT id, email, senha_hash FROM usuarios WHERE email = ?");
            $stmt->execute([$email]);
            $usuario = $stmt->fetch();

            // Verifica hash — mesmo tempo de resposta para e-mail inexistente (evita enumeração)
            $hashFalso = '$2y$12$invalido.invalido.invalido.invalido.invalido.invali';
            $hashVerificar = $usuario ? $usuario['senha_hash'] : $hashFalso;

            if (!$usuario || !password_verify($senha, $hashVerificar)) {
                responder(401, ['erro' => 'E-mail ou senha incorretos.']);
            }

            responder(200, [
                'sucesso'  => true,
                'mensagem' => 'Login realizado com sucesso!',
                'usuario'  => ['id' => $usuario['id'], 'email' => $usuario['email']],
            ]);
        } catch (PDOException $e) {
            responder(500, ['erro' => 'Erro interno. Tente novamente.']);
        }
        break;

    default:
        responder(400, ['erro' => 'Ação inválida. Use "cadastrar" ou "login".']);
}
