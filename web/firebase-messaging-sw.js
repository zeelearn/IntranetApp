


importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js");


firebase.initializeApp({
  apiKey: 'AIzaSyDDvVRpknNCx8KTmy1TO-BXW6kPmzPEyNc',
  appId: '1:411998223312:web:3ec3c688769d9aa2dd97d5',
  messagingSenderId: '411998223312',
  projectId: 'intranet-9fda2',
  authDomain: 'intranet-9fda2.firebaseapp.com',
  storageBucket: 'intranet-9fda2.appspot.com',
  measurementId: 'G-5DZKG2P4P9',
});



function storeNotificationInIndexedDB(data) {
  return new Promise((resolve) => {
    let req = indexedDB.open('background_notifications', 1);
    req.onupgradeneeded = function (e) {
      let db = e.target.result;
      if (!db.objectStoreNames.contains('notifications')) {
        db.createObjectStore('notifications', { keyPath: 'id', autoIncrement: true });
      }
    };
    req.onsuccess = function (e) {
      let db = e.target.result;
      if (!db.objectStoreNames.contains('notifications')) {
        resolve();
        return;
      }
      let tx = db.transaction(['notifications'], 'readwrite');
      let store = tx.objectStore('notifications');
      let record = {
        title: data.title || '',
        description: data.body || data.description || '',
        type: data.type || '',
        date: new Date().toISOString(),
        imageurl: data.url || data.imageurl || '',
        logoUrl: data.logo || data.logoUrl || '',
        bigImageUrl: data.bigimage || data.bigImageUrl || '',
        webViewLink: data.url || data.webViewLink || ''
      };
      let addReq = store.add(record);
      addReq.onsuccess = function () {
        console.log("Successfully stored background notification in IndexedDB", record);
        resolve();
      };
      addReq.onerror = function (err) {
        console.error("Failed to add record to IndexedDB notifications store", err);
        resolve();
      };
    };
    req.onerror = function (err) {
      console.error("Failed to open IndexedDB background_notifications", err);
      resolve();
    };
  });
}

const messaging = firebase.messaging();

self.addEventListener("notificationclick", function (event) {
  event.notification.close();

  const targetUrl = event.notification.data?.url || '/';
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(windowClients => {
      // for (const client of windowClients) {
      //   // Focus existing tab if same origin
      //   if (client.url.includes(self.location.origin) && "focus" in client) {
      //     return client.focus();
      //   }
      // }
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

  const pjpIdVal = payload.data.PjpId || payload.data.pjpId || payload.data.pjpid || '';
  const notificationOptions = {
    body: payload.data.body,
    icon: 'https://zeelearn.com/wp-content/uploads/zeelearnlogo_new171.png',
    data: Object.assign({}, payload.data, {
      url: (payload.data.type === 'PJP' && pjpIdVal)
        ? ('/?type=PJP&PjpId=' + pjpIdVal) : (payload.data.type === 'EXPENSE-COURIER')
          ? ('/courier_detail?claimId=' + (payload.data.cid || payload.data.claimId || payload.data.claimID || '') + '&eCode=' + (payload.data.employee_code || payload.data.employeeCode || '') + '&isAccch=' + (payload.data.isAccch || ''))
          : (payload.data.url || '/')
    })
  };

  const showPromise = new Promise((resolve) => {
    const showNotification = () => {
      storeNotificationInIndexedDB(payload.data).then(() => {
        self.registration.showNotification(notificationTitle, notificationOptions)
          .then(() => resolve())
          .catch((e) => {
            console.log('Error in showing notification - ', e);
            resolve();
          });
      });
    };

    if (payload.data.user_id && !payload.data.employee_code) {
      // Check logindetails
      let dbUserRequest = indexedDB.open('logindetails');
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

        Promise.all([getFromStore('userId'), getFromStore('userData')]).then(([localUserId, localUserData]) => {
          let matched = false;

          if (localUserId && payload.data.user_id == localUserId) {
            console.log('User id matching on userId - ', payload.data.user_id);
            matched = true;
          } else if (localUserData) {
            try {
              let parsedOfflineUserData = JSON.parse(localUserData);
              if (parsedOfflineUserData && parsedOfflineUserData.data && parsedOfflineUserData.data.user_info && parsedOfflineUserData.data.user_info[0]) {
                if (payload.data.user_id == parsedOfflineUserData.data.user_info[0].user_id) {
                  console.log('User id matching on parsed userData - ', payload.data.user_id);
                  matched = true;
                }
              }
            } catch (e) {
              console.log('Failed to parse userData', e);
            }
          }

          if (matched) {
            showNotification();
          } else {
            console.log('User id not matching or not found in logindetails.');
            resolve();
          }
        });
      };
    } else {
      // Check kidzeepref
      let dbUserRequest = indexedDB.open('kidzeepref');
      dbUserRequest.onerror = function (err) {
        console.error("kidzeepref Failed to open database:", err);
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
            showNotification();
          } else {
            console.log('User id not matching or not found in Intranet. Payload empid:', payload.data.empid, 'Payload empCode:', payload.data.employee_code, 'Local empid:', localEmpid, 'Local empCode:', localEmpCode);
            resolve();
          }
        });
      };
    }
  });

  event.waitUntil(showPromise);
});







