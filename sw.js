// Service worker Gym Crew : permet l'installation et un affichage hors connexion.
// Réseau d'abord (pour toujours avoir la dernière version), cache en secours. Les données (Supabase, Firebase) ne sont jamais mises en cache.
const CACHE="gymcrew-v2";
const SHELL=["./","index.html","config.js","manifest.webmanifest","icon-192.png","icon-512.png","fonts/anton.woff2","fonts/barlow-condensed-400.woff2","fonts/barlow-condensed-600.woff2","fonts/barlow-condensed-700.woff2"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(SHELL)).catch(()=>{}));self.skipWaiting()});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==CACHE).map(x=>caches.delete(x)))).then(()=>self.clients.claim()))});
self.addEventListener("fetch",e=>{
  const r=e.request;if(r.method!=="GET"||new URL(r.url).origin!==location.origin)return;
  e.respondWith(fetch(r).then(res=>{if(res.ok){const cp=res.clone();caches.open(CACHE).then(c=>c.put(r,cp))}return res}).catch(()=>caches.match(r).then(m=>m||caches.match("index.html"))));
});
self.addEventListener("notificationclick",e=>{e.notification.close();e.waitUntil(self.clients.matchAll({type:"window"}).then(l=>l.length?l[0].focus():self.clients.openWindow("./")))});
