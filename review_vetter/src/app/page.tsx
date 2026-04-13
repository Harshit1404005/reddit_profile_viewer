"use client";

import React, { useState } from "react";
import { 
  BarChart3, 
  Search, 
  ShieldCheck, 
  Zap, 
  TrendingUp, 
  MessageSquare, 
  ArrowRight,
  ShoppingCart,
  CheckCircle2
} from "lucide-react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useRouter } from "next/navigation";

export default function LandingPage() {
  const [url, setUrl] = useState("");
  const router = useRouter();

  const handleAnalyze = () => {
    if (!url.trim()) return;
    router.push(`/dashboard?url=${encodeURIComponent(url)}`);
  };

  return (
    <div className="min-h-screen bg-slate-50 selection:bg-indigo-100 selection:text-indigo-700">
      {/* ─── Navigation ─── */}
      <nav className="fixed top-0 w-full z-50 bg-white/80 backdrop-blur-md border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-indigo-600 rounded-lg flex items-center justify-center">
              <BarChart3 className="text-white w-5 h-5" />
            </div>
            <span className="font-display font-bold text-xl tracking-tight text-slate-900">
              Review<span className="text-indigo-600">Vetter</span>
            </span>
          </div>
          
          <div className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-600">
            <a href="#features" className="hover:text-indigo-600 transition-colors">Features</a>
            <a href="#how-it-works" className="hover:text-indigo-600 transition-colors">How it Works</a>
            <a href="#pricing" className="hover:text-indigo-600 transition-colors">Pricing</a>
          </div>

          <div className="flex items-center gap-4">
            <button className="text-sm font-semibold text-slate-700 hover:text-indigo-600">Log In</button>
            <button className="bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2.5 rounded-full text-sm font-bold shadow-lg shadow-indigo-600/20 transition-all hover:scale-105 active:scale-95">
              Get Started
            </button>
          </div>
        </div>
      </nav>

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
            <h1 className="text-5xl md:text-7xl font-display font-extrabold text-slate-900 leading-[1.1] mb-8 max-w-4xl mx-auto text-balance">
              Discover why they buy. <br />
              <span className="text-indigo-600">Fix why they leave.</span>
            </h1>
            <p className="text-lg md:text-xl text-slate-600 max-w-2xl mx-auto mb-12 leading-relaxed">
              Synthesize 10,000+ reviews into an actionable SWOT report in 30 seconds. Stop drowning in data and start building better products.
            </p>

            <div className="max-w-2xl mx-auto relative group">
              <div className="absolute -inset-1 bg-gradient-to-r from-indigo-500 to-blue-500 rounded-2xl blur opacity-25 group-hover:opacity-40 transition duration-1000 group-hover:duration-200"></div>
              <div className="relative bg-white border border-slate-200 rounded-2xl p-2 flex items-center shadow-xl">
                <div className="pl-4 pr-3 text-slate-400">
                  <ShoppingCart className="w-5 h-5" />
                </div>
                <input 
                  type="text" 
                  placeholder="Paste Amazon or Shopify Product URL..." 
                  className="flex-1 bg-transparent border-none focus:ring-0 text-slate-900 text-base py-3 outline-hidden"
                  value={url}
                  onChange={(e) => setUrl(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleAnalyze()}
                />
                <button 
                  onClick={handleAnalyze}
                  className="bg-indigo-600 hover:bg-indigo-700 text-white px-8 py-3 rounded-xl font-bold transition-all flex items-center gap-2"
                >
                  Analyze <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>

            <div className="mt-8 flex items-center justify-center gap-6 text-sm font-medium text-slate-400">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-500" /> No API Key Required
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-500" /> Supports Shopify & Amazon
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-500" /> SWOT Report in 30s
              </div>
            </div>
          </motion.div>
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

        {/* ─── Features Grid ─── */}
        <section id="features" className="max-w-7xl mx-auto px-6 py-32">
          <div className="grid md:grid-cols-3 gap-8">
            <FeatureCard 
              icon={<TrendingUp className="text-indigo-600" />}
              title="SWOT Synthesis"
              description="Automatically generate Strengths, Weaknesses, Opportunities, and Threats for any SKU in seconds."
            />
            <FeatureCard 
              icon={<MessageSquare className="text-indigo-600" />}
              title="Sentiment Heatmaps"
              description="Visualize exactly where customer frustration is leaking into your reviews and fix it."
            />
            <FeatureCard 
              icon={<ShieldCheck className="text-indigo-600" />}
              title="Competitor Spying"
              description="Enter your competitor's link to see their product flaws and steal their market share."
            />
          </div>
        </section>
      </main>

      {/* ─── Footer ─── */}
      <footer className="border-t border-slate-200 py-12 bg-white">
        <div className="max-w-7xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-8">
           <div className="flex items-center gap-2">
            <div className="w-6 h-6 bg-indigo-600 rounded flex items-center justify-center">
              <BarChart3 className="text-white w-4 h-4" />
            </div>
            <span className="font-display font-bold text-lg tracking-tight text-slate-900">
              ReviewVetter
            </span>
          </div>
          <p className="text-slate-400 text-sm">© 2026 ReviewVetter Intelligence Inc. Built for Growth.</p>
        </div>
      </footer>
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
