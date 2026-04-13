// auth-firebase.js - Logique d'authentification Bakatiket

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { 
    getAuth, 
    signInWithEmailAndPassword, 
    createUserWithEmailAndPassword, 
    sendPasswordResetEmail,
    onAuthStateChanged,
    signOut
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
import { 
    getDatabase, 
    ref, 
    set, 
    get 
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-database.js";

const firebaseConfig = {
    databaseURL: "https://baka-ticket-2026-default-rtdb.firebaseio.com/"
};

// Initialisation
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getDatabase(app);

// ─── LOGIQUE DE CONNEXION ────────────────────────────────────────────────────────

export async function login(email, password) {
    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;
        
        // Récupérer le rôle depuis la DB
        const userRef = ref(db, `users/${user.uid}`);
        const snapshot = await get(userRef);
        
        if (snapshot.exists()) {
            const userData = snapshot.val();
            localStorage.setItem('userRole', userData.role);
            redirectUser(userData.role);
        } else {
            // Par défaut si pas en DB
            localStorage.setItem('userRole', 'client');
            redirectUser('client');
        }
        return { success: true };
    } catch (error) {
        console.error("Login Error:", error);
        return { success: false, message: translateError(error.code) };
    }
}

// ─── LOGIQUE D'INSCRIPTION ──────────────────────────────────────────────────────

export async function signup(email, password, fullName, phone, role) {
    try {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        // Enregistrer en DB
        await set(ref(db, `users/${user.uid}`), {
            fullName: fullName,
            email: email,
            phone: phone,
            role: role,
            createdAt: Date.now(),
            commission: role === 'partner' ? 12 : 0
        });

        localStorage.setItem('userRole', role);
        redirectUser(role);
        return { success: true };
    } catch (error) {
        console.error("Signup Error:", error);
        return { success: false, message: translateError(error.code) };
    }
}

// ─── MOT DE PASSE OUBLIÉ ────────────────────────────────────────────────────────

export async function resetPassword(email) {
    try {
        await sendPasswordResetEmail(auth, email);
        return { success: true };
    } catch (error) {
        return { success: false, message: translateError(error.code) };
    }
}

// ─── REDIRECTION ───────────────────────────────────────────────────────────────

function redirectUser(role) {
    // Exception Super Admin par numéro
    const user = auth.currentUser;
    // Note: Dans une vraie app, on vérifierait le numéro via Firebase Auth Phone
    // Ici on simule par rapport au rôle stocké en DB ou au login hardcodé
    
    if (role === 'super-admin') {
        window.location.href = 'super-admin.html';
    } else if (role === 'partner') {
        window.location.href = 'partner-dashboard.html';
    } else {
        window.location.href = 'index.html';
    }
}

// ─── UTILS ────────────────────────────────────────────────────────────────────

function translateError(code) {
    switch (code) {
        case 'auth/invalid-credential': return "Email ou mot de passe incorrect.";
        case 'auth/email-already-in-use': return "Cet email est déjà utilisé.";
        case 'auth/weak-password': return "Mot de passe trop faible (min 6 caractères).";
        case 'auth/user-not-found': return "Aucun utilisateur trouvé avec cet email.";
        default: return "Une erreur est survenue. Veuillez réessayer.";
    }
}

// Persistance : redirection auto si déjà loggé
onAuthStateChanged(auth, async (user) => {
    if (user && window.location.pathname.includes('auth.html')) {
        const role = localStorage.getItem('userRole');
        if (role) redirectUser(role);
    }
});

window.authActions = { login, signup, resetPassword };
