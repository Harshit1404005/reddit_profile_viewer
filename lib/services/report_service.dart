import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/reddit_models.dart';

class ReportService {
  /// Entry point: Generates the full PDF byte stream for a profile.
  static Future<Uint8List> generateReport(RedditProfile profile) async {
    final pdf = pw.Document(
      title: 'RedIntel Profile Report: u/${profile.username}',
      author: 'RedIntel Analysis Engine',
    );

    // Load fonts for a professional look
    final font = await PdfGoogleFonts.robotoMedium();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final monoFont = await PdfGoogleFonts.robotoMonoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(profile, boldFont),
        footer: (context) => _buildFooter(context, monoFont),
        build: (context) => [
          _buildExecutiveSummary(profile, font, boldFont),
          pw.SizedBox(height: 24),
          _buildSignalsSection(profile, font, boldFont),
          pw.SizedBox(height: 24),
          _buildActivityTimeline(profile, font, boldFont),
          pw.SizedBox(height: 32),
          _buildSecurityDisclaimer(font),
        ],
      ),
    );

    return pdf.save();
  }

  /// Agency Branding and Case Metadata
  static pw.Widget _buildHeader(RedditProfile profile, pw.Font font) {
    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final refId = 'INSIGHT-${profile.username.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'REDINTEL INSIGHTS',
              style: pw.TextStyle(
                font: font,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800,
                letterSpacing: 1.5,
              ),
            ),
            pw.Text(
              'PROFESSIONAL ANALYSIS REPORT',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.red800),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SESSION REF: $refId', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('GENERATED: $date', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('SUBJECT: u/${profile.username}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('ENGINE: TRIDENT-V4', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  /// Core Statistics and Bio
  static pw.Widget _buildExecutiveSummary(RedditProfile profile, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('I. PROFILE OVERVIEW', style: pw.TextStyle(font: bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          headerAlignment: pw.Alignment.centerLeft,
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(font: bold, fontSize: 10, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
          cellStyle: pw.TextStyle(font: font, fontSize: 10),
          headers: ['Metric', 'Profile Discovery Data'],
          data: [
            ['Username Identity', 'u/${profile.username}'],
            ['Account lifespan', profile.accountAge],
            ['Total Karma Threshold', profile.totalKarma.toString()],
            ['Discovery Status', profile.status],
            ['Tone Assessment', '${(profile.toxicity * 100).toStringAsFixed(1)}% (Interaction Intensity)'],
            ['Safety Rating', profile.nsfw > 0.5 ? 'SENSITIVE CONTENT' : 'STANDARD'],
          ],
        ),
      ],
    );
  }

  /// Behavioral Signals List
  static pw.Widget _buildSignalsSection(RedditProfile profile, pw.Font font, pw.Font bold) {
    // Generate some mock signals based on the profile data for the report
    final signals = [
      if (profile.totalKarma > 10000) 'High Influence: Subject possesses significant community engagement records.',
      if (profile.nsfw > 0.5) 'Sensitive Discovery: History contains adult-oriented material.',
      if (profile.toxicity > 0.6) 'High Intensity Rhetoric: Analysis detects forceful interaction patterns.',
      if (profile.status == 'HIDDEN') 'Private profile: Subject has limited public visibility.',
      if (profile.accountAge.contains('Y') && int.parse(profile.accountAge.split('Y')[0]) > 5) 
         'Legacy Contributor: Deep historical footprint (5+ years).',
      'Advanced Retrieval: Data synthesized across 5 independent retrieval nodes.',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('II. BEHAVIORAL INSIGHT MARKERS', style: pw.TextStyle(font: bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        ...signals.map((s) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• ', style: pw.TextStyle(font: bold)),
              pw.Expanded(child: pw.Text(s, style: pw.TextStyle(font: font, fontSize: 10))),
            ],
          ),
        )),
      ],
    );
  }

  /// Activity Records Table
  static pw.Widget _buildActivityTimeline(RedditProfile profile, pw.Font font, pw.Font bold) {
    final activity = [
      ...profile.recentPosts.take(8).map((p) => [
        p.time,
        'POST',
        p.subreddit,
        p.title.length > 50 ? '${p.title.substring(0, 47)}...' : p.title,
        p.source,
      ]),
      ...profile.recentComments.take(8).map((c) => [
        c.time,
        'COMM',
        c.subreddit,
        c.body.length > 50 ? '${c.body.substring(0, 47)}...' : c.body,
        c.source,
      ]),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('III. ACTIVITY TIMELINE (LATEST RECORDS)', style: pw.TextStyle(font: bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          headerStyle: pw.TextStyle(font: bold, fontSize: 8, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
          cellStyle: pw.TextStyle(font: font, fontSize: 8),
          headers: ['Timestamp', 'Type', 'Subreddit', 'Insight Snippet', 'Retrieval Node'],
          data: activity,
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: const pw.FixedColumnWidth(60),
            1: const pw.FixedColumnWidth(40),
            2: const pw.FixedColumnWidth(80),
            3: const pw.FlexColumnWidth(),
            4: const pw.FixedColumnWidth(70),
          },
        ),
      ],
    );
  }

  /// Security and Legal Disclaimer
  static pw.Widget _buildSecurityDisclaimer(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.red800, width: 1),
        color: PdfColors.red50,
      ),
      child: pw.Text(
        'NOTICE: This analysis report was generated using public data nodes. '
        'Interpretation of results is algorithmic and intended for informational purposes. '
        'Professional discretion is advised in the use of these findings.',
        textAlign: pw.TextAlign.justify,
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.red900),
      ),
    );
  }

  /// Page numbering and global footer
  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount} | REDINTEL-INSIGHTS-PROFESSIONAL',
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
      ),
    );
  }
}
