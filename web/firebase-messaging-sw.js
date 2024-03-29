importScripts('https://www.gstatic.com/firebasejs/3.5.2/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/3.5.2/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyDnrm3FPGzLcP1g_U0IZrd39o8qUqgsk5o",
  authDomain: "zipbuzz-prod.firebaseapp.com",
  databaseURL: "https://zipbuzz-prod-default-rtdb.firebaseio.com",
  projectId: "zipbuzz-prod",
  storageBucket: "zipbuzz-prod.appspot.com",
  messagingSenderId: "892338366790",
  appId: "1:892338366790:web:38ff4d54d4a1bb85469d47",
  measurementId: "G-1CCE22HZC2"
});

// Retrieve Firebase Messaging object.
const messaging = firebase.messaging();