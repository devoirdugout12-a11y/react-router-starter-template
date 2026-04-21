import { useParams, Link } from "react-router";
import { useEvents, BakatiketEvent } from "../hooks/useEvents";
import { useEffect, useState } from "react";
import { db } from "../lib/firebase";
import { ref, get, push, set } from "firebase/database";
import { useAuth } from "../lib/auth";
import { MapPin, Calendar, Clock, ChevronLeft, CreditCard, ShieldCheck } from "lucide-react";

export default function EventDetail() {
  const { id } = useParams();
  const { user } = useAuth();
  const [event, setEvent] = useState<BakatiketEvent | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedType, setSelectedType] = useState<string>("standard");
  const [quantity, setQuantity] = useState(1);
  const [bookingStatus, setBookingStatus] = useState<"idle" | "booking" | "success" | "error">("idle");

  useEffect(() => {
    if (!id) return;
    const eventRef = ref(db, `events/${id}`);
    get(eventRef).then((snapshot) => {
      if (snapshot.exists()) {
        setEvent({ ...snapshot.val(), id });
      }
      setLoading(false);
    });
  }, [id]);

  const handleBooking = async () => {
    if (!user || !event || bookingStatus === "booking") return;
    
    setBookingStatus("booking");
    try {
      const reservationRef = ref(db, `events/${event.id}/reservations`);
      const newReservationRef = push(reservationRef);
      
      await set(newReservationRef, {
        userId: user.uid,
        userName: user.displayName || "Anonyme",
        ticketType: selectedType,
        quantity: quantity,
        timestamp: Date.now(),
        status: "active"
      });

      setBookingStatus("success");
    } catch (err) {
      console.error(err);
      setBookingStatus("error");
    }
  };

  if (loading) return <div className="flex items-center justify-center min-h-screen neon-text-cyan underline">Recherche de l'événement...</div>;
  if (!event) return <div className="p-20 text-center">Événement introuvable. <Link to="/" className="text-neon-cyan">Retour à l'accueil</Link></div>;

  return (
    <div className="min-h-screen pb-20">
      {/* Cover Image */}
      <div className="relative h-[40vh] w-full">
        <img 
          src={event.image || "https://images.unsplash.com/photo-1492684223066-81342ee5ff30"} 
          alt={event.name}
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-[#03030b] to-transparent" />
        <Link to="/" className="absolute top-6 left-6 glass p-2 rounded-full hover:neon-border transition-all">
          <ChevronLeft size={24} />
        </Link>
      </div>

      <div className="max-w-6xl mx-auto px-6 -mt-32 relative z-10 grid grid-cols-1 lg:grid-cols-3 gap-12">
        {/* Left: Info */}
        <div className="lg:col-span-2">
          <div className="glass p-8 rounded-3xl mb-8">
            <h1 className="text-5xl font-black mb-6 neon-text-cyan uppercase tracking-tighter">{event.name}</h1>
            
            <div className="flex flex-wrap gap-6 mb-8 text-gray-300">
              <div className="flex items-center gap-2">
                <MapPin className="text-neon-pink" size={20} />
                <span className="font-bold">{event.location}</span>
              </div>
              <div className="flex items-center gap-2">
                <Calendar className="text-neon-pink" size={20} />
                <span>{new Date(event.startTime).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })}</span>
              </div>
              <div className="flex items-center gap-2">
                <Clock className="text-neon-pink" size={20} />
                <span>{new Date(event.startTime).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}</span>
              </div>
            </div>

            <div className="prose prose-invert max-w-none">
              <p className="text-lg leading-relaxed text-gray-400">
                {event.description}
              </p>
            </div>
          </div>
        </div>

        {/* Right: Booking Card */}
        <div className="lg:col-span-1">
          <div className="glass p-8 rounded-3xl sticky top-24 border border-white/10 group hover:neon-border transition-all duration-500">
            <h3 className="text-2xl font-bold mb-6 flex items-center gap-2">
              <CreditCard className="text-neon-cyan" /> Réservation
            </h3>

            {bookingStatus === "success" ? (
              <div className="text-center py-8">
                <ShieldCheck size={64} className="mx-auto text-green-500 mb-4 animate-bounce" />
                <h4 className="text-xl font-bold mb-2 text-green-500">Réservé !</h4>
                <p className="text-gray-400 text-sm mb-6">Votre ticket est validé. Retrouvez vos réservations dans votre profil.</p>
                <Link to="/" className="btn-premium w-full inline-block">Retour à l'accueil</Link>
              </div>
            ) : (
              <div className="space-y-6">
                <div>
                  <label className="text-xs text-gray-500 uppercase font-black mb-3 block">Choisir votre catégorie</label>
                  <div className="grid grid-cols-2 gap-3">
                    {Object.entries(event.maxTickets || {}).map(([type, max]) => (
                      <button
                        key={type}
                        onClick={() => setSelectedType(type)}
                        className={`p-3 rounded-xl border text-sm font-bold transition-all ${
                          selectedType === type 
                          ? 'border-neon-cyan bg-neon-cyan/20 text-neon-cyan shadow-[0_0_10px_rgba(0,255,255,0.3)]' 
                          : 'border-white/10 hover:border-white/30 text-gray-400'
                        }`}
                      >
                        {type.toUpperCase()}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="flex items-center justify-between p-4 bg-white/5 rounded-2xl border border-white/5">
                  <span className="font-bold">Quantité</span>
                  <div className="flex items-center gap-4">
                    <button 
                      onClick={() => setQuantity(Math.max(1, quantity - 1))}
                      className="w-8 h-8 flex items-center justify-center rounded-lg bg-white/5 hover:bg-white/10"
                    >-</button>
                    <span className="font-black text-xl w-6 text-center">{quantity}</span>
                    <button 
                      onClick={() => setQuantity(quantity + 1)}
                      className="w-8 h-8 flex items-center justify-center rounded-lg bg-white/5 hover:bg-white/10"
                    >+</button>
                  </div>
                </div>

                <div className="pt-4">
                  {!user ? (
                    <Link to="/login" className="btn-premium w-full flex items-center justify-center">
                      Connectez-vous pour réserver
                    </Link>
                  ) : (
                    <button 
                      onClick={handleBooking}
                      disabled={bookingStatus === "booking"}
                      className="btn-premium w-full flex items-center justify-center disabled:opacity-50"
                    >
                      {bookingStatus === "booking" ? "Traitement..." : "Confirmer la réservation"}
                    </button>
                  )}
                  <p className="text-[10px] text-gray-500 text-center mt-4 uppercase">Traitement sécurisé par Bakatiket Pay</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
