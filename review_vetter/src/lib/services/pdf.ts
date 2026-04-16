import { jsPDF } from "jspdf";
import { ProductIntelligence } from "./intelligence";

export class PDFService {
  /**
   * Generates a professional intelligence report PDF.
   */
  static generateReport(intel: ProductIntelligence) {
    const doc = new jsPDF({
      orientation: "portrait",
      unit: "mm",
      format: "a4",
    });

    const primaryColor = "#4f46e5"; // Indigo 600
    const secondaryColor = "#1e293b"; // Slate 800
    const accentColor = "#10b981"; // Emerald 500

    // ─── PAGE 1: HEADER & OVERVIEW ───
    
    // Background Header
    doc.setFillColor(secondaryColor);
    doc.rect(0, 0, 210, 40, "F");

    // Logo / Title
    doc.setTextColor("#ffffff");
    doc.setFontSize(24);
    doc.setFont("helvetica", "bold");
    doc.text("ReviewVetter", 20, 25);
    
    doc.setFontSize(10);
    doc.setFont("helvetica", "normal");
    doc.text("STRATEGIC PRODUCT AUDIT", 20, 32);

    doc.setTextColor("#ffffff");
    doc.setFontSize(8);
    doc.text(`DATE: ${new Date().toLocaleDateString()}`, 160, 25);
    doc.text(`REF: RV-${Math.random().toString(36).substring(7).toUpperCase()}`, 160, 30);

    // Product Name
    doc.setTextColor(secondaryColor);
    doc.setFontSize(18);
    doc.setFont("helvetica", "bold");
    doc.text(intel.productName, 20, 55);

    // Board Score Box
    doc.setFillColor("#f8fafc");
    doc.roundedRect(150, 45, 40, 25, 3, 3, "F");
    
    doc.setTextColor(secondaryColor);
    doc.setFontSize(8);
    doc.setFont("helvetica", "bold");
    doc.text("VETTER SCORE", 155, 52);
    
    doc.setFontSize(16);
    doc.setTextColor(primaryColor);
    doc.text(`${intel.score}/100`, 155, 62);

    // Intelligence Vectors
    doc.setTextColor(secondaryColor);
    doc.setFontSize(12);
    doc.setFont("helvetica", "bold");
    doc.text("INTELLIGENCE VECTORS", 20, 80);

    const vectors = [
      { label: "Product Reliability", value: intel.details.quality },
      { label: "Market Favorability", value: intel.details.value },
      { label: "Logistics Efficiency", value: intel.details.shipping },
      { label: "Resolution Speed", value: intel.details.support },
    ];

    let y = 90;
    vectors.forEach((v) => {
      doc.setFontSize(10);
      doc.setFont("helvetica", "bold");
      doc.setTextColor(secondaryColor);
      doc.text(v.label, 20, y);
      
      doc.setFontSize(9);
      doc.setTextColor(primaryColor);
      doc.text(`${v.value}%`, 180, y, { align: "right" });

      // Bar
      doc.setFillColor("#f1f5f9");
      doc.rect(20, y + 2, 160, 2, "F");
      doc.setFillColor(primaryColor);
      doc.rect(20, y + 2, (v.value / 100) * 160, 2, "F");

      y += 12;
    });

    // SWOT Summary
    y = 150;
    doc.setTextColor(secondaryColor);
    doc.setFontSize(12);
    doc.setFont("helvetica", "bold");
    doc.text("SWOT AUDIT SUMMARY", 20, y);

    const swotData = [
      { label: "STRENGTHS", items: intel.swot.strengths, color: accentColor },
      { label: "WEAKNESSES", items: intel.swot.weaknesses, color: "#ef4444" },
    ];

    y += 10;
    swotData.forEach((section) => {
      doc.setFillColor(section.color);
      doc.rect(20, y, 3, 3, "F");
      doc.setTextColor(secondaryColor);
      doc.setFontSize(10);
      doc.text(section.label, 25, y + 2.5);
      
      y += 8;
      section.items.forEach(item => {
        doc.setFontSize(9);
        doc.setFont("helvetica", "normal");
        doc.text(`• ${item}`, 25, y);
        y += 5;
      });
      y += 5;
    });

    // Strategy Roadmap
    y = 220;
    doc.setTextColor(secondaryColor);
    doc.setFontSize(12);
    doc.setFont("helvetica", "bold");
    doc.text("STRATEGIC EVOLUTION ROADMAP", 20, y);

    y += 10;
    intel.roadmap.slice(0, 3).forEach((step, i) => {
      doc.setFillColor("#f8fafc");
      doc.roundedRect(20, y, 170, 15, 2, 2, "F");
      
      doc.setTextColor(primaryColor);
      doc.setFontSize(10);
      doc.setFont("helvetica", "bold");
      doc.text(`0${i+1} ${step.title}`, 25, y + 6);
      
      doc.setTextColor("#64748b");
      doc.setFontSize(8);
      doc.setFont("helvetica", "normal");
      doc.text(step.description, 25, y + 11);
      
      y += 18;
    });

    // Footer
    doc.setFontSize(8);
    doc.setTextColor("#94a3b8");
    doc.text("CONFIDENTIAL | FOR INTERNAL STRATEGY USE ONLY", 105, 285, { align: "center" });
    doc.text("REVIEWVETTER AI AGENTS © 2026", 105, 290, { align: "center" });

    // Save
    doc.save(`${intel.productName.replace(/\s+/g, "_")}_ReviewVetter_Audit.pdf`);
  }
}
