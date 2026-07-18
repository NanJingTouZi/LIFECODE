// ===== sw.js - Service Worker untuk PWA =====
const CACHE_NAME = 'angka-kehidupan-v1';
const urlsToCache = [
    '/LIFECODE/',
    '/LIFECODE/index.html',
    '/LIFECODE/lifecode.html',
    '/LIFECODE/manifest.json',
    '/LIFECODE/nanjing1.jpeg'
];

// Install Service Worker
self.addEventListener('install', function(event) {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(function(cache) {
                console.log('✅ Cache dibuka');
                return cache.addAll(urlsToCache);
            })
    );
});

// Activate Service Worker
self.addEventListener('activate', function(event) {
    event.waitUntil(
        caches.keys().then(function(cacheNames) {
            return Promise.all(
                cacheNames.map(function(cacheName) {
                    if (cacheName !== CACHE_NAME) {
                        console.log('🗑️ Cache lama dihapus:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});

// Fetch (serve dari cache)
self.addEventListener('fetch', function(event) {
    event.respondWith(
        caches.match(event.request)
            .then(function(response) {
                return response || fetch(event.request);
            })
    );
});
