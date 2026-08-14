self.addEventListener('install', event => event.waitUntil(caches.open('train-well-v43').then(cache => cache.addAll(['./', 'index.html', 'styles.css?v=43', 'app.js?v=43', 'manifest.webmanifest', 'app-icon-180.png', 'app-icon-512.png', 'assets/guides/bodyweight-squat-ai.png', 'assets/guides/slow-calf-raise-ai.png', 'assets/guides/side-plank.png', 'assets/guides/calf-raise.png', 'assets/guides/ankle-circle.svg', 'assets/guides/bridge-start.svg', 'assets/guides/bridge-up.svg', 'assets/guides/lunge-start.svg', 'assets/guides/single-leg-stand.svg', 'assets/guides/single-leg-stand-ai.png', 'assets/guides/incline-pushup-ai.png', 'assets/guides/dead-bug-ai.png', 'assets/guides/wall-sit-ai.png', 'assets/guides/single-leg-bridge-ai.png', 'assets/guides/prone-yt-ai.png', 'assets/guides/forearm-plank-ai.png', 'assets/guides/wall-scapular-push-ai.png', 'assets/guides/brisk-walk-ai.png', 'assets/guides/wall-slide-ai.png', 'assets/guides/run-walk-ai.png', 'assets/guides/calf-stretch-ai.png', 'assets/guides/diaphragmatic-breathing-ai.png'])).then(() => self.skipWaiting())));
self.addEventListener('activate', event => event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key !== 'train-well-v43').map(key => caches.delete(key)))).then(() => self.clients.claim())));
self.addEventListener('fetch', event => {
  if (event.request.mode === 'navigate') {
    event.respondWith(fetch(event.request).catch(() => caches.match('./')));
    return;
  }
  event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request)));
});
