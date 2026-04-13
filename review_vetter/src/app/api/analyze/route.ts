import { NextRequest, NextResponse } from "next/server";
import { IntelligenceService } from "@/lib/services/intelligence";

export async function POST(req: NextRequest) {
  try {
    const { url } = await req.json();

    if (!url) {
      return NextResponse.json({ error: "Product URL is required" }, { status: 400 });
    }

    // Determine product type from URL (Simulated for MVP)
    let type: "IPHONE" | "DYSON" | "NONE" = "NONE";
    if (url.toLowerCase().includes("iphone")) type = "IPHONE";
    if (url.toLowerCase().includes("dyson") || url.toLowerCase().includes("airwrap")) type = "DYSON";

    // Simulate Network Latency
    await new Promise((resolve) => setTimeout(resolve, 2000));

    // Get Intelligence
    const intel = IntelligenceService.getMockIntelligence(type);

    return NextResponse.json(intel);
  } catch (error) {
    console.error("API Error:", error);
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
  }
}
