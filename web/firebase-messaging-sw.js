


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

self.addEventListener('push', function (event) {
  let payload;
  try {
    payload = event.data.json();
  } catch (e) {
    console.log("Push event data is not JSON", e);
    return;
  }

  console.log("Message receiving in firebase-messaging-sw.js file (native push) -", payload);

  // If there's no data payload, let Firebase handle it (e.g. standard notification)
  if (!payload.data || !payload.data.title) {
    return;
  }

  const notificationTitle = payload.data.title;
  console.log('Notification title is - ', notificationTitle);

  const notificationOptions = { 
    body: payload.data.body, 
    icon: 'https://zeelearn.com/wp-content/uploads/zeelearnlogo_new171.png', 
    data: { url: payload.data.url } 
  };

  const showPromise = new Promise((resolve) => {
    let dbUserRequest = indexedDB.open('kidzeepref');

    dbUserRequest.onerror = function (err) {
      console.error("logindetails Failed to open database:", err);
      resolve();
    };

    dbUserRequest.onsuccess = function (dbvent) {
      let db = dbvent.target.result;
      if (!db.objectStoreNames.contains('box')) return resolve();

      let transaction = db.transaction(['box'], 'readonly');
      let objectStore = transaction.objectStore('box');
      
      const getFromStore = (key) => new Promise((res) => {
        let req = objectStore.get(key);
        req.onsuccess = (e) => res(e.target.result);
        req.onerror = () => res(null);
      });
      
      Promise.all([getFromStore('empid'), getFromStore('employee_Code')]).then(([localEmpid, localEmpCode]) => {
        let shouldShow = false;
        
        if (payload.data.employee_code && payload.data.employee_code == localEmpCode) {
          console.log('User id matching on employee_code - ', payload.data.employee_code);
          shouldShow = true;
        } else if (payload.data.empid && payload.data.empid == localEmpid) {
          console.log('User id matching on empid - ', payload.data.empid);
          shouldShow = true;
        }
        
        if (shouldShow) {
          self.registration.showNotification(notificationTitle, notificationOptions)
            .then(() => resolve())
            .catch((e) => {
              console.log('Error in showing notification - ', e);
              resolve();
            });
        } else {
          console.log('User id not matching or not found. Payload empid:', payload.data.empid, 'Payload empCode:', payload.data.employee_code, 'Local empid:', localEmpid, 'Local empCode:', localEmpCode);
          resolve();
        }
      });
    };
  });

  event.waitUntil(showPromise);
});







