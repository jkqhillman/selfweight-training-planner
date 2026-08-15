const CACHE_NAME = 'train-well-v50';
const APP_SHELL = [
  './',
  'index.html',
  'styles.css?v=50',
  'app.js?v=50',
  'manifest.webmanifest',
  'app-icon-180.png',
  'app-icon-512.png'
];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(APP_SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)))).then(() => self.clients.claim()));
});

function updateCache(request) {
  return fetch(request).then(response => {
    if (response.ok) caches.open(CACHE_NAME).then(cache => cache.put(request, response.clone()));
    return response;
  });
}

function networkFirst(request) {
  const timeout = new Promise(resolve => setTimeout(() => resolve(null), 1500));
  return Promise.race([fetch(request), timeout]).then(response => {
    if (response) {
      if (response.ok) caches.open(CACHE_NAME).then(cache => cache.put(request, response.clone()));
      return response;
    }
    return caches.match(request).then(cached => cached || caches.match('./'));
  }).catch(() => caches.match(request).then(cached => cached || caches.match('./')));
}

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;

  if (event.request.mode === 'navigate') {
    event.respondWith(networkFirst(event.request));
    return;
  }

  event.respondWith(caches.match(event.request).then(cached => cached || updateCache(event.request)));
});
