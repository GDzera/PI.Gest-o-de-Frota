<?php
// Blindagem: descarta qualquer saída que porventura já tenha sido enviada antes
// deste ponto (ex.: um caractere invisível de BOM introduzido acidentalmente por
// algum editor de arquivos ao salvar). Sem isso, aquele conteúdo "fantasma" quebra
// o JSON antes mesmo do nosso código rodar.
while (ob_get_level() > 0) {
    ob_end_clean();
}

// Gera o manifest.json "na hora", pelo PHP, em vez de servir um arquivo .json estático.
// Isso evita problemas de BOM/codificação que alguns editores de arquivo de hospedagem
// costumam introduzir ao salvar arquivos .json diretamente pelo painel.

header('Content-Type: application/manifest+json; charset=utf-8');

$manifest = [
    'name' => 'Saffrix Fleet - Sistema de Gestão de Manutenção',
    'short_name' => 'Saffrix Fleet',
    'description' => 'Gestão e controle de frota de veículos leves: veículos, condutores e manutenções.',
    'start_url' => 'index.php',
    'scope' => '.',
    'display' => 'standalone',
    'orientation' => 'portrait-primary',
    'background_color' => '#ffffff',
    'theme_color' => '#0c3c6c',
    'lang' => 'pt-BR',
    'icons' => [
        [
            'src' => 'assets/img/icon-192.png',
            'sizes' => '192x192',
            'type' => 'image/png',
            'purpose' => 'any',
        ],
        [
            'src' => 'assets/img/icon-512.png',
            'sizes' => '512x512',
            'type' => 'image/png',
            'purpose' => 'any',
        ],
    ],
];

echo json_encode($manifest, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
