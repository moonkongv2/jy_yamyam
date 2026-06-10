import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/active_meal_timer_session.dart';

class ActiveMealTimerSessionStore {
  const ActiveMealTimerSessionStore();

  static const _sessionKey = 'activeMealTimerSession';

  Future<void> save(ActiveMealTimerSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<ActiveMealTimerSession?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawSession = preferences.getString(_sessionKey);
    if (rawSession == null || rawSession.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawSession);
      if (decoded is! Map) {
        return null;
      }

      return ActiveMealTimerSession.fromJson(
        Map<String, Object?>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }
}
