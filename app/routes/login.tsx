import { Link, useNavigate } from "react-router";
import { loginWithGoogle } from "../lib/auth";
import { LogIn, Github } from "lucide-react";

export default function Login() {
  const navigate = useNavigate();

  const handleGoogleLogin = async () => {
    try {
      await loginWithGoogle();
      navigate("/");
    } catch (err) {
      console.error(err);
      alert("Erreur de connexion");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-6">
      <div className="glass w-full max-w-md p-10 rounded-[3rem] border border-white/5 relative overflow-hidden group">
        <div className="absolute -top-24 -right-24 w-48 h-48 bg-neon-cyan/20 blur-3xl group-hover:bg-neon-cyan/40 transition-all rounded-full" />
        
        <div className="relative">
          <Link to="/" className="text-sm text-gray-500 hover:text-neon-cyan transition-all mb-8 inline-block uppercase font-black">
            ← Retour
          </Link>
          
          <h1 className="text-4xl font-black mb-2 neon-text-cyan tracking-tighter">CONNEXION</h1>
          <p className="text-gray-400 mb-10 text-sm">Accédez à vos billets et à votre dashboard.</p>

          <div className="space-y-4">
            <button 
              onClick={handleGoogleLogin}
              className="w-full flex items-center justify-center gap-4 py-4 rounded-3xl bg-white text-black font-black hover:shadow-[0_0_20px_white] transition-all"
            >
              <img src="https://www.google.com/favicon.ico" className="w-5 h-5" alt="Google" />
              Continuer avec Google
            </button>

            <button 
              className="w-full flex items-center justify-center gap-4 py-4 rounded-3xl bg-white/5 border border-white/10 text-white font-bold hover:bg-white/10 transition-all"
            >
              <Github size={20} />
              Continuer avec GitHub
            </button>
          </div>

          <div className="mt-12 pt-8 border-t border-white/5 text-center">
            <p className="text-xs text-gray-500 uppercase font-black mb-4">Ou par e-mail</p>
            <div className="space-y-4">
              <input 
                type="email" placeholder="Email"
                className="w-full bg-white/5 border border-white/5 rounded-2xl p-4 focus:outline-none focus:border-neon-cyan/50 text-sm"
              />
              <button 
                className="btn-premium w-full flex items-center justify-center gap-2"
              >
                C'est parti <LogIn size={18} />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
