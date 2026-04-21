import { useState, useEffect } from "react";
import { useAuth, getUserRole, setUserRole } from "../lib/auth";
import { db } from "../lib/firebase";
import { ref, push, set, onValue } from "firebase/database";
import { Plus, Users, BarChart3, LayoutDashboard, LogOut, Settings } from "lucide-react";
import { Link, useNavigate } from "react-router";

export default function Dashboard() {
  const { user, loading: authLoading } = useAuth();
  const [role, setRole] = useState<string | null>(null);
  const [isCreating, setIsCreating] = useState(false);
  const [activeTab, setActiveTab] = useState("overview");
  const navigate = useNavigate();

  // Form State
  const [formData, setFormData] = useState({
    name: "",
    location: "",
    description: "",
    startTime: "",
    endTime: "",
    imageUrl: "",
    tickets: {
      standard: 200,
      gold: 50,
      premium: 30,
      presidentiel: 10
    }
  });

  const [myEvents, setMyEvents] = useState<any[]>([]);

  useEffect(() => {
    if (!authLoading && !user) {
      navigate("/login");
    } else if (user) {
      getUserRole(user.uid).then(setRole);
      
      // Listen to partner's events
      const eventsRef = ref(db, "events");
      return onValue(eventsRef, (snapshot) => {
        const data = snapshot.val();
        if (data) {
          const list = Object.entries(data)
            .map(([id, val]: [string, any]) => ({ ...val, id }))
            .filter((e: any) => e.ownerId === user.uid);
          setMyEvents(list);
        }
      });
    }
  }, [user, authLoading, navigate]);

  const handleCreateEvent = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    const eventsRef = ref(db, "events");
    const newEventRef = push(eventsRef);
    
    const eventData = {
      ...formData,
      startTime: new Date(formData.startTime).getTime(),
      endTime: new Date(formData.endTime).getTime(),
      status: "active",
      ownerId: user.uid,
      createdAt: Date.now(),
      reservations: {}
    };

    await set(newEventRef, eventData);
    setIsCreating(false);
    alert("Événement créé avec succès !");
  };

  if (authLoading) return <div className="flex items-center justify-center h-screen neon-text-cyan">Chargement...</div>;

  return (
    <div className="flex min-h-screen bg-[#03030b]">
      {/* Sidebar */}
      <aside className="w-64 glass border-r border-white/5 hidden md:flex flex-col">
        <div className="p-6">
          <h1 className="text-2xl font-black neon-text-cyan">BAKATIKET</h1>
          <p className="text-[10px] text-gray-500 uppercase tracking-widest mt-1">Partner Portal</p>
        </div>

        <nav className="flex-1 px-4 space-y-2">
          <button 
            onClick={() => setActiveTab("overview")}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${activeTab === 'overview' ? 'bg-neon-cyan/20 text-neon-cyan' : 'text-gray-400 hover:bg-white/5'}`}
          >
            <LayoutDashboard size={20} /> Vue d'ensemble
          </button>
          <button 
            onClick={() => setActiveTab("events")}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${activeTab === 'events' ? 'bg-neon-cyan/20 text-neon-cyan' : 'text-gray-400 hover:bg-white/5'}`}
          >
            <BarChart3 size={20} /> Mes Événements
          </button>
          <button 
            className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-gray-400 hover:bg-white/5"
          >
            <Users size={20} /> Clients
          </button>
        </nav>

        <div className="p-4 border-t border-white/5">
          <button className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-red-500 hover:bg-red-500/10 transition-all font-bold">
            <LogOut size={20} /> Déconnexion
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-8">
        <header className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-3xl font-bold">Bienvenue, {user?.displayName || "Partenaire"}</h2>
            <p className="text-gray-400">Gérez vos événements et suivez vos ventes en temps réel.</p>
          </div>
          <button 
            onClick={() => setIsCreating(true)}
            className="btn-premium flex items-center gap-2"
          >
            <Plus size={20} /> Créer un événement
          </button>
        </header>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="glass p-6 rounded-3xl">
            <p className="text-gray-500 text-sm mb-1">Ventes Totales</p>
            <h4 className="text-3xl font-bold">0 FCFA</h4>
          </div>
          <div className="glass p-6 rounded-3xl">
            <p className="text-gray-500 text-sm mb-1">Billets Vendus</p>
            <h4 className="text-3xl font-bold">0</h4>
          </div>
          <div className="glass p-6 rounded-3xl">
            <p className="text-gray-500 text-sm mb-1">Événements Actifs</p>
            <h4 className="text-3xl font-bold">{myEvents.length}</h4>
          </div>
        </div>

        {/* My Events List */}
        <section className="glass rounded-3xl overflow-hidden">
          <div className="p-6 border-b border-white/5 flex justify-between items-center">
            <h3 className="font-bold">Derniers événements</h3>
            <button className="text-neon-cyan text-sm hover:underline">Voir tout</button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="text-xs text-gray-500 uppercase bg-white/5">
                <tr>
                  <th className="px-6 py-4">Événement</th>
                  <th className="px-6 py-4">Date</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Ventes</th>
                  <th className="px-6 py-4">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                {myEvents.map(event => (
                  <tr key={event.id} className="hover:bg-white/5 transition-all">
                    <td className="px-6 py-4 font-bold">{event.name}</td>
                    <td className="px-6 py-4 text-gray-400">{new Date(event.startTime).toLocaleDateString()}</td>
                    <td className="px-6 py-4">
                      <span className="px-2 py-1 rounded-full text-[10px] bg-green-500/20 text-green-500 border border-green-500/20">
                        {event.status}
                      </span>
                    </td>
                    <td className="px-6 py-4">0 FCFA</td>
                    <td className="px-6 py-4">
                      <button className="text-neon-cyan hover:underline text-sm">Détails</button>
                    </td>
                  </tr>
                ))}
                {myEvents.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-6 py-12 text-center text-gray-500">
                      Vous n'avez pas encore créé d'événement.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </section>

        {/* Reservation Modal (TBD) */}
      </main>

      {/* Creation Modal */}
      {isCreating && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-black/80 backdrop-blur-sm">
          <div className="glass w-full max-w-2xl rounded-3xl p-8 overflow-y-auto max-h-[90vh]">
            <h3 className="text-2xl font-bold mb-6 neon-text-cyan">Nouvel Événement</h3>
            <form onSubmit={handleCreateEvent} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <input 
                  type="text" placeholder="Nom de l'événement" required
                  className="bg-white/5 border border-white/10 rounded-xl p-3 w-full focus:outline-none focus:border-neon-cyan"
                  value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})}
                />
                <input 
                  type="text" placeholder="Lieu" required
                  className="bg-white/5 border border-white/10 rounded-xl p-3 w-full focus:outline-none focus:border-neon-cyan"
                  value={formData.location} onChange={e => setFormData({...formData, location: e.target.value})}
                />
              </div>
              <textarea 
                placeholder="Description" required rows={3}
                className="bg-white/5 border border-white/10 rounded-xl p-3 w-full focus:outline-none focus:border-neon-cyan"
                value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})}
              />
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs text-gray-500 mb-1 block uppercase">Début</label>
                  <input 
                    type="datetime-local" required
                    className="bg-white/5 border border-white/10 rounded-xl p-3 w-full focus:outline-none focus:border-neon-cyan"
                    value={formData.startTime} onChange={e => setFormData({...formData, startTime: e.target.value})}
                  />
                </div>
                <div>
                  <label className="text-xs text-gray-500 mb-1 block uppercase">Fin</label>
                  <input 
                    type="datetime-local" required
                    className="bg-white/5 border border-white/10 rounded-xl p-3 w-full focus:outline-none focus:border-neon-cyan"
                    value={formData.endTime} onChange={e => setFormData({...formData, endTime: e.target.value})}
                  />
                </div>
              </div>
              <input 
                type="url" placeholder="URL de l'image (Bannière)"
                className="bg-white/5 border border-white/10 rounded-xl p-3 w-full focus:outline-none focus:border-neon-cyan"
                value={formData.imageUrl} onChange={e => setFormData({...formData, imageUrl: e.target.value})}
              />
              
              <div className="pt-4 flex gap-4">
                <button type="submit" className="btn-premium flex-1">Publier l'événement</button>
                <button type="button" onClick={() => setIsCreating(false)} className="glass px-6 py-3 rounded-full font-bold">Annuler</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
