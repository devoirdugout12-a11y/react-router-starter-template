// js/firebase.js - Initialisation et logique Realtime DB

// Import Firebase SDK via CDN
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getDatabase, ref, onValue, push, set } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-database.js";

const firebaseConfig = {
    databaseURL: "https://baka-ticket-2026-default-rtdb.firebaseio.com/"
};

// Initialisation
const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

// Référence aux événements
const eventsRef = ref(db, 'events');

// Fonction pour mettre à jour l'accueil en temps réel
export function listenToEvents(callback) {
    onValue(eventsRef, (snapshot) => {
        const data = snapshot.val();
        callback(data);
    });
}

// Fonction pour créer un événement
export async function createEvent(eventData) {
    const newEventRef = push(eventsRef);
    await set(newEventRef, {
        ...eventData,
        id: newEventRef.key,
        createdAt: Date.now()
    });
    return newEventRef.key;
}

window.bakatiket = { db, eventsRef };
