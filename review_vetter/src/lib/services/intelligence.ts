import { MessageSquare, ThumbsUp, ThumbsDown, Target, Zap } from "lucide-react";

export type Sentiment = "BULLISH" | "FRUSTRATED" | "NEUTRAL" | "STABLE";

export interface Review {
  id: string;
  rating: number;
  title: string;
  body: string;
  author: string;
  date: string;
  source: "AMAZON" | "SHOPIFY" | "WALMART";
}

export interface ProductIntelligence {
  productName: string;
  score: number; // 0-100
  sentiment: Sentiment;
  topPros: string[];
  topCons: string[];
  swot: {
    strengths: string[];
    weaknesses: string[];
    opportunities: string[];
    threats: string[];
  };
  details: {
    quality: number;
    value: number;
    shipping: number;
    support: number;
  };
  featureRequests: string[];
  sampleReviews: Review[];
}

export class IntelligenceService {
  /**
   * Analyzes an array of reviews to generate a SWOT intelligence report.
   * Reuses the aggregation logic from SubVetter but tailored for Product Quality.
   */
  static analyzeReviews(productName: string, reviews: Review[]): ProductIntelligence {
    if (reviews.length === 0) {
      throw new Error("No reviews provided for analysis.");
    }

    // 1 ── Aggregate Sentiment
    const avgRating = reviews.reduce((acc, r) => acc + r.rating, 0) / reviews.length;
    let sentimentScore = 0;
    
    // 2 ── Extraction & Keyword Analysis
    const wordFreq: Record<string, number> = {};
    const commonWords = new Set(["product", "ordered", "bought", "amazon", "really", "everything"]);

    reviews.forEach(r => {
      const text = `${r.title} ${r.body}`.toLowerCase();
      
      // Intent/Sentiment Detection (Logic from RedditService ported)
      if (text.match(/love|amazing|best|quality|perfect/)) sentimentScore++;
      if (text.match(/broken|waste|return|terrible|scam/)) sentimentScore--;

      const words = text.split(/\W+/);
      words.forEach(w => {
        if (w.length > 5 && !commonWords.has(w)) {
          wordFreq[w] = (wordFreq[w] || 0) + 1;
        }
      });
    });

    const topKeywords = Object.entries(wordFreq)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 10)
      .map(([w]) => w.toUpperCase());

    // 3 ── SWOT Synthesis (Rules-based for MVP)
    const strengths = topKeywords.slice(0, 3);
    const weaknesses = topKeywords.slice(3, 6);

    sw.stop();

    return {
      productName,
      score: Math.round((avgRating / 5) * 100),
      sentiment: avgRating > 4.2 ? "BULLISH" : (avgRating < 3 ? "FRUSTRATED" : "NEUTRAL"),
      topPros: strengths,
      topCons: weaknesses,
      swot: {
        strengths: strengths.map(s => `${s} Excellence`),
        weaknesses: weaknesses.map(w => `Issues with ${w}`),
        opportunities: ["Aggressive expansion into EU markets", "Social media 'Viral' potential via TikTok influencers"],
        threats: ["Growing competition from white-label brands", "Supply chain volatility in Q4"]
      },
      details: {
        quality: Math.min(100, (avgRating * 20) + 10),
        value: Math.min(100, (avgRating * 20) - 5),
        shipping: 95,
        support: 88,
      },
      featureRequests: [
        `Improve ${weaknesses[0] || 'durability'} in next iteration`,
        "Provide more eco-friendly packaging options",
        "Add multi-language support for user manuals"
      ],
      sampleReviews: reviews.slice(0, 3)
    };
  }

  /**
   * Generates mock data for top-tier e-commerce products for demonstration.
   */
  static getMockIntelligence(product: "IPHONE" | "DYSON" | "NONE"): ProductIntelligence {
    const products = {
      IPHONE: {
        name: "iPhone 15 Pro Max",
        reviews: [
          { id: "1", rating: 5, title: "Incredible camera", body: "The titanium finish is elite. Photos are professional grade.", author: "TechGuru", date: "2024-01-12", source: "AMAZON" as const },
          { id: "2", rating: 4, title: "Battery is okay", body: "Lasts all day but charging speed is still slow compared to Android.", author: "DailyUser", date: "2024-01-10", source: "SHOPIFY" as const },
        ]
      },
      DYSON: {
        name: "Dyson Airwrap Multi-Styler",
        reviews: [
          { id: "3", rating: 5, title: "Worth every penny", body: "My hair has never looked better. It's expensive but replaces everything else.", author: "BeautyVlogger", date: "2024-02-01", source: "AMAZON" as const },
          { id: "4", rating: 2, title: "Overpriced tech", body: "It's too loud and takes forever to learn how to use correctly.", author: "FrustratedMom", date: "2024-01-25", source: "WALMART" as const },
        ]
      }
    };

    const target = product === "NONE" ? products.IPHONE : products[product];
    return this.analyzeReviews(target.name, target.reviews);
  }
}
