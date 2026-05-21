<?php
// =============================================
// Safe Walk - API REST de autenticação (PHP)
// Coloque esta pasta dentro do seu servidor
// local (ex: XAMPP/htdocs/safewalk_api/)
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

// ---------- Roteamento ----------
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(405, ['erro' => 'Método não permitido. Use POST.']);
}

$body = json_decode(file_get_contents('php://input'), true) ?? [];
$acao = $body['acao'] ?? '';

// Função SMTP via SSL (Porta 465) totalmente funcional para Sockets nativos
function enviarEmailSmtp(string $host, int $porta, string $usuario, string $senha, string $para, string $assunto, string $corpo): bool {
    try {
        $socket = fsockopen("ssl://$host", $porta, $errno, $errstr, 15);
        if (!$socket) return false;

        $lerResposta = function() use ($socket) {
            $resp = '';
            while ($linha = fgets($socket, 515)) {
                $resp .= $linha;
                if (isset($linha[3]) && $linha[3] == ' ') break;
            }
            return $resp;
        };

        $lerResposta(); // 220
        fputs($socket, "EHLO localhost\r\n"); $lerResposta();
        fputs($socket, "AUTH LOGIN\r\n"); $lerResposta();
        fputs($socket, base64_encode($usuario) . "\r\n"); $lerResposta();
        fputs($socket, base64_encode($senha) . "\r\n"); $lerResposta();
        fputs($socket, "MAIL FROM: <$usuario>\r\n"); $lerResposta();
        fputs($socket, "RCPT TO: <$para>\r\n"); $lerResposta();
        fputs($socket, "DATA\r\n"); $lerResposta();
        
        // Cabeçalhos de e-mail bem formatados
        $cabecalhos = "From: Safe Walk <$usuario>\r\n" .
                      "To: <$para>\r\n" .
                      "Subject: =?UTF-8?B?" . base64_encode($assunto) . "?=\r\n" .
                      "Content-Type: text/plain; charset=UTF-8\r\n\r\n";
                      
        fputs($socket, $cabecalhos . $corpo . "\r\n.\r\n");
        $resp = $lerResposta();
        fputs($socket, "QUIT\r\n");
        fclose($socket);
        
        return (strpos($resp, '250') !== false);
    } catch (Exception $e) {
        return false;
    }
}


switch ($acao) {

    // ==================== CADASTRO ====================
    case 'cadastrar':
        $email    = trim($body['email'] ?? '');
        $senha    = $body['senha'] ?? '';
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
            $db   = getDB();
            $stmt = $db->prepare("SELECT id FROM usuarios WHERE email = ?");
            $stmt->execute([$email]);
            if ($stmt->fetch()) {
                responder(409, ['erro' => 'E-mail já cadastrado.']);
            }

            $hash = password_hash($senha, PASSWORD_BCRYPT, ['cost' => 12]);
            $stmt = $db->prepare("INSERT INTO usuarios (email, senha_hash) VALUES (?, ?)");
            $stmt->execute([$email, $hash]);

            responder(201, [
                'sucesso'  => true,
                'mensagem' => 'Conta criada com sucesso!',
                'usuario'  => ['id' => (int) $db->lastInsertId(), 'email' => $email],
            ]);
        } catch (PDOException $e) {
            responder(500, ['erro' => 'Erro interno ao cadastrar usuário.']);
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
            $db   = getDB();
            $stmt = $db->prepare("SELECT id, email, senha_hash FROM usuarios WHERE email = ?");
            $stmt->execute([$email]);
            $usuario = $stmt->fetch();

            $hashFalso     = '$2y$12$invalido.invalido.invalido.invalido.invalido.invali';
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
            responder(500, ['erro' => 'Erro interno ao realizar login.']);
        }
        break;

    // ==================== ALTERAR SENHA ====================
    case 'alterar_senha':
        $uid        = (int)($body['usuario_id'] ?? 0);
        $senhaAtual = $body['senha_atual'] ?? '';
        $novaSenha  = $body['nova_senha'] ?? '';

        if (!$uid || !$senhaAtual || !$novaSenha) {
            responder(400, ['erro' => 'Preencha todos os campos.']);
        }
        if (strlen($novaSenha) < 6) {
            responder(400, ['erro' => 'A nova senha deve ter ao menos 6 caracteres.']);
        }

        try {
            $db   = getDB();
            $stmt = $db->prepare("SELECT senha_hash FROM usuarios WHERE id = ?");
            $stmt->execute([$uid]);
            $usuario = $stmt->fetch();

            if (!$usuario || !password_verify($senhaAtual, $usuario['senha_hash'])) {
                responder(401, ['erro' => 'Senha atual incorreta.']);
            }

            $novoHash = password_hash($novaSenha, PASSWORD_BCRYPT, ['cost' => 12]);
            $db->prepare("UPDATE usuarios SET senha_hash = ? WHERE id = ?")->execute([$novoHash, $uid]);

            responder(200, ['sucesso' => true, 'mensagem' => 'Senha alterada com sucesso!']);
        } catch (PDOException $e) {
            responder(500, ['erro' => 'Erro interno ao alterar senha.']);
        }
        break;

    // ==================== SOLICITAR RECUPERAÇÃO ====================
    case 'solicitar_recuperacao':
        $email = trim($body['email'] ?? '');

        if (!$email || !validarEmail($email)) {
            responder(400, ['erro' => 'E-mail inválido.']);
        }

        try {
            $db   = getDB();
            $stmt = $db->prepare("SELECT id FROM usuarios WHERE email = ?");
            $stmt->execute([$email]);
            $usuario = $stmt->fetch();

            if (!$usuario) {
                responder(200, ['sucesso' => true, 'mensagem' => 'Se o e-mail existir, você receberá o código.']);
            }

            // Gera token seguro de 6 dígitos
            $token   = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
            $expira  = date('Y-m-d H:i:s', strtotime('+15 minutes'));

            // Cria de forma segura as colunas de controle caso elas não existam no MySQL
            try {
                @$db->exec("ALTER TABLE usuarios ADD COLUMN reset_token VARCHAR(10) NULL");
                @$db->exec("ALTER TABLE usuarios ADD COLUMN reset_expira DATETIME NULL");
            } catch (Exception $e) {
                // Se as colunas já existirem, o MySQL joga um erro e o PHP simplesmente continua
            }

            $db->prepare("UPDATE usuarios SET reset_token = ?, reset_expira = ? WHERE email = ?")
               ->execute([$token, $expira, $email]);

            // Configuração ajustada para o Gmail SSL (Seguro e estável)
            $host         = 'smtp.gmail.com';
            $porta        = 465; // Mudado para 465 (SSL) para resolver o bug do socket
            $usuario_smtp = 'safewalksuporte@gmail.com';
            
            // ⚠️ ATENÇÃO: Verifique sua senha abaixo. Ela precisa ter exatamente 16 letras!
            $senha_smtp   = 'paibfimcpmjaaiob'; 
            
            $assunto  = 'Safe Walk - Código de recuperação de senha';
            $corpo    = "Olá!\n\nSeu código de recuperação de senha é:\n\n$token\n\nEste código expira em 15 minutos.\n\nSe você não solicitou a recuperação, ignore este e-mail.\n\nEquipe Safe Walk";

            $ok = enviarEmailSmtp($host, $porta, $usuario_smtp, $senha_smtp, $email, $assunto, $corpo);

            if (!$ok) {
                responder(500, ['erro' => 'Erro ao enviar e-mail. Verifique suas credenciais SMTP.']);
            }

            responder(200, ['sucesso' => true, 'mensagem' => 'Código enviado para seu e-mail.']);
        } catch (PDOException $e) {
            responder(500, ['erro' => 'Erro interno de banco: ' . $e->getMessage()]);
        }
        break;

    // ==================== VERIFICAR TOKEN ====================
    case 'verificar_token':
        $email = trim($body['email'] ?? '');
        $token = trim($body['token'] ?? '');

        if (!$email || !$token) {
            responder(400, ['erro' => 'Campos obrigatórios.']);
        }

        try {
            $db   = getDB();
            $stmt = $db->prepare("SELECT id FROM usuarios WHERE email = ? AND reset_token = ? AND reset_expira > NOW()");
            $stmt->execute([$email, $token]);
            $usuario = $stmt->fetch();

            if (!$usuario) {
                responder(401, ['erro' => 'Código inválido ou expirado.']);
            }

            responder(200, ['sucesso' => true]);
        } catch (PDOException $e) {
            responder(500, ['erro' => 'Erro interno de banco.']);
        }
        break;

    // ==================== REDEFINIR SENHA ====================
    case 'redefinir_senha':
        $email     = trim($body['email'] ?? '');
        $token     = trim($body['token'] ?? '');
        $novaSenha = $body['nova_senha'] ?? '';

        if (!$email || !$token || !$novaSenha) {
            responder(400, ['erro' => 'Campos obrigatórios.']);
        }
        if (strlen($novaSenha) < 6) {
            responder(400, ['erro' => 'A senha deve ter ao menos 6 caracteres.']);
        }

        try {
            $db   = getDB();
            $stmt = $db->prepare("SELECT id FROM usuarios WHERE email = ? AND reset_token = ? AND reset_expira > NOW()");
            $stmt->execute([$email, $token]);
            $usuario = $stmt->fetch();

            if (!$usuario) {
                responder(401, ['erro' => 'Código inválido ou expirado.']);
            }

            $hash = password_hash($novaSenha, PASSWORD_BCRYPT, ['cost' => 12]);
            $db->prepare("UPDATE usuarios SET senha_hash = ?, reset_token = NULL, reset_expira = NULL WHERE email = ?")
               ->execute([$hash, $email]);

            responder(200, ['sucesso' => true, 'mensagem' => 'Senha redefinida com sucesso!']);
        } catch (PDOException $e) {
            responder(500, ['erro' => 'Erro interno de banco.']);
        }
        break;

    default:
        responder(400, ['erro' => 'Ação inválida.']);
}