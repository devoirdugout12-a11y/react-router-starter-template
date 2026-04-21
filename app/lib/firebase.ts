import { initializeApp } from "firebase/app";
import { getDatabase } from "firebase/database";
import { getAuth } from "firebase/auth";

// These should be environment variables in a real project
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "baka-ticket-2026.firebaseapp.com",
  databaseURL: "https://baka-ticket-2026-default-rtdb.firebaseio.com/",
  projectId: "baka-ticket-2026",
  storageBucket: "baka-ticket-2026.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
export const db = getDatabase(app);
export const auth = getAuth(app);
export default app;
