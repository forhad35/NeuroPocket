import 'package:flutter/material.dart';

enum AiTaskType {
  grammarCheck(
    id: 'grammar_check',
    title: 'Grammar Check',
    banglaTitle: 'গ্রামার চেক ও কারেকশন',
    description: 'Fix grammatical errors, typos, and punctuation issues with explanations.',
    icon: Icons.spellcheck_rounded,
    badgeColor: Color(0xFF6366F1),
  ),
  naturalPhrasing(
    id: 'natural_phrasing',
    title: 'Natural Phrasing',
    banglaTitle: 'সেন্টেন্স ফরম্যাটিং ও টিউনিং',
    description: 'Make sentences sound natural, smooth, and professionally formatted.',
    icon: Icons.auto_awesome_rounded,
    badgeColor: Color(0xFF06B6D4),
  ),
  sentenceAlternatives(
    id: 'sentence_alternatives',
    title: 'Better Alternatives',
    banglaTitle: 'উন্নত বিকল্প বাক্য সাজেস্ট',
    description: 'Get 3 superior alternative sentences with different tones (Casual, Formal, Concise).',
    icon: Icons.alt_route_rounded,
    badgeColor: Color(0xFF10B981),
  ),
  paragraphProofread(
    id: 'paragraph_proofread',
    title: 'Paragraph Proofread',
    banglaTitle: 'প্যারাগ্রাফ প্রুফরিডিং',
    description: 'Complete paragraph proofreading, improving structure, flow, and clarity.',
    icon: Icons.article_rounded,
    badgeColor: Color(0xFFF59E0B),
  ),
  ocrStructuring(
    id: 'ocr_structuring',
    title: 'OCR Structure & Clean',
    banglaTitle: 'ওসিআর টেক্সট স্ট্রাকচার ও ক্লিন',
    description: 'Merge broken OCR lines, fix split words, remove artifacts, and structure paragraphs & lists.',
    icon: Icons.auto_fix_normal_rounded,
    badgeColor: Color(0xFF8B5CF6),
  ),
  multilingualRewrite(
    id: 'multilingual_rewrite',
    title: 'Polite & Pro Rewrite',
    banglaTitle: 'প্রফেশনাল ও পোলাইট রি-রাইট',
    description: 'Translate & elevate text into polished, courteous, and business-ready English or Bengali.',
    icon: Icons.translate_rounded,
    badgeColor: Color(0xFFEC4899),
  );

  final String id;
  final String title;
  final String banglaTitle;
  final String description;
  final IconData icon;
  final Color badgeColor;

  const AiTaskType({
    required this.id,
    required this.title,
    required this.banglaTitle,
    required this.description,
    required this.icon,
    required this.badgeColor,
  });
}

