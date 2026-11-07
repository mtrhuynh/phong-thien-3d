/* Phong Thien 3D service worker: makes the temple installable as an app.
   Navigations and the page's own version probe always go to the network first,
   so a fresh deploy is never masked by the cache; heavy static assets
   (models, music, backdrop, sounds) are cached after their first load. */
const CACHE = 'pt3d-assets-v1';
self.addEventListener('install', (e) => { self.skipWaiting(); });
self.addEventListener('activate', (e) => { e.waitUntil(self.clients.claim()); });
self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET' || url.origin !== self.location.origin) return;
  if (e.request.mode === 'navigate') {
    e.respondWith(fetch(e.request).catch(() => caches.match('index.html')));
    return;
  }
  if (/\/(models|music|bg|sounds)\//.test(url.pathname)) {
    e.respondWith(caches.open(CACHE).then(async (c) => {
      const hit = await c.match(e.request);
      if (hit) return hit;
      const res = await fetch(e.request);
      if (res.ok) c.put(e.request, res.clone());
      return res;
    }));
    return;
  }
  e.respondWith(fetch(e.request));
});
