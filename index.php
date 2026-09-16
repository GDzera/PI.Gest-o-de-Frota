<?php
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/helpers.php';
require_once __DIR__ . '/includes/whatsapp.php';

exigirLogin();

// Módulo padrão conforme o perfil do usuário
$padrao = usuarioLogadoPerfil() === 'gestor' ? 'dashboard' : 'meu_veiculo';

$moduloAtual = $_GET['modulo'] ?? $padrao;
$acaoAtual   = $_GET['acao'] ?? 'listar';

$modulosPermitidos = [
    'dashboard', 'veiculos', 'condutores', 'oficinas',
    'manutencoes', 'solicitacoes', 'relatorios', 'meu_veiculo',
];

if (!in_array($moduloAtual, $modulosPermitidos, true)) {
    $moduloAtual = $padrao;
}

$arquivoController = __DIR__ . '/controllers/' . ucfirst($moduloAtual) . 'Controller.php';

if (!file_exists($arquivoController)) {
    http_response_code(404);
    die('Módulo não encontrado.');
}

require $arquivoController;
