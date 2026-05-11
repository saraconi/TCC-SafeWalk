<?php
// =============================================
// Safe Walk - API de Contatos e Áudios
// Salvar em: C:\xampp\htdocs\safewalk_api\dados.php
// =============================================

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'safewalk');
define('DB_USER', 'root');
define('DB_PASS', '3028');        // coloque sua senha aqui
define('DB_CHARSET', 'utf8mb4');
define('UPLOAD_DIR', __DIR__ . '/audios/');

function getDB(): PDO {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    return new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);
}

function responder(int $status, array $dados): void {
    http_response_code($status);
    echo json_encode($dados, JSON_UNESCAPED_UNICODE);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    responder(405, ['erro' => 'Método não permitido.']);
}

$body  = json_decode(file_get_contents('php://input'), true) ?? [];
$acao  = $body['acao'] ?? '';

switch ($acao) {

    // ===== CONTATOS =====

    case 'listar_contatos':
        $uid = (int)($body['usuario_id'] ?? 0);
        if (!$uid) responder(400, ['erro' => 'usuario_id obrigatório.']);
        $stmt = getDB()->prepare("SELECT * FROM contatos WHERE usuario_id = ? ORDER BY nome");
        $stmt->execute([$uid]);
        responder(200, ['contatos' => $stmt->fetchAll()]);
        break;

    case 'adicionar_contato':
        $uid    = (int)($body['usuario_id'] ?? 0);
        $nome   = trim($body['nome'] ?? '');
        $tel    = trim($body['telefone'] ?? '');
        if (!$uid || !$nome || !$tel) responder(400, ['erro' => 'Campos obrigatórios.']);
        $stmt = getDB()->prepare("INSERT INTO contatos (usuario_id, nome, telefone) VALUES (?,?,?)");
        $stmt->execute([$uid, $nome, $tel]);
        responder(201, ['sucesso' => true, 'id' => (int)getDB()->lastInsertId()]);
        break;

    case 'editar_contato':
        $id   = (int)($body['id'] ?? 0);
        $nome = trim($body['nome'] ?? '');
        $tel  = trim($body['telefone'] ?? '');
        if (!$id || !$nome || !$tel) responder(400, ['erro' => 'Campos obrigatórios.']);
        $db = getDB();
        $stmt = $db->prepare("UPDATE contatos SET nome=?, telefone=? WHERE id=?");
        $stmt->execute([$nome, $tel, $id]);
        responder(200, ['sucesso' => true]);
        break;

    case 'deletar_contato':
        $id = (int)($body['id'] ?? 0);
        if (!$id) responder(400, ['erro' => 'id obrigatório.']);
        $db = getDB();
        $stmt = $db->prepare("DELETE FROM contatos WHERE id=?");
        $stmt->execute([$id]);
        responder(200, ['sucesso' => true]);
        break;

    // ===== ÁUDIOS =====

    case 'listar_audios':
        $uid = (int)($body['usuario_id'] ?? 0);
        if (!$uid) responder(400, ['erro' => 'usuario_id obrigatório.']);
        $stmt = getDB()->prepare("SELECT id, nome, duracao, criado_em FROM audios WHERE usuario_id = ? ORDER BY criado_em DESC");
        $stmt->execute([$uid]);
        responder(200, ['audios' => $stmt->fetchAll()]);
        break;

    case 'salvar_audio':
        $uid     = (int)($body['usuario_id'] ?? 0);
        $nome    = trim($body['nome'] ?? '');
        $duracao = trim($body['duracao'] ?? '00:00');
        $dados   = $body['arquivo_base64'] ?? '';
        if (!$uid || !$nome || !$dados) responder(400, ['erro' => 'Campos obrigatórios.']);
        if (!is_dir(UPLOAD_DIR)) mkdir(UPLOAD_DIR, 0755, true);
        $nomeArq = uniqid("audio_") . '.aac';
        file_put_contents(UPLOAD_DIR . $nomeArq, base64_decode($dados));
        $stmt = getDB()->prepare("INSERT INTO audios (usuario_id, nome, duracao, arquivo) VALUES (?,?,?,?)");
        $stmt->execute([$uid, $nome, $duracao, $nomeArq]);
        responder(201, ['sucesso' => true, 'arquivo' => $nomeArq]);
        break;

    case 'deletar_audio':
        $id = (int)($body['id'] ?? 0);
        if (!$id) responder(400, ['erro' => 'id obrigatório.']);
        $db   = getDB();
        $stmt = $db->prepare("SELECT arquivo FROM audios WHERE id=?");
        $stmt->execute([$id]);
        $row  = $stmt->fetch();
        if ($row && file_exists(UPLOAD_DIR . $row['arquivo'])) {
            unlink(UPLOAD_DIR . $row['arquivo']);
        }
        $db->prepare("DELETE FROM audios WHERE id=?")->execute([$id]);
        responder(200, ['sucesso' => true]);
        break;

    default:
        responder(400, ['erro' => 'Ação inválida.']);
}
