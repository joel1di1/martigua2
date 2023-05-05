// console.log('[Serviceworker] - Push received', event);
self.addEventListener('push', (event) => {
  const data = event.data.json();

  const options = {
    body: data.body,
    icon: data.icon,
    badge: data.badge,
    vibrate: data.vibrate,
    tag: data.tag,
    data: data.data,
  };

  // Afficher la notification
  event.waitUntil(self.registration.showNotification(data.title, options));
});

// console.log('[Serviceworker]', "Loaded!");
