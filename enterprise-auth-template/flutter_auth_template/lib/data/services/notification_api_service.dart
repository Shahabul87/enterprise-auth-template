import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_template/core/config/app_config.dart';
import 'package:flutter_auth_template/data/models/notification_models.dart';

class NotificationApiService {
  final http.Client _client;
  final String _baseUrl;

  NotificationApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = AppConfig.apiBaseUrl;

  // Notification Management
  Future<List<NotificationMessage>> getNotifications({
    int page = 0,
    int limit = 20,
    bool unreadOnly = false,
    NotificationType? type,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (unreadOnly) 'unread_only': 'true',
        if (type != null) 'type': type.name,
      };

      final uri = Uri.parse('$_baseUrl/notifications')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => NotificationMessage.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get notifications failed: $e');
    }
  }

  Future<NotificationMessage> createNotification(
    CreateNotificationRequest request,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationMessage.fromJson(data['data']);
      } else {
        throw Exception('Failed to create notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create notification failed: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Mark as read failed: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Mark all as read failed: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete notification failed: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Clear notifications failed: $e');
    }
  }

  // Template Management
  Future<List<NotificationTemplate>> getTemplates() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/notifications/templates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => NotificationTemplate.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get templates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get templates failed: $e');
    }
  }

  Future<NotificationTemplate> createTemplate(
    NotificationTemplate template,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications/templates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(template.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationTemplate.fromJson(data['data']);
      } else {
        throw Exception('Failed to create template: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create template failed: $e');
    }
  }

  Future<NotificationTemplate> updateTemplate(
    String templateId,
    NotificationTemplate template,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/notifications/templates/$templateId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(template.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationTemplate.fromJson(data['data']);
      } else {
        throw Exception('Failed to update template: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update template failed: $e');
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/notifications/templates/$templateId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete template: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete template failed: $e');
    }
  }

  // Preferences Management
  Future<NotificationPreferences> getPreferences() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/notifications/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationPreferences.fromJson(data['data']);
      } else {
        throw Exception('Failed to get preferences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get preferences failed: $e');
    }
  }

  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/notifications/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(preferences.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationPreferences.fromJson(data['data']);
      } else {
        throw Exception('Failed to update preferences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Update preferences failed: $e');
    }
  }

  // Batch Management
  Future<List<NotificationBatch>> getBatches() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/notifications/batches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => NotificationBatch.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get batches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get batches failed: $e');
    }
  }

  Future<NotificationBatch> createBatch({
    required String title,
    required List<String> recipients,
    required String templateId,
    required Map<String, dynamic> variables,
    DateTime? scheduledAt,
  }) async {
    try {
      final requestBody = {
        'title': title,
        'recipients': recipients,
        'template_id': templateId,
        'variables': variables,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications/batches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationBatch.fromJson(data['data']);
      } else {
        throw Exception('Failed to create batch: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create batch failed: $e');
    }
  }

  Future<void> cancelBatch(String batchId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications/batches/$batchId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel batch: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Cancel batch failed: $e');
    }
  }

  // Subscription Management
  Future<List<NotificationSubscription>> getSubscriptions() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/notifications/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => NotificationSubscription.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get subscriptions failed: $e');
    }
  }

  Future<NotificationSubscription> createSubscription({
    required NotificationChannel channel,
    required String endpoint,
    Map<String, dynamic>? credentials,
  }) async {
    try {
      final requestBody = {
        'channel': channel.name,
        'endpoint': endpoint,
        if (credentials != null) 'credentials': credentials,
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationSubscription.fromJson(data['data']);
      } else {
        throw Exception('Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create subscription failed: $e');
    }
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/notifications/subscriptions/$subscriptionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete subscription failed: $e');
    }
  }

  // Analytics
  Future<NotificationAnalytics> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/notifications/analytics')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationAnalytics.fromJson(data['data']);
      } else {
        throw Exception('Failed to get analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get analytics failed: $e');
    }
  }

  Future<void> trackNotificationAction({
    required String notificationId,
    required String actionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {
        'notification_id': notificationId,
        'action_id': actionId,
        'timestamp': DateTime.now().toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

      await _client.post(
        Uri.parse('$_baseUrl/notifications/analytics/actions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      );
    } catch (e) {
      // Don't throw for analytics tracking failures
      print('Failed to track notification action: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/notifications/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get unread count failed: $e');
    }
  }

  // Test notification
  Future<void> sendTestNotification({
    required String title,
    required String content,
    NotificationType type = NotificationType.info,
    List<NotificationChannel>? channels,
  }) async {
    try {
      final requestBody = {
        'title': title,
        'content': content,
        'type': type.name,
        if (channels != null) 'channels': channels.map((c) => c.name).toList(),
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl/notifications/test'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send test notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Send test notification failed: $e');
    }
  }

  Future<String> _getAuthToken() async {
    // Implementation depends on your auth system
    // This is a placeholder - replace with actual token retrieval
    return 'your-auth-token';
  }

  void dispose() {
    _client.close();
  }
}