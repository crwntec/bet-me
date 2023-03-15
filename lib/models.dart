import 'dart:convert';

import 'package:flutter/cupertino.dart';
class Bet {
  final String title;
  final String timestamp;

  Bet({
    required this.title,
    required this.timestamp
  });

  factory Bet.fromJson(Map<String, dynamic> jsonData) {
    return Bet(
      title: jsonData['title'],
      timestamp: jsonData['timestamp']
    );
  }
  static Map<String, dynamic> toMap(Bet bet) => {
    'title': bet.title,
    'timestamp': bet.timestamp
  };
  static String encode(List<Bet> bets) => json.encode(
    bets
      .map<Map<String, dynamic>>((bet) => Bet.toMap(bet))
      .toList()
  );
  static List<Bet> decode(String bets) => (json.decode(bets) as List<dynamic>).map<Bet>((item) => Bet.fromJson(item)).toList();
}