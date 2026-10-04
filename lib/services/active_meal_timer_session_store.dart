import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/active_meal_timer_session.dart';

class ActiveMealTimerSessionStore {
  const ActiveMealTimerSessionStore();

  static const _sessionKey = 'activeMealTimerSession';

  static final _operationQueues = Expando<Future<dynamic>>();

  Future<T> _withPreferences<T>(
    Future<T> Function(SharedPreferences) operation,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final previous = _operationQueues[preferences];
    late final Future<T> result;
    Future<T> perform() async {
      try {
        return await operation(preferences);
      } finally {
        if (identical(_operationQueues[preferences], result)) {
          _operationQueues[preferences] = null;
        }
      }
    }

    result = (previous ?? Future<void>.value()).then(
      (_) => perform(),
      onError: (Object _, StackTrace __) => perform(),
    );
    _operationQueues[preferences] = result;
    return result;
  }

  Future<void> save(ActiveMealTimerSession session) async {
    await _withPreferences((preferences) async {
      if (!await preferences.setString(
        _sessionKey,
        jsonEncode(session.toJson()),
      )) {
        throw StateError('Unable to save active meal session.');
      }
    });
  }

  Future<ActiveMealTimerSession?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawSession = preferences.getString(_sessionKey);
    if (rawSession == null || rawSession.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(rawSession);
      if (decoded is! Map) return null;
      return ActiveMealTimerSession.fromJson(
        Map<String, Object?>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _withPreferences((preferences) async {
      if (!await preferences.remove(_sessionKey)) {
        throw StateError('Unable to clear active meal session.');
      }
    });
  }
}
