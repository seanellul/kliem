import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  print('🗑️ Clearing Word-Dex data...');
  
  final prefs = await SharedPreferences.getInstance();
  
  // Clear Word-Dex data
  await prefs.remove('kelma-worddex');
  
  print('✅ Word-Dex data cleared!');
  print('📱 Next time you catch a word, it will have the correct translation.');
} 