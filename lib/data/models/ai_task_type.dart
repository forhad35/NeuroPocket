import 'package:flutter/material.dart';

enum AiTaskType {
  grammarCheck(
    id: 'grammar_check',
    title: 'Grammar Check',
    banglaTitle: 'গ্রামার চেক',
    subtitle: 'Fix typos & grammar errors',
    banglaSubtitle: 'বানান ও ব্যাকরণ সংশোধন',
    description: 'Fix grammatical errors, typos, and punctuation issues with explanations.',
    banglaDescription: 'ইংরেজি ও বাংলা বাক্যের ব্যাকরণ, বানান ও যতিচিহ্ন ঠিক করে।',
    icon: Icons.spellcheck_rounded,
    badgeColor: Color(0xFF6366F1),
  ),
  naturalPhrasing(
    id: 'natural_phrasing',
    title: 'Natural Phrasing',
    banglaTitle: 'ন্যাচারাল ফ্রেজিং',
    subtitle: 'Smooth & fluent sentences',
    banglaSubtitle: 'সাবলীল ও স্বাভাবিক বাক্য',
    description: 'Make sentences sound natural, smooth, and professionally formatted.',
    banglaDescription: 'অস্বাভাবিক বা ভাঙা বাক্যকে প্রফেশনাল ও সাবলীল বানায়।',
    icon: Icons.auto_awesome_rounded,
    badgeColor: Color(0xFF06B6D4),
  ),
  sentenceAlternatives(
    id: 'sentence_alternatives',
    title: 'Better Alternatives',
    banglaTitle: 'বিকল্প বাক্য',
    subtitle: '3 versatile tone options',
    banglaSubtitle: '৩টি ভিন্ন টোনের সাজেশন',
    description: 'Get 3 superior alternative sentences with different tones (Casual, Formal, Concise).',
    banglaDescription: 'ফরমাল, ক্যাজুয়াল ও সংক্ষিপ্ত ৩টি ভিন্ন ধরণের বিকল্প তৈরি করে।',
    icon: Icons.alt_route_rounded,
    badgeColor: Color(0xFF10B981),
  ),
  paragraphProofread(
    id: 'paragraph_proofread',
    title: 'Paragraph Proofread',
    banglaTitle: 'প্যারাগ্রাফ প্রুফরিড',
    subtitle: 'Structure & cohesion polish',
    banglaSubtitle: 'গঠন ও লেখার মান উন্নয়ন',
    description: 'Complete paragraph proofreading, improving structure, flow, and clarity.',
    banglaDescription: 'সম্পূর্ণ প্যারাগ্রাফের অর্থ ঠিক রেখে কোহিশন ও ফ্লো বাড়ায়।',
    icon: Icons.article_rounded,
    badgeColor: Color(0xFFF59E0B),
  ),
  ocrStructuring(
    id: 'ocr_structuring',
    title: 'OCR Clean & Structure',
    banglaTitle: 'ওসিআর টেক্সট ক্লিন',
    subtitle: 'Merge broken lines & format',
    banglaSubtitle: 'ভাঙা লাইন ঠিক ও স্ট্রাকচার',
    description: 'Merge broken OCR lines, fix split words, remove artifacts, and structure paragraphs & lists.',
    banglaDescription: 'ভাঙা লাইন জোড়া লাগিয়ে ও নয়েজ দূর করে ক্লিন ডকুমেন্ট বানায়।',
    icon: Icons.auto_fix_normal_rounded,
    badgeColor: Color(0xFF8B5CF6),
  ),
  multilingualRewrite(
    id: 'multilingual_rewrite',
    title: 'Polite & Pro Rewrite',
    banglaTitle: 'পেশাদার রি-রাইট',
    subtitle: 'Business & courteous tone',
    banglaSubtitle: 'ভদ্র ও বিজনেস রূপান্তর',
    description: 'Translate & elevate text into polished, courteous, and business-ready English or Bengali.',
    banglaDescription: 'রুচিশীল ও পেশাদার কর্পোরেট বা বিনয়ী ভাষায় রূপান্তর করে।',
    icon: Icons.translate_rounded,
    badgeColor: Color(0xFFEC4899),
  );

  final String id;
  final String title;
  final String banglaTitle;
  final String subtitle;
  final String banglaSubtitle;
  final String description;
  final String banglaDescription;
  final IconData icon;
  final Color badgeColor;

  const AiTaskType({
    required this.id,
    required this.title,
    required this.banglaTitle,
    required this.subtitle,
    required this.banglaSubtitle,
    required this.description,
    required this.banglaDescription,
    required this.icon,
    required this.badgeColor,
  });

  String localizedTitle(bool isBangla) => isBangla ? banglaTitle : title;
  String localizedSubtitle(bool isBangla) => isBangla ? banglaSubtitle : subtitle;
  String localizedDescription(bool isBangla) => isBangla ? banglaDescription : description;
}
