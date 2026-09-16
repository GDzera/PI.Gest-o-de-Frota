const CACHE_NAME = 'saffrix-fleet-v1';

const ARQUIVOS_ESTATICOS = [
    'assets/css/style.css',
    'assets/img/logo.png',
    'assets/img/logo-icone.png',
    'assets/img/icon-192.png',
    'assets/img/icon-512.png',
    'offline.html',
];

// Instala o service worker e guarda em cache os arquivos estáticos (logo, css, ícones).
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => cache.addAll(ARQUIVOS_ESTATICOS))
    );
    self.skipWaiting();
});

// Remove caches de versões antigas do app.
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((nomes) =>
            Promise.all(nomes.filter((n) => n !== CACHE_NAME).map((n) => caches.delete(n)))
        )
    );
    self.clients.claim();
});

// Estratégia:
// - Arquivos estáticos (css/imagens deste app): cache primeiro, com atualização em segundo plano.
// - Páginas do sistema (PHP): sempre busca na internet (dados mudam o tempo todo);
//   se não houver conexão, mostra uma tela simples de "sem conexão" em vez de travar.
self.addEventListener('fetch', (event) => {
    const req = event.request;
    if (req.method !== 'GET') return;

    const url = new URL(req.url);
    const estatico = url.origin === self.location.origin && ARQUIVOS_ESTATICOS.some((a) => url.pathname.endsWith(a));

    if (estatico) {
        event.respondWith(
            caches.match(req).then((cacheado) => {
                const buscar = fetch(req).then((resp) => {
                    caches.open(CACHE_NAME).then((cache) => cache.put(req, resp.clone()));
                    return resp;
                }).catch(() => cacheado);
                return cacheado || buscar;
            })
        );
        return;
    }

    if (req.mode === 'navigate') {
        event.respondWith(
            fetch(req).catch(() => caches.match('offline.html'))
        );
    }
});
