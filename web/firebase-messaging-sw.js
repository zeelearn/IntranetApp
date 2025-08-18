
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js");


firebase.initializeApp({
  apiKey: 'AIzaSyBl0E5LxXz3l6tdSSITpaEiA1sF6jPr4Mg',
  appId: '1:92536473318:web:2bff6cb251cb0157179d27',
  messagingSenderId: '92536473318',
  projectId: 'intranetweb-68536',
  authDomain: 'intranetweb-68536.firebaseapp.com',
  storageBucket: 'intranetweb-68536.appspot.com',
  measurementId: 'G-0934VN0XTW',
});



const messaging = firebase.messaging();

self.addEventListener("notificationclick", function (event) {
  event.notification.close();

  const targetUrl = event.notification.data?.url || '/';
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(windowClients => {
      for (const client of windowClients) {
        // Focus existing tab if same origin
        if (client.url.includes(self.location.origin) && "focus" in client) {
          return client.focus();
        }
      }
      // Always try openWindow — Chrome only blocks cross-origin in insecure mode
      return clients.openWindow(targetUrl).catch(err => {
        console.warn("openWindow blocked:", err);
      });
    })
  );
});


messaging.onBackgroundMessage(async function (payload) {
  console.log("Message receiving in firebase-messaging-sw.js file -", payload);
  const notificationTitle = payload.data.title;


  console.log('Notification title is - ', notificationTitle);

  const notificationOptions = {
    body: payload.data.body,
    icon: payload.data.logo || '/icons/Icon-192.png',
    data: {
      url: payload.data.url || '/'
    },
    image: payload.data.bigimage || undefined
  };

  // const notificationOptions = { body: payload.data.body, icon: 'https://zeelearn.com/wp-content/uploads/zeelearnlogo_new171.png', data: { url: payload.data.url }, };

  self.registration.showNotification(notificationTitle, notificationOptions);


});






