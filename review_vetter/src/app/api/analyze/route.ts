import { NextRequest, NextResponse } from "next/server";
import { IntelligenceService } from "@/lib/services/intelligence";

export async function POST(req: NextRequest) {
  try {
    const { url } = await req.json();
    const token = process.env.APIFY_TOKEN;

    if (!url) {
      return NextResponse.json({ error: "Product URL is required" }, { status: 400 });
    }

    // 1 ── Determine if we can do a REAL analysis
    const isAmazon = url.toLowerCase().includes("amazon.");
    
    if (isAmazon && token) {
      try {
        const reviews = await IntelligenceService.fetchRealReviews(url, token);
        const productName = url.split("/dp/")[0]?.split("/").pop()?.replace(/-/g, " ") || "Product Scan";
        const intel = IntelligenceService.analyzeReviews(productName, reviews);
        return NextResponse.json(intel);
      } catch (e) {
        console.error("Real Analysis Failed, falling back to mock:", e);
      }
    }

    // 2 ── Fallback: Determine product type from URL (Simulated for MVP)
    let type: "IPHONE" | "DYSON" | "NONE" = "NONE";
    if (url.toLowerCase().includes("iphone")) type = "IPHONE";
    if (url.toLowerCase().includes("dyson") || url.toLowerCase().includes("airwrap")) type = "DYSON";

    // Simulate Network Latency for "Wait" experience
    await new Promise((resolve) => setTimeout(resolve, 2000));

    // Get Intelligence
    const intel = IntelligenceService.getMockIntelligence(type);

    return NextResponse.json(intel);
  } catch (error) {
    console.error("API Error:", error);
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
  }
}
