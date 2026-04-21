import type { MetaFunction } from "react-router";
import { Link } from "react-router";
import { useEvents } from "../hooks/useEvents";
import { Ticket, MapPin, Calendar, ArrowRight } from "lucide-react";

export const meta: MetaFunction = () => {
  return [
    { title: "Bakatiket - Billetterie Numérique Congo" },
    { name: "description", content: "Réservez vos places pour les meilleurs événements au Congo." },
  ];
};

export default function Index() {
  const { events, loading } = useEvents();

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="pt-24 pb-12 px-6 text-center">
        <h1 className="text-6xl font-black mb-4 neon-text-cyan tracking-tighter">
          BAKATIKET
        </h1>
        <p className="text-xl text-gray-400 mb-8 max-w-2xl mx-auto">
          L'adrénaline des événements du Congo, à portée de clic.
          <span className="block text-neon-pink font-bold">Zéro file d'attente. 100% Autonome.</span>
        </p>
        <div className="flex justify-center gap-4">
          <a href="#events" className="btn-premium">Découvrir les événements</a>
          <Link to="/dashboard" className="glass px-6 py-3 rounded-full font-bold hover:bg-white/10 transition-all">
            Dashboard Partenaire
          </Link>
        </div>
      </section>

      {/* Events Grid */}
      <section id="events" className="max-w-7xl mx-auto px-6 py-12">
        <h2 className="text-3xl font-bold mb-8 flex items-center gap-2">
          <Ticket className="text-neon-pink" /> Événements en cours
        </h2>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1, 2, 3].map((n) => (
              <div key={n} className="glass rounded-3xl h-96 animate-pulse" />
            ))}
          </div>
        ) : events.length === 0 ? (
          <div className="text-center py-20 glass rounded-3xl">
            <p className="text-gray-500">Aucun événement actif pour le moment. Revenez bientôt !</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {events.map((event) => (
              <div key={event.id} className="glass rounded-3xl overflow-hidden group hover:neon-border transition-all duration-500">
                <div className="relative h-48 overflow-hidden">
                  <img 
                    src={event.image || "https://images.unsplash.com/photo-1492684223066-81342ee5ff30"} 
                    alt={event.name}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                  />
                  <div className="absolute top-4 right-4 bg-black/60 backdrop-blur-md px-3 py-1 rounded-full text-xs font-bold text-neon-cyan border border-neon-cyan/30">
                    {new Date(event.startTime).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}
                  </div>
                </div>

                <div className="p-6">
                  <h3 className="text-2xl font-bold mb-2 group-hover:neon-text-cyan transition-all">
                    {event.name}
                  </h3>
                  
                  <div className="space-y-2 mb-6 text-sm text-gray-400">
                    <div className="flex items-center gap-2">
                      <MapPin size={16} className="text-neon-pink" />
                      {event.location}
                    </div>
                    <div className="flex items-center gap-2">
                      <Calendar size={16} className="text-neon-pink" />
                      {new Date(event.startTime).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}
                    </div>
                  </div>

                  <Link 
                    to={`/event/${event.id}`} 
                    className="w-full flex items-center justify-center gap-2 py-3 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/10 group-hover:border-neon-cyan/50 transition-all font-bold"
                  >
                    Réserver <ArrowRight size={18} />
                  </Link>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
