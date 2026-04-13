"use client";

import React, { useState, useEffect } from "react";
import { 
  BarChart3, 
  Search, 
  ShieldCheck, 
  Zap, 
  TrendingUp, 
  MessageSquare, 
  ArrowLeft,
  ThumbsUp,
  ThumbsDown,
  Target,
  AlertCircle,
  Lightbulb,
  ArrowRight,
  CheckCircle2
} from "lucide-react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { IntelligenceService, ProductIntelligence } from "@/lib/services/intelligence";
import Link from "next/link";
import { useSearchParams } from "next/navigation";

export default function Dashboard() {
  const [intel, setIntel] = useState<ProductIntelligence | null>(null);
  const [loading, setLoading] = useState(true);
  const searchParams = useSearchParams();
  const productUrl = searchParams.get("url") || "";

  useEffect(() => {
    async function fetchIntel() {
      if (!productUrl) {
         setIntel(IntelligenceService.getMockIntelligence("IPHONE"));
         setLoading(false);
         return;
      }
      
      setLoading(true);
      try {
        const res = await fetch("/api/analyze", {
          method: "POST",
          body: JSON.stringify({ url: productUrl }),
          headers: { "Content-Type": "application/json" }
        });
        const data = await res.json();
        setIntel(data);
      } catch (e) {
        console.error("Dashboard Fetch Error:", e);
      } finally {
        setLoading(false);
      }
    }
    
    fetchIntel();
  }, [productUrl]);

  if (loading) return <LoadingState />;

  return (
    <div className="min-h-screen bg-slate-50">
      {/* ─── Dashboard Nav ─── */}
      <nav className="h-16 border-b border-slate-200 bg-white px-8 flex items-center justify-between sticky top-0 z-50">
        <div className="flex items-center gap-6">
          <Link href="/" className="text-slate-400 hover:text-indigo-600 transition-colors">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div className="h-4 w-[1px] bg-slate-200" />
          <div className="flex items-center gap-2">
            <div className="w-6 h-6 bg-indigo-600 rounded flex items-center justify-center">
              <BarChart3 className="text-white w-4 h-4" />
            </div>
            <span className="font-display font-bold text-lg text-slate-900 uppercase tracking-tight">
              Review<span className="text-indigo-600">Vetter</span>
            </span>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="relative group">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input 
              type="text" 
              placeholder="New Product Scan..." 
              className="pl-9 pr-4 py-2 bg-slate-100 border-none rounded-lg text-sm w-64 focus:ring-2 focus:ring-indigo-500 transition-all font-medium"
            />
          </div>
          <button className="bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm font-bold shadow-md shadow-indigo-600/10 hover:bg-indigo-700 transition-all">
            UPGRADE PRO
          </button>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-8 py-10">
        {/* ─── Header ─── */}
        <header className="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
          <div>
            <div className="inline-flex items-center gap-2 px-2 py-1 bg-indigo-50 text-indigo-600 text-[10px] font-black tracking-widest uppercase rounded mb-3">
              <Zap className="w-3 h-3 fill-current" />
              AI Synthesized Report
            </div>
            <h1 className="text-4xl font-display font-black text-slate-900">
              {intel?.productName}
            </h1>
            <p className="text-slate-500 font-medium mt-1">
              Based on 1,248 Amazon & Shopify reviews analyzed in real-time.
            </p>
          </div>

          <div className="flex items-center gap-3">
             <div className="px-6 py-4 bg-white border border-slate-200 rounded-2xl trust-card text-center">
                <span className="text-xs font-bold text-slate-400 block mb-1 uppercase tracking-tighter">Vetter Score</span>
                <span className="text-3xl font-black text-indigo-600">{intel?.score}%</span>
             </div>
             <div className={cn(
               "px-6 py-4 border rounded-2xl trust-card text-center",
               intel?.sentiment === "BULLISH" ? "bg-emerald-50 border-emerald-100" : "bg-red-50 border-red-100"
             )}>
                <span className="text-xs font-bold text-slate-400 block mb-1 uppercase tracking-tighter">Market Pulse</span>
                <span className={cn(
                  "text-3xl font-black",
                  intel?.sentiment === "BULLISH" ? "text-emerald-600" : "text-red-600"
                )}>{intel?.sentiment}</span>
             </div>
          </div>
        </header>

        {/* ─── Detailed Metrics & Feature Requests ─── */}
        <div className="grid md:grid-cols-3 gap-6 mb-12">
            <div className="md:col-span-2 bg-white rounded-3xl p-8 border border-slate-200 trust-card">
               <h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest mb-8">Performance Breakdown</h3>
               <div className="space-y-6">
                  <MetricBar label="Product Quality" value={intel?.details.quality || 0} color="bg-indigo-600" />
                  <MetricBar label="Value for Money" value={intel?.details.value || 0} color="bg-emerald-500" />
                  <MetricBar label="Shipping & Logistics" value={intel?.details.shipping || 0} color="bg-blue-500" />
                  <MetricBar label="Customer Support" value={intel?.details.support || 0} color="bg-amber-500" />
               </div>
            </div>

            <div className="bg-indigo-600 rounded-3xl p-8 text-white shadow-xl shadow-indigo-600/20">
               <h3 className="text-xs font-black tracking-widest text-indigo-200 uppercase mb-6 flex items-center gap-2">
                 <Lightbulb className="w-4 h-4" /> Top Feature Requests
               </h3>
               <ul className="space-y-4">
                  {intel?.featureRequests.map((req, i) => (
                    <li key={i} className="flex gap-3 text-sm font-medium leading-relaxed group">
                       <CheckCircle2 className="w-4 h-4 text-indigo-300 shrink-0 mt-0.5" />
                       {req}
                    </li>
                  ))}
               </ul>
            </div>
        </div>

        {/* ─── SWOT GRID ─── */}
        <div className="grid md:grid-cols-2 gap-6 mb-12">
            <SwotCard 
              type="STRENGTHS" 
              icon={<ThumbsUp className="w-5 h-5 text-emerald-600" />}
              items={intel?.swot.strengths || []}
              bgColor="bg-emerald-50/50"
              borderColor="border-emerald-100"
            />
            <SwotCard 
              type="WEAKNESSES" 
              icon={<ThumbsDown className="w-5 h-5 text-red-600" />}
              items={intel?.swot.weaknesses || []}
              bgColor="bg-red-50/50"
              borderColor="border-red-100"
            />
            <SwotCard 
              type="OPPORTUNITIES" 
              icon={<Lightbulb className="w-5 h-5 text-indigo-600" />}
              items={intel?.swot.opportunities || []}
              bgColor="bg-indigo-50/50"
              borderColor="border-indigo-100"
            />
            <SwotCard 
              type="THREATS" 
              icon={<Target className="w-5 h-5 text-amber-600" />}
              items={intel?.swot.threats || []}
              bgColor="bg-amber-50/50"
              borderColor="border-amber-100"
            />
        </div>

        {/* ─── Sample Reviews ─── */}
        <section className="mb-12">
            <h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest mb-6">Top Customer Signals</h3>
            <div className="grid md:grid-cols-3 gap-6">
               {intel?.sampleReviews.map((review, i) => (
                  <div key={i} className="bg-white p-6 rounded-2xl border border-slate-200 trust-card">
                     <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center gap-1">
                           {[...Array(5)].map((_, j) => (
                             <div key={j} className={cn("w-3 h-3 rounded-full", j < review.rating ? "bg-amber-400" : "bg-slate-200")} />
                           ))}
                        </div>
                        <span className="text-[10px] font-bold text-slate-400">{review.source}</span>
                     </div>
                     <h4 className="font-bold text-sm mb-2">{review.title}</h4>
                     <p className="text-xs text-slate-500 leading-relaxed italic">"{review.body}"</p>
                     <div className="mt-4 pt-4 border-t border-slate-100 flex items-center justify-between">
                        <span className="text-[10px] font-bold text-indigo-600">u/{review.author}</span>
                        <span className="text-[10px] text-slate-400">{review.date}</span>
                     </div>
                  </div>
               ))}
            </div>
        </section>

        {/* ─── Roadmap & Insights ─── */}
        <section className="bg-slate-900 rounded-3xl p-10 text-white shadow-2xl overflow-hidden relative">
          <div className="relative z-10">
            <div className="flex items-center gap-3 mb-8">
              <div className="w-10 h-10 bg-indigo-600 rounded-xl flex items-center justify-center">
                <ShieldCheck className="w-6 h-6" />
              </div>
              <h2 className="text-2xl font-display font-bold">Vetter Strategic Roadmap</h2>
            </div>
            
            <div className="grid md:grid-cols-3 gap-8">
              <RoadmapStep 
                num="01" 
                title="Immediate Fix" 
                desc="Address battery degradation complaints in r/Apple by updating firmwire power profiles." 
              />
              <RoadmapStep 
                num="02" 
                title="Market Expansion" 
                desc="High demand for 'Titanium Blue' color on Trustpilot suggests a limited edition run." 
              />
              <RoadmapStep 
                num="03" 
                title="Competitor Blow" 
                desc="Emphasize camera low-light performance in next ad cycle to counter S24 launch." 
              />
            </div>

            <button className="mt-12 bg-indigo-600 text-white px-8 py-3 rounded-xl font-bold transition-all flex items-center gap-2 group hover:bg-indigo-700">
               Generate Full Detailed Brief <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </button>
          </div>
          <div className="absolute top-0 right-0 w-1/3 h-full bg-indigo-600/10 blur-3xl rounded-full translate-x-1/2 -translate-y-1/2" />
        </section>
      </main>
    </div>
  );
}

function LoadingState() {
  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-8">
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ repeat: Infinity, duration: 1, ease: "linear" }}
        className="mb-8"
      >
        <div className="w-12 h-12 border-4 border-indigo-600 border-t-transparent rounded-full" />
      </motion.div>
      <h2 className="text-2xl font-display font-bold text-slate-900 mb-2">Synthesizing Product Pulse</h2>
      <p className="text-slate-500 font-medium">Aggregating reviews from Amazon & Shopify stores...</p>
    </div>
  );
}

function SwotCard({ type, icon, items, bgColor, borderColor }: any) {
  return (
    <div className={cn("p-8 rounded-3xl border trust-card", bgColor, borderColor)}>
       <div className="flex items-center justify-between mb-6">
          <h3 className="text-xs font-black tracking-widest text-slate-400 uppercase">{type}</h3>
          <div className="w-10 h-10 bg-white rounded-xl shadow-sm flex items-center justify-center">
            {icon}
          </div>
       </div>
       <ul className="space-y-4">
          {items.map((item: string, i: number) => (
            <li key={i} className="flex gap-3 text-slate-700 font-medium text-sm leading-relaxed">
               <div className="w-1.5 h-1.5 rounded-full bg-slate-200 mt-1.5 shrink-0" />
               {item}
            </li>
          ))}
       </ul>
    </div>
  );
}

function RoadmapStep({ num, title, desc }: any) {
  return (
    <div>
      <div className="text-3xl font-display font-black text-indigo-500/30 mb-2">{num}</div>
      <h4 className="font-bold text-lg mb-2">{title}</h4>
      <p className="text-slate-400 text-sm leading-relaxed">{desc}</p>
    </div>
  );
}

function MetricBar({ label, value, color }: { label: string, value: number, color: string }) {
  return (
    <div>
      <div className="flex items-center justify-between mb-2">
        <span className="text-xs font-bold text-slate-600">{label}</span>
        <span className="text-xs font-black text-slate-900">{value}%</span>
      </div>
      <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
        <motion.div 
          initial={{ width: 0 }}
          animate={{ width: `${value}%` }}
          transition={{ duration: 1, delay: 0.5 }}
          className={cn("h-full rounded-full", color)}
        />
      </div>
    </div>
  );
}
