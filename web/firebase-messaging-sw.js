importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyByMxwr0zs8X_YbnVcAjWOAGHMyqYR1M3w",
  authDomain: "mabna-care.firebaseapp.com",
  projectId: "mabna-care",
  storageBucket: "mabna-care.firebasestorage.app",
  messagingSenderId: "826365542912",
  appId: "1:826365542912:web:d2ecd5645fcf29cf820ee5",
  measurementId: "G-RE2XWQB14T"
});

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  // When FCM payload already includes a `notification` block, the Firebase SDK
  // displays it automatically. Avoid showing a duplicate notification here.
  if (payload?.notification) return;

  const title = payload?.data?.title || 'MABNA CARE';
  const body = payload?.data?.body || '';
  const icon = payload?.data?.icon || 'https://mabna-care.web.app/icons/Icon-192.png';
  const badge = payload?.data?.badge || 'https://mabna-care.web.app/icons/notification-badge.png';
  const url = payload?.data?.url || 'https://mabna-care.web.app/';
  const tag = payload?.data?.tag || 'mabna-care-notification';

  self.registration.showNotification(title, {
    body,
    icon,
    badge,
    tag,
    data: { url },
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = event.notification?.data?.url || 'https://mabna-care.web.app/';
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      for (const client of windowClients) {
        if (client.url.includes('mabna-care') && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});
