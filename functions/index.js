const { onValueUpdated } = require("firebase-functions/v2/database");
const { getDatabase } = require("firebase-admin/database");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Automatiquement expire les événements dont la date de fin est passée.
 */
exports.expireEvents = onValueUpdated("/events/{eventId}", async (event) => {
    const eventData = event.data.after.val();
    
    if (!eventData || eventData.status === "expired") return;

    const now = Date.now();
    const endTime = eventData.endTime;

    if (now > endTime) {
        console.log(`Expiring event ${event.params.eventId}: ${eventData.name}`);
        
        // Mettre à jour le statut pour qu'il n'apparaisse plus sur l'accueil
        await event.data.after.ref.update({
            status: "expired"
        });

        // Optionnel: Archiver les réservations si nécessaire
        const reservations = eventData.reservations;
        if (reservations) {
            const db = getDatabase();
            await db.ref(`archived_events/${event.params.eventId}`).set({
                ...eventData,
                archivedAt: now
            });
        }
    }
});
