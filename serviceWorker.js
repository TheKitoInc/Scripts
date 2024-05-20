const NETWORK_TIMEOUT = 5000
const CACHE_NAME = 'v1'
const CACHE_FILES = ['.']

/// //////////////////////////////CACHE ACCESS///////////////////////////////////
// Init cache
async function getCache () {
  return await caches.open(CACHE_NAME)
}

async function initCache () {
  const cache = await getCache()

  if (cache) {
    console.log('Service Worker: Init cache: ' + CACHE_NAME)
    return cache.addAll(CACHE_FILES)
  }
}

// Put response in cache
async function toCache (request, response) {
  const cache = await getCache()

  if (cache) { return cache.put(request, response.clone()) }
}

// Get response from cache
async function fromCache (request) {
  const cache = await getCache()

  if (cache) { return cache.match(request) }
}

// Clean older cache
async function cleanCache () {
  caches.keys().then(function (keys) {
    return keys.map(async function (cache) {
      if (cache !== CACHE_NAME) {
        console.log('Service Worker: Removing old cache: ' + cache)
        return await caches.delete(cache)
      }
    })
  })
}
/// //////////////////////////////NETWORK ACCESS/////////////////////////////////
async function fromNetwork (request) {
  const response = await fetch(request)

  if (response) {
    toCache(request, response.clone())
    return response
  }
}
/// //////////////////////////NETWORK/CACHE ACCESS///////////////////////////////
async function fromNetworkElseCache (request) {
  let response = await fromNetwork(request)

  if (response) { return response }

  response = await fromCache(request)

  return response
}
async function fromCacheElseNetwork (request) {
  let response = await fromCache(request)

  if (response) { return response }

  response = await fromNetwork(request)

  return response
}
async function fromCacheElseNetworkUpdateCache (request) {
  let response = await fromCache(request)

  if (response) {
    fromNetwork(request)
    return response
  }

  response = await fromNetwork(request)

  return response
}
/// /////////////////////////////////////////////////////////////////////////////
// On install, cache the non available resource.
self.addEventListener('install', function (evt) {
  console.log('The service worker is being installed.')
  cleanCache()
  evt.waitUntil(initCache().then(function () {
    return self.skipWaiting()
  }))
})

// On activate
self.addEventListener('activate', function (evt) {
  console.log('The service worker is being activated.')
  evt.waitUntil(self.clients.claim())
})

// On fetch
self.addEventListener('fetch', function (evt) {
  // console.log('The service worker is serving the asset: ' + evt.request.url);
  // evt.respondWith(fromNetworkElseCache(evt.request));
  evt.respondWith(fromCacheElseNetworkUpdateCache(evt.request))
})
