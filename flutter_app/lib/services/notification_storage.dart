import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_manager_flutter/models/notification.dart';

class NotificationStorage {
  static const String _key = 'notifications';

  /// Salva uma notificação
  Future<void> save(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getAll();
    
    // Adiciona no início (mais recente primeiro)
    notifications.insert(0, notification);
    
    // Limita a 100 notificações mais recentes
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }
    
    final jsonList = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Retorna todas as notificações (mais recentes primeiro)
  Future<List<AppNotification>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    
    try {
      final jsonList = jsonDecode(jsonStr) as List<dynamic>;
      return jsonList
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      return [];
    }
  }

  /// Marca uma notificação como lida
  Future<void> markAsRead(String id) async {
    final notifications = await getAll();
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(read: true);
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    }
  }

  /// Marca todas como lidas
  Future<void> markAllAsRead() async {
    final notifications = await getAll();
    final updated = notifications.map((n) => n.copyWith(read: true)).toList();
    final prefs = await SharedPreferences.getInstance();
    final jsonList = updated.map((n) => n.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Remove uma notificação
  Future<void> delete(String id) async {
    final notifications = await getAll();
    notifications.removeWhere((n) => n.id == id);
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Remove todas as notificações
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Conta notificações não lidas
  Future<int> getUnreadCount() async {
    final notifications = await getAll();
    return notifications.where((n) => !n.read).length;
  }
}
