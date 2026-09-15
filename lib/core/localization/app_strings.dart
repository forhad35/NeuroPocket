import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/language/language_bloc.dart';
import 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  static AppStrings of(BuildContext context) {
    try {
      final state = context.watch<LanguageBloc>().state;
      return AppStrings(state.language);
    } catch (_) {
      return const AppStrings(AppLanguage.bangla);
    }
  }

  bool get isBangla => language == AppLanguage.bangla;

  // App General
  String get appTitle => isBangla ? 'অফলাইন এআই রাইটিং ও চ্যাট' : 'Offline AI Writing & Chat';
  String get onDeviceBadge => isBangla ? '১০০% অন-ডিভাইস' : '100% On-Device';
  String get offlineMode => isBangla ? 'অফলাইন মোড' : 'Offline Mode';
  String get languageTitle => isBangla ? 'অ্যাপের ভাষা' : 'App Language';
  String get switchLanguage => isBangla ? 'English এ পরিবর্তন করুন' : 'Switch to বাংলা';

  // Navigation
  String get navEditor => isBangla ? 'এআই রাইটার' : 'AI Writer';
  String get navChat => isBangla ? 'অফলাইন চ্যাট' : 'Offline Chat';
  String get navOcr => isBangla ? 'ওসিআর স্ক্যানার' : 'OCR Scanner';
  String get navSettings => isBangla ? 'মডেল ও সেটিংস' : 'Models & Settings';

  // AI Editor
  String get editorTitle => isBangla ? 'স্মার্ট এআই রাইটিং অ্যাসিস্ট্যান্ট' : 'Smart AI Writing Assistant';
  String get editorSubtitle => isBangla
      ? 'অফলাইনে ব্যাকরণ ঠিক করুন, বাক্য সুন্দর করুন ও অনুবাদ করুন'
      : 'Proofread grammar, refine tone & translate completely offline';
  String get inputPlaceholder => isBangla
      ? 'এখানে আপনার বাক্য বা প্যারাগ্রাফ লিখুন বা পেস্ট করুন...'
      : 'Type or paste your sentence or paragraph here...';
  String get buttonAnalyze => isBangla ? 'প্রসেস ও জেনারেট করুন' : 'Analyze & Generate';
  String get processingAi => isBangla ? 'অন-ডিভাইস এআই প্রসেসিং হচ্ছে...' : 'Processing with on-device AI...';
  String get resultTitle => isBangla ? 'এআই ফলাফল ও সংশোধন' : 'AI Results & Improvements';
  String get originalText => isBangla ? 'মূল টেক্সট' : 'Original Text';
  String get correctedText => isBangla ? 'সংশোধিত টেক্সট' : 'Corrected Text';
  String get explanation => isBangla ? 'ব্যাখ্যা ও কারণ' : 'Explanation';
  String get alternatives => isBangla ? 'বিকল্প বাক্যসমূহ' : 'Alternative Versions';
  String get copy => isBangla ? 'কপি করুন' : 'Copy';
  String get copied => isBangla ? 'ক্লিপবোর্ডে কপি করা হয়েছে!' : 'Copied to clipboard!';
  String get clear => isBangla ? 'মুছুন' : 'Clear';
  String get selectTask => isBangla ? 'কাজের ধরণ নির্বাচন করুন:' : 'Select Task Type:';

  // Task Type Names
  String get taskGrammarCheck => isBangla ? 'ব্যাকরণ সংশোধন' : 'Grammar Fix';
  String get taskNaturalPhrasing => isBangla ? 'স্বাভাবিক ভাব' : 'Natural Tone';
  String get taskAlternatives => isBangla ? '৩টি বিকল্প বাক্য' : '3 Alternatives';
  String get taskParagraphProofread => isBangla ? 'প্যারাগ্রাফ প্রুফরিড' : 'Proofreading';
  String get taskOcrStructuring => isBangla ? 'ডকুমেন্ট ফরম্যাট' : 'Doc Structure';
  String get taskMultilingualRewrite => isBangla ? 'ভদ্র ও বিজনেস টোন' : 'Polite / Business';

  // Task Descriptions
  String get taskGrammarDesc => isBangla
      ? 'ইংরেজি ও বাংলা বাক্যের ব্যাকরণ, বানান ও যতিচিহ্ন ঠিক করে।'
      : 'Fixes grammar, spelling, tense, and punctuation errors.';
  String get taskNaturalDesc => isBangla
      ? 'অস্বাভাবিক বা ভাঙা বাক্যকে প্রফেশনাল ও সাবলীল বানায়।'
      : 'Transforms awkward sentences into smooth, natural phrasing.';
  String get taskAlternativesDesc => isBangla
      ? 'ফরমাল, ক্যাজুয়াল ও সংক্ষিপ্ত ৩টি ভিন্ন ধরণের বিকল্প তৈরি করে।'
      : 'Generates Formal, Casual, and Concise alternative phrasing.';
  String get taskParagraphDesc => isBangla
      ? 'সম্পূর্ণ প্যারাগ্রাফের অর্থ ঠিক রেখে কোহিশন ও ফ্লো বাড়ায়।'
      : 'Enhances flow, cohesion, and transitions of entire paragraphs.';
  String get taskOcrDesc => isBangla
      ? 'ভাঙা লাইন জোড়া লাগিয়ে ও নয়েজ দূর করে ক্লিন ডকুমেন্ট বানায়।'
      : 'Repairs split words, broken lines, and formats scanned text.';
  String get taskMultilingualDesc => isBangla
      ? 'রুচিশীল ও পেশাদার কর্পোরেট বা বিনয়ী ভাষায় রূপান্তর করে।'
      : 'Rewrites text into courteous, polished, and professional tone.';

  // Chat View
  String get chatTitle => isBangla ? 'অফলাইন এআই চ্যাট' : 'Offline AI Chat';
  String get chatPlaceholder => isBangla ? 'এআই-কে প্রশ্ন করুন বা কিছু লিখুন...' : 'Ask AI or type a sentence...';
  String get chatGreeting => isBangla
      ? 'আমি আপনার স্মার্ট অন-ডিভাইস এআই সহকারী (Offline AI Assistant)।\n\nআপনি আমাকে যেকোনো প্রশ্ন করতে পারেন, কোনো টেক্সট কারেক্ট বা রিরাইট করতে বলতে পারেন, অথবা বাংলা ও ইংরেজিতে যেকোনো বিষয়ে সম্পূর্ণ অফলাইনে কথোপকথন করতে পারেন!'
      : 'I am your smart offline on-device AI assistant.\n\nYou can ask me questions, request grammar corrections, translate text, or have a fluent conversation in English and Bengali completely offline!';
  String get quickPrompt1 => isBangla
      ? 'ম্যানেজারকে ছুটির জন্য একটি ভদ্র ইমেইল লিখে দাও'
      : 'Write a polite leave email to my manager';
  String get quickPrompt2 => isBangla
      ? 'কীভাবে আমার ইংরেজি লেখাকে আরও সাবলীল করব?'
      : 'How can I make my English writing natural?';
  String get quickPrompt3 => isBangla
      ? 'আমি ভালো আছি এটা ইংরেজিতে অনুবাদ করো'
      : 'Translate "ami valo achi" to English';
  String get clearChat => isBangla ? 'চ্যাট ক্লিয়ার করুন' : 'Clear Chat';

  // OCR View
  String get ocrTitle => isBangla ? 'ওসিআর ডকুমেন্ট স্ক্যানার' : 'OCR Document Scanner';
  String get ocrSubtitle => isBangla
      ? 'ছবি থেকে টেক্সট এক্সট্রাক্ট করে অফলাইনে এআই দিয়ে ফরম্যাট করুন'
      : 'Extract text from images and format with offline AI';
  String get scanCamera => isBangla ? 'ক্যামেরা স্ক্যান' : 'Camera Scan';
  String get pickGallery => isBangla ? 'গ্যালারি থেকে ছবি' : 'Gallery Image';
  String get recognizedText => isBangla ? 'শনাক্তকৃত টেক্সট' : 'Recognized Text';
  String get noTextFound => isBangla
      ? 'কোনো ছবি নির্বাচন করা হয়নি। ক্যামেরা বা গ্যালারি থেকে ছবি নিন।'
      : 'No image selected. Capture from camera or pick from gallery.';
  String get sendToEditor => isBangla ? 'এআই এডিটরে পাঠান' : 'Send to AI Editor';

  // Model Manager & Settings
  String get modelsTitle => isBangla ? 'অন-ডিভাইস লোকাল GGUF মডেলসমূহ' : 'On-Device Local GGUF Models';
  String get geminiTitle => isBangla ? 'গুগল জেমিনি ক্লাউড এআই (ঐচ্ছিক)' : 'Google Gemini Cloud AI (Optional)';
  String get geminiDesc => isBangla
      ? 'ক্লাউড সুপার-ইন্টেলিজেন্স ব্যবহারের জন্য আপনার ফ্রি জেমিনি এপিআই কি দিন।'
      : 'Add your free Gemini API key to use cloud super-intelligence alongside offline models.';
  String get geminiKeyLabel => isBangla ? 'জেমিনি এপিআই কী (API Key)' : 'Gemini API Key';
  String get saveKey => isBangla ? 'কী সংরক্ষণ করুন' : 'Save Key';
  String get testInferenceTitle => isBangla ? 'অন-ডিভাইস লাইভ টেস্ট' : 'Live On-Device GGUF Test';
  String get activeModelLabel => isBangla ? 'বর্তমান সক্রিয় মডেল:' : 'Active Model:';
  String get testPromptLabel => isBangla ? 'টেস্ট প্রম্পট' : 'Test Prompt';
  String get runTest => isBangla ? 'অফলাইন টেস্ট চালান' : 'Run Offline Test';
  String get bestForTitle => isBangla ? 'কোন কাজের জন্য সেরা:' : 'Best For:';
  String get download => isBangla ? 'ডাউনলোড' : 'Download';
  String get downloading => isBangla ? 'ডাউনলোড হচ্ছে...' : 'Downloading...';
  String get cancel => isBangla ? 'বাতিল' : 'Cancel';
  String get setActive => isBangla ? 'সক্রিয় করুন' : 'Set as Active';
  String get active => isBangla ? 'সক্রিয় (ACTIVE)' : 'ACTIVE';
  String get delete => isBangla ? 'মুছে ফেলুন' : 'Delete';
  String get deleteConfirm => isBangla
      ? 'আপনি কি নিশ্চিত যে এই মডেলটি ডিভাইস থেকে মুছে ফেলতে চান?'
      : 'Are you sure you want to delete this model from disk?';
}

