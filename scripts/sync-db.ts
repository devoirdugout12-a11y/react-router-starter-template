import { db } from "../app/lib/firebase";
import { ref, set, remove } from "firebase/database";

/**
 * Reset and initialize the database structure for Bakatiket.
 * Path: scripts/sync-db.ts
 */
export async function resetDatabase() {
  console.log("🔥 Réinitialisation de la base de données baka-ticket-2026...");
  
  try {
    // 1. Wipe current root (Caution: starts from zero)
    await remove(ref(db, "/"));

    // 2. Initialize Core Structure
    await set(ref(db, "events"), {});
    await set(ref(db, "users"), {});
    await set(ref(db, "archived_events"), {});

    // 3. Add a Demo Event for the "Wow" factor
    const demoId = "demo-event-2026";
    await set(ref(db, `events/${demoId}`), {
      name: "Bakatiket Launch - Pointe-Noire",
      location: "Palais de la Culture",
      description: "Le lancement officiel de la billetterie autonome au Congo. Venez vivre l'expérience Bakatiket !",
      startTime: Date.now() + 86400000, // Demain
      endTime: Date.now() + 172800000,   // Après-demain
      maxTickets: {
        standard: 500,
        gold: 100,
        premium: 50,
        presidentiel: 10
      },
      image: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&q=80&w=2070",
      status: "active",
      ownerId: "system",
      createdAt: Date.now()
    });

    console.log("✅ Base de données synchronisée avec succès !");
  } catch (error) {
    console.error("❌ Erreur lors de la synchronisation :", error);
  }
}
