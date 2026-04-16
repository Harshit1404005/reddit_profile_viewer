"use client";

import React, { useState } from "react";
import { 
  ShieldCheck, 
  Search, 
  Zap, 
  TrendingUp, 
  MessageSquare, 
  ArrowRight,
  ArrowLeft,
  ShoppingCart,
  CheckCircle2,
  Target
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Navbar from "@/components/Navbar";

export default function LandingPage() {
  const [url, setUrl] = useState("");
  const [compUrl, setCompUrl] = useState("");
  const [isCompare, setIsCompare] = useState(false);
  const router = useRouter();

  const handleAnalyze = () => {
    if (!url.trim()) return;
    const params = new URLSearchParams({ url });
    if (isCompare && compUrl.trim()) {
      params.append("compare", compUrl.trim());
    }
    router.push(`/dashboard?${params.toString()}`);
  };

  return (
    <div className="min-h-screen bg-[#FDFDFF] selection:bg-indigo-100 selection:text-indigo-900">
      <Navbar />
      
      <main className="pt-32 pb-20">
        {/* ─── Hero Section ─── */}
        <section className="max-w-7xl mx-auto px-6 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-50 border border-indigo-100 text-indigo-700 text-xs font-bold tracking-widest uppercase mb-6">
              <Zap className="w-3 h-3 fill-current" />
              Revolutionizing E-commerce Intelligence
            </div>
            <h1 className="text-6xl md:text-7xl font-display font-black text-slate-900 leading-tight mb-8 tracking-tighter">
              Know what your customers <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 to-violet-600">want. Before they do.</span>
            </h1>
            <p className="max-w-2xl mx-auto text-lg text-slate-500 font-medium leading-relaxed mb-12">
              ReviewVetter scans thousands of reviews in 60 seconds to identify product flaws, 
              scale winning ads, and <span className="text-slate-900 font-bold">recover lost revenue.</span>
            </p>

            <div className="flex flex-col md:flex-row items-center justify-center gap-4 mb-20">
              <Link href="/dashboard?demo=true" className="w-full md:w-auto px-8 py-4 bg-slate-900 text-white rounded-2xl font-black uppercase text-xs tracking-widest hover:bg-slate-800 transition-all shadow-xl shadow-slate-900/20">
                 See Live Demo
              </Link>
              <Link href="/signup" className="w-full md:w-auto px-8 py-4 bg-indigo-600 text-white rounded-2xl font-black uppercase text-xs tracking-widest hover:bg-indigo-700 transition-all shadow-xl shadow-indigo-600/30">
                 Get Started Free
              </Link>
            </div>

            <RoiCalculator />

            {/* ─── Comparison Mode Toggle ─── */}
            <div className="flex justify-center mb-10">
              <div className="inline-flex bg-slate-100 p-1 rounded-xl border border-slate-200">
                <button 
                  onClick={() => setIsCompare(false)}
                  className={cn(
                    "px-6 py-2 rounded-lg text-[10px] font-black uppercase tracking-widest transition-all",
                    !isCompare ? "bg-white text-indigo-600 shadow-sm" : "text-slate-500 hover:text-slate-700"
                  )}
                >
                  Single Scan
                </button>
                <button 
                  onClick={() => setIsCompare(true)}
                  className={cn(
                    "px-6 py-2 rounded-lg text-[10px] font-black uppercase tracking-widest transition-all",
                    isCompare ? "bg-white text-indigo-600 shadow-sm" : "text-slate-500 hover:text-slate-700"
                  )}
                >
                  Market Compare
                </button>
              </div>
            </div>

            <div className="max-w-4xl mx-auto relative group">
              <div className="absolute -inset-1 bg-gradient-to-r from-indigo-500 to-blue-500 rounded-2xl blur opacity-10 group-hover:opacity-25 transition duration-1000"></div>
              <div className={cn(
                "relative bg-white border border-slate-200 rounded-2xl p-2 flex flex-col md:flex-row items-stretch gap-2 shadow-2xl transition-all",
                isCompare && "ring-4 ring-indigo-50 border-indigo-200"
              )}>
                <div className="flex-1 flex items-center min-w-0">
                  <div className="pl-4 pr-3 text-slate-400">
                    <ShoppingCart className="w-5 h-5" />
                  </div>
                  <input 
                    type="text" 
                    placeholder={isCompare ? "Primary Product URL..." : "Paste Amazon or Shopify Product URL..."}
                    className="flex-1 bg-transparent border-none focus:ring-0 text-slate-900 text-base py-4 outline-hidden"
                    value={url}
                    onChange={(e) => setUrl(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleAnalyze()}
                  />
                </div>

                <AnimatePresence>
                  {isCompare && (
                    <motion.div 
                      initial={{ opacity: 0, width: 0 }}
                      animate={{ opacity: 1, width: "auto" }}
                      exit={{ opacity: 0, width: 0 }}
                      className="flex-1 flex items-center border-t md:border-t-0 md:border-l border-slate-100 min-w-0 overflow-hidden"
                    >
                      <div className="pl-4 pr-3 text-indigo-400">
                        <Target className="w-5 h-5" />
                      </div>
                      <input 
                        type="text" 
                        placeholder="Competitor URL..." 
                        className="flex-1 bg-transparent border-none focus:ring-0 text-slate-900 text-base py-4 outline-hidden"
                        value={compUrl}
                        onChange={(e) => setCompUrl(e.target.value)}
                        onKeyDown={(e) => e.key === "Enter" && handleAnalyze()}
                      />
                    </motion.div>
                  )}
                </AnimatePresence>

                <button 
                  onClick={handleAnalyze}
                  className="bg-indigo-600 hover:bg-slate-900 text-white px-8 py-4 rounded-xl font-black uppercase text-xs tracking-widest transition-all flex items-center justify-center gap-2 shrink-0 shadow-lg shadow-indigo-600/20 active:scale-95"
                >
                  {isCompare ? "Generate Battlecard" : "VET PRODUCT"} <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>

            <div className="mt-8 flex items-center justify-center gap-6 text-sm font-medium text-slate-400">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-500" /> No API Key Required
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-500" /> Multi-Source Scout
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-500" /> Comparison Engine
              </div>
            </div>
          </motion.div>
        </section>

        {/* ─── How It Works (Universal Process) ─── */}
        <section id="how-it-works" className="max-w-7xl mx-auto px-6 py-32 bg-white">
          <div className="text-center mb-20">
            <h2 className="text-4xl font-display font-black text-slate-900 mb-4 tracking-tight">The 60-Second Scout Process</h2>
            <p className="text-slate-500 font-medium">How ReviewVetter transforms raw reviews into market-winning assets.</p>
          </div>
          
          <div className="grid md:grid-cols-4 gap-8">
            <StepItem 
              num="01" 
              title="Connect Link" 
              desc="Paste any link from Amazon, Walmart, or Trustpilot. Our agents detect the platform automatically." 
            />
            <StepItem 
              num="02" 
              title="AI Scouting" 
              desc="Our deep-crawlers scan thousands of public reviews to identify core sentiment and product flaws." 
            />
            <StepItem 
              num="03" 
              title="AI Synthesis" 
              desc="Data is normalized into SWOT reports, 5-step strategic roadmaps, and competitor battlecards." 
            />
            <StepItem 
              num="04" 
              title="Scale & Fix" 
              desc="Copy-paste ready-to-use ad hooks and customer support responses to save your rating and win sales." 
            />
          </div>
        </section>

        {/* ─── Trust Bar ─── */}
        <section className="mt-20 border-y border-slate-200 bg-white/50 py-12">
          <div className="max-w-7xl mx-auto px-6">
            <p className="text-center text-xs font-bold tracking-widest text-slate-400 uppercase mb-8">Trusted by data-driven brands</p>
            <div className="flex flex-wrap justify-center gap-12 opacity-50 grayscale hover:grayscale-0 transition-all duration-500">
               {/* Placeholders for logos */}
               <span className="font-display font-black text-2xl text-slate-900 italic">Shopify Plus</span>
               <span className="font-display font-black text-2xl text-slate-900">Amazon Brand</span>
               <span className="font-display font-black text-2xl text-slate-900 opacity-80">FlowCommerce</span>
               <span className="font-display font-black text-2xl text-slate-900 italic">Trustpilot</span>
            </div>
          </div>
        </section>

        {/* ─── Why This Idea Wins (Value Props) ─── */}
        <section id="features" className="max-w-7xl mx-auto px-6 py-20">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-display font-black text-slate-900 mb-4 tracking-tight">The SaaS Edge for E-commerce</h2>
            <p className="text-slate-500 font-medium">Built to solve the #1 pain point store owners beg for on r/ecommerce.</p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            <FeatureCard 
              icon={<TrendingUp className="text-indigo-600" />}
              title="Revenue Recovery"
              description="Identify exactly how much MRR is leaking through specific product flaws. Fix issues for an estimated 12-18% revenue lift."
            />
            <FeatureCard 
              icon={<Zap className="text-indigo-600" />}
              title="AI Ad Creative Studio"
              description="Instantly generate high-converting Meta and TikTok ad hooks based on customer-verified strengths. Copy, paste, and scale."
            />
            <FeatureCard 
              icon={<ShieldCheck className="text-indigo-600" />}
              title="Negative Review Assistant"
              description="Automatically draft professional responses to common complaints. Turn frustrated customers into brand advocates in seconds."
            />
          </div>
        </section>

        {/* ─── Pricing Section ─── */}
        <section id="pricing" className="max-w-7xl mx-auto px-6 py-32 bg-slate-900 rounded-[3rem] text-white overflow-hidden relative">
          <div className="relative z-10 text-center mb-16">
            <h2 className="text-4xl font-display font-black mb-4">Scalable Intelligence</h2>
            <p className="text-slate-400 font-medium italic">High-growth plans for brands and agencies.</p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8 relative z-10 mb-12">
             <PriceCard 
               tier="Starter" 
               price="0" 
               desc="3 product analyses/month." 
               features={["Amazon + Trustpilot", "SWOT Matrix", "Email Support"]} 
             />
             <PriceCard 
               tier="Pro" 
               price="29" 
               desc="Everything you need to scale." 
               features={["30 analyses/mo", "All platforms", "Revenue Leakage AI", "Ad Creative Studio", "PDF Exports"]} 
               featured
             />
             <PriceCard 
               tier="Agency" 
               price="79" 
               desc="Unlimited for brands." 
               features={["Unlimited Scans", "White-label PDFs", "Team Seats", "Priority Queue"]} 
             />
          </div>

          <div className="text-center relative z-10">
             <Link href="/pricing" className="text-sm font-bold text-indigo-400 hover:text-white transition-colors underline flex items-center justify-center gap-2">
                View Full Plan Comparison & One-Time Audits <ArrowLeft className="w-3 h-3 rotate-180" />
             </Link>
          </div>
        </section>
      </main>

      {/* ─── Footer ─── */}
      <footer className="border-t border-slate-200 py-20 bg-white">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid md:grid-cols-4 gap-12 mb-16">
            <div className="md:col-span-2">
              <div className="flex items-center gap-2 mb-6">
                <div className="w-8 h-8 bg-indigo-600 rounded-lg flex items-center justify-center">
                  <ShieldCheck className="text-white w-5 h-5" />
                </div>
                <span className="font-display font-bold text-xl tracking-tight text-slate-900">
                  ReviewVetter
                </span>
              </div>
              <p className="text-slate-500 text-sm font-medium leading-relaxed max-w-xs mb-8">
                Building the future of e-commerce intelligence with transparent, public-data analysis.
              </p>
              <div className="flex items-center gap-4 grayscale opacity-50">
                <div className="px-3 py-1 border border-slate-300 rounded text-[10px] font-black uppercase">GDPR Ready</div>
                <div className="px-3 py-1 border border-slate-300 rounded text-[10px] font-black uppercase">AES-256 SSL</div>
                <div className="px-3 py-1 border border-slate-300 rounded text-[10px] font-black uppercase">SOC2 Type II</div>
              </div>
            </div>

            <div>
              <h4 className="font-bold text-sm text-slate-900 mb-6 uppercase tracking-widest text-[10px]">Product</h4>
              <ul className="space-y-4 text-sm font-medium text-slate-500">
                <li><a href="#how-it-works" className="hover:text-indigo-600 transition-colors">How it Works</a></li>
                <li><a href="#features" className="hover:text-indigo-600 transition-colors">Features</a></li>
                <li><a href="#pricing" className="hover:text-indigo-600 transition-colors">Pricing</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold text-sm text-slate-900 mb-6 uppercase tracking-widest text-[10px]">Legal</h4>
              <ul className="space-y-4 text-sm font-medium text-slate-500">
                <li><Link href="/privacy" className="hover:text-indigo-600 transition-colors">Privacy Policy</Link></li>
                <li><Link href="/terms" className="hover:text-indigo-600 transition-colors">Terms of Service</Link></li>
                <li><a href="mailto:support@reviewvetter.com" className="hover:text-indigo-600 transition-colors">Contact Support</a></li>
              </ul>
            </div>
          </div>
          
          <div className="pt-8 border-t border-slate-100 flex flex-col md:flex-row justify-between items-center gap-4 text-slate-400 text-xs font-bold uppercase tracking-widest">
            <p>© 2026 ReviewVetter Intelligence Inc. All rights reserved.</p>
            <p>Made for Growth Founders.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

function StepItem({ num, title, desc }: { num: string, title: string, desc: string }) {
  return (
    <div className="relative p-8 rounded-3xl border border-slate-100 hover:border-indigo-100 transition-all bg-white group">
      <div className="text-5xl font-display font-black text-indigo-50/50 absolute top-4 right-8 group-hover:text-indigo-50 transition-colors">
        {num}
      </div>
      <div className="relative z-10 pt-8">
        <h4 className="font-display font-bold text-xl text-slate-900 mb-3">{title}</h4>
        <p className="text-slate-500 text-sm leading-relaxed">{desc}</p>
      </div>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  return (
    <div className="bg-white p-8 rounded-3xl border border-slate-200 trust-card">
      <div className="w-12 h-12 bg-indigo-50 rounded-2xl flex items-center justify-center mb-6">
        {icon}
      </div>
      <h3 className="font-display font-bold text-xl text-slate-900 mb-3">{title}</h3>
      <p className="text-slate-600 leading-relaxed text-sm">{description}</p>
    </div>
  );
}

function PriceCard({ tier, price, desc, features, featured }: any) {
  return (
    <div className={cn(
      "p-10 rounded-3xl border transition-all relative",
      featured ? "bg-indigo-600 border-indigo-500 scale-105 shadow-2xl shadow-indigo-600/30" : "bg-white/5 border-white/10"
    )}>
       {featured && <span className="absolute -top-4 left-1/2 -translate-x-1/2 bg-white text-indigo-600 px-4 py-1 rounded-full text-[10px] font-black uppercase tracking-widest z-20">Most Popular</span>}
       <h3 className="text-xl font-bold mb-2">{tier}</h3>
       <p className={cn("text-xs mb-8", featured ? "text-indigo-200" : "text-slate-400")}>{desc}</p>
       <div className="flex items-baseline gap-1 mb-8">
          <span className="text-4xl font-black">${price}</span>
          <span className={cn("text-xs font-bold", featured ? "text-indigo-200" : "text-slate-500")}>/mo</span>
       </div>
       <ul className="space-y-4 mb-10">
          {features.map((f: string, i: number) => (
            <li key={i} className="flex items-center gap-2 text-sm font-medium">
               <CheckCircle2 className={cn("w-4 h-4", featured ? "text-indigo-300" : "text-emerald-500")} /> {f}
            </li>
          ))}
       </ul>
       <Link href="/signup" className={cn(
         "w-full py-3 rounded-xl font-bold transition-all flex items-center justify-center",
         featured ? "bg-white text-indigo-600 hover:bg-slate-100" : "bg-indigo-600 text-white hover:bg-indigo-700"
       )}>
          Get Started
       </Link>
    </div>
  );
}
function RoiCalculator() {
  const [rev, setRev] = useState(10000);
  const [rate, setRate] = useState(3.5);
  
  const lost = Math.max(0, rev * (4.5 - rate) * 0.04);

  return (
    <div className="max-w-md mx-auto bg-white border border-slate-200 rounded-[2rem] p-8 shadow-2xl relative overflow-hidden mb-20 group">
       <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-50/50 rounded-full -mr-16 -mt-16 transition-transform group-hover:scale-110" />
       <h3 className="text-sm font-black text-slate-400 uppercase tracking-widest mb-6">Revenue Leakage Calculator</h3>
       
       <div className="space-y-6 relative z-10">
          <div>
            <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 text-left">Monthly Revenue ($)</label>
            <input 
              type="number" 
              value={rev} 
              onChange={(e) => setRev(Number(e.target.value))}
              className="w-full bg-slate-50 border-none rounded-xl px-4 py-3 text-slate-900 font-bold focus:ring-2 focus:ring-indigo-600 outline-hidden" 
            />
          </div>
          <div>
             <div className="flex justify-between mb-2">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest text-left">Current Rating</label>
                <span className="text-xs font-bold text-indigo-600">{rate} ★</span>
             </div>
             <input 
               type="range" 
               min="1" max="5" step="0.1" 
               value={rate} 
               onChange={(e) => setRate(Number(e.target.value))}
               className="w-full accent-indigo-600 h-1.5 bg-slate-100 rounded-lg appearance-none cursor-pointer" 
             />
          </div>

          <div className="pt-6 border-t border-slate-100">
             <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1 leading-none">Estimated Monthly Loss</div>
             <div className="text-4xl font-black text-red-500 tabular-nums">${lost.toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 0 })}</div>
             <p className="text-[9px] text-slate-400 mt-2 font-medium italic">Based on avg 4% conversion loss per 0.5★ drop below 4.5</p>
          </div>
       </div>
    </div>
  );
}
