/**********
 * Default values used to create the SW in case the /cache_manifest.json is not found
 **********/

const DEFAULT_VERSION = '1';
const DEFAULT_CTN_PATHS = [
  '/js/app.js',
  '/css/app.css',
  '/fonts/blocks.woff',
  '/fonts/blocks.woff2',
  '/images/p.png',
  '/images/r.png',
  '/images/s.png',
  '/images/w.png',
  '/images/icons/icon-72.png',
  '/images/icons/icon-96.png',
  '/images/icons/icon-128.png',
  '/images/icons/icon-144.png',
  '/images/icons/icon-152.png',
  '/images/icons/icon-192.png',
  '/images/icons/icon-384.png',
  '/images/icons/icon-512.png'
];
const DEFAULT_NTC_PATHS = ['/'];

/**********
 * Utilities
 **********/

// Structure used to hold a given identifier (name), paths and urls of a given strategy
const CacheSpec = class {
  constructor(version, namePrefix, paths) {
    this.namePrefix = namePrefix;
    this.name = namePrefix + version;
    this.paths = paths;
    this.urls = this.paths.map(p => self.origin + p)
  }
  getName() {
    return this.name;
  }
  getPaths() {
    return this.paths;
  }
  setPaths(paths) {
    this.paths = paths;
  }
  setVersion(version) {
    this.name = this.namePrefix + version;
  }
};

// Do put in the browser Cache Storage the resources listed in the CacheSpec input
const cacher = spec => caches.open(spec.getName()).then(cache => cache.addAll(spec.getPaths()))
// Test if url is held by given CacheSpec
const inCache = (declaredCache, url) => (declaredCache.urls.includes(url));

/**********
 * Globals used alongside install/activate/fetch events
 **********/
const cacheThenNetwork = new CacheSpec(DEFAULT_VERSION, 'CTN', DEFAULT_CTN_PATHS);
const networkThenCache = new CacheSpec(DEFAULT_VERSION, 'NTC', DEFAULT_NTC_PATHS)
const specdCaches = [cacheThenNetwork, networkThenCache]

/**********
 * SW lifecycle events
 **********/

// Role: put resources in the Cache Storage and optionnaly updates the global CacheSpecs
self.addEventListener('install', function(event) {
  //console.log('[Service Worker] install');
  event.waitUntil(
    fetch('/cache_manifest.json')
      .then(function(response) {
        return response.ok ? response.json() : false;
      })
      .then(function(manifest) {
        // If there is a cache_manifest.json (generated by *mix phx.digest*)
        // use new resources urls for CTN, and use the manifest version both for CTN and NTC
        if(manifest) {
          cacheThenNetwork.setVersion(DEFAULT_VERSION + '-' + manifest.version);
          networkThenCache.setVersion(DEFAULT_VERSION + '-' + manifest.version);
          const newPaths = Object.values(manifest.latest).filter(f => (f.match(/^(images|css|js|fonts)/) && !f.match(/map$/)));
          cacheThenNetwork.setPaths(newPaths);
        }
        // Finally put listed resources in browser Cache Storage
        return Promise.all(specdCaches.map(cacher));
      })
    );
});

// Role: SW version migration (deleting old caches, when no other browser tab is opened)
self.addEventListener('activate', function(event) {
  //console.log('[Service Worker] activate');
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames
          .filter(cacheName => !specdCaches.map(c => c.name).includes(cacheName))
          .map(cacheName => caches.delete(cacheName))
      );
    })
  );
});

// Role: intercept app.js client resource fetch
// and decide how to serve it depending on the strategy managing it
self.addEventListener('fetch', function(event) {
  if (event.request.cache === 'only-if-cached' && event.request.mode !== 'same-origin') {
    // Devtools error on tab first load
    return;
  }
  event.respondWith(new Promise((resolve) => {
    if (event.request.method !== 'GET') {
      console.log('[Service Worker] BYPASS: ' + event.request.url);
      resolve(fetch(event.request));
    } else if (inCache(cacheThenNetwork, event.request.url)) {
      console.log('[Service Worker] CTN strategy: ' + event.request.url);
      resolve(caches.open(cacheThenNetwork.name)
        .then(cache => cache.match(event.request))
        .then(response => response || fetch(event.request))
      );
    } else if (inCache(networkThenCache, event.request.url)) {
      console.log('[Service Worker] NTC strategy: ' + event.request.url);
      resolve(
        fetch(event.request).catch(() =>
          caches.open(networkThenCache.name)
            .then(cache => cache.match(event.request))
        )
      );
    } else {
      console.log('[Service Worker] Network-only: ' + event.request.url);
      resolve(fetch(event.request));
    }
  }));
});