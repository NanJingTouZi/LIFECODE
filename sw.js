// ===== sw.js - Strategi "Network First" untuk Data Segar =====
const CACHE_NAME = 'angka-kehidupan-v2'; // ← Ubah versi untuk memperbarui cache

self.addEventListener('install', function(event) {
    console.log('🔄 Service Worker versi baru terinstal');
    // Lewati proses 'waiting' agar SW baru langsung aktif
    self.skipWaiting();
});

self.addEventListener('activate', function(event) {
    console.log('🗑️ Service Worker diaktifkan, cache lama dibersihkan');
    event.waitUntil(
        caches.keys().then(function(cacheNames) {
            return Promise.all(
                cacheNames.map(function(cacheName) {
                    // Hapus semua cache kecuali yang saat ini
                    if (cacheName !== CACHE_NAME) {
                        console.log('🗑️ Cache lama dihapus:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
    // Pastikan SW baru langsung mengontrol halaman
    return clients.claim();
});

self.addEventListener('fetch', function(event) {
    // STRATEGI: Network First (Coba ambil dari internet dulu)
    event.respondWith(
        fetch(event.request)
            .then(function(networkResponse) {
                // Jika berhasil ambil dari internet, update cache dengan versi baru
                if (event.request.method === 'GET' && networkResponse && networkResponse.status === 200) {
                    const responseToCache = networkResponse.clone();
                    caches.open(CACHE_NAME)
                        .then(function(cache) {
                            cache.put(event.request, responseToCache);
                        });
                }
                return networkResponse;
            })
            .catch(function() {
                // Jika gagal (offline), baru ambil dari cache
                return caches.match(event.request);
            })
    );
});
