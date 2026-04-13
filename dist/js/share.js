// js/share.js - Partage et QR Codes

export function shareEvent(id, title) {
    const shareUrl = `${window.location.origin}/event/${id}`;
    
    if (navigator.share) {
        navigator.share({
            title: title || 'Bakatiket - Billetterie Congo',
            text: `Réservez vos places pour ${title} sur Bakatiket !`,
            url: shareUrl,
        })
        .then(() => console.log('Partage réussi'))
        .catch((error) => console.log('Erreur de partage', error));
    } else {
        // Fallback: Copier dans le presse-papier
        navigator.clipboard.writeText(shareUrl).then(() => {
            alert('Lien copié dans le presse-papier !');
        });
    }
}

export function generateQRUrl(id) {
    const shareUrl = `${window.location.origin}/event/${id}`;
    return `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${encodeURIComponent(shareUrl)}`;
}

window.shareEvent = shareEvent;
window.generateQRUrl = generateQRUrl;
