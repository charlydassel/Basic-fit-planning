// Service worker Gym Crew : permet l'installation et un affichage hors connexion.
// Réseau d'abord, en contournant le cache HTTP du navigateur (sinon l'app installée peut garder une ancienne version),
// cache en secours hors connexion. Les données (Supabase, Firebase) ne passent jamais par ici.
const CACHE="gymcrew-v3";
const SHELL=["./","index.html","config.js","manifest.webmanifest","icon-192.png","icon-512.png","fonts/anton.woff2","fonts/barlow-condensed-400.woff2","fonts/barlow-condensed-600.woff2","fonts/barlow-condensed-700.woff2"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(SHELL.map(u=>new Request(u,{cache:"reload"})))).catch(()=>{}));self.skipWaiting()});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==CACHE).map(x=>caches.delete(x)))).then(()=>self.clients.claim()))});
self.addEventListener("fetch",e=>{
  const r=e.request,u=new URL(r.url);if(r.method!=="GET"||u.origin!==location.origin)return;
  // Les polices et icônes ne changent pas : cache d'abord. Le reste (page, config) : toujours vérifier sur le réseau.
  const stat=/\/fonts\/|\.png$/.test(u.pathname);
  if(stat){e.respondWith(caches.match(r).then(m=>m||fetch(r).then(res=>{if(res.ok){const cp=res.clone();caches.open(CACHE).then(c=>c.put(r,cp))}return res})));return}
  e.respondWith(fetch(r.url,{cache:"no-cache",credentials:"same-origin"}).then(res=>{if(res.ok){const cp=res.clone();caches.open(CACHE).then(c=>c.put(r,cp))}return res})
    .catch(()=>caches.match(r).then(m=>m||caches.match("index.html"))));
});
self.addEventListener("message",e=>{if(e.data==="skip")self.skipWaiting()});
self.addEventListener("notificationclick",e=>{e.notification.close();e.waitUntil(self.clients.matchAll({type:"window"}).then(l=>l.length?l[0].focus():self.clients.openWindow("./")))});
