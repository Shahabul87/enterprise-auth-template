import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../models/notification_models.dart';

class NotificationApiService {
  final http.Client _client;
  final String _baseUrl;

  NotificationApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = AppConfig.apiBaseUrl;

  // Notification Management
  Future&lt;List&lt;NotificationMessage&gt;&gt; getNotifications({
    int page = 0,
    int limit = 20,
    bool unreadOnly = false,
    NotificationType? type,
  }) async {
    try {
      final queryParams = &lt;String, String&gt;{
        &apos;page&apos;: page.toString(),
        &apos;limit&apos;: limit.toString(),
        if (unreadOnly) &apos;unread_only&apos;: &apos;true&apos;,
        if (type != null) &apos;type&apos;: type.name,
      };

      final uri = Uri.parse(&apos;$_baseUrl/notifications&apos;)
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[&apos;data&apos;] as List)
            .map((item) =&gt; NotificationMessage.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get notifications: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get notifications failed: $e&apos;);
    }
  }

  Future&lt;NotificationMessage&gt; createNotification(
    CreateNotificationRequest request,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationMessage.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to create notification: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Create notification failed: $e&apos;);
    }
  }

  Future&lt;void&gt; markAsRead(String notificationId) async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/$notificationId/read&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to mark as read: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Mark as read failed: $e&apos;);
    }
  }

  Future&lt;void&gt; markAllAsRead() async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/read-all&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to mark all as read: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Mark all as read failed: $e&apos;);
    }
  }

  Future&lt;void&gt; deleteNotification(String notificationId) async {
    try {
      final response = await _client.delete(
        Uri.parse(&apos;$_baseUrl/notifications/$notificationId&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to delete notification: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Delete notification failed: $e&apos;);
    }
  }

  Future&lt;void&gt; clearAllNotifications() async {
    try {
      final response = await _client.delete(
        Uri.parse(&apos;$_baseUrl/notifications&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to clear notifications: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Clear notifications failed: $e&apos;);
    }
  }

  // Template Management
  Future&lt;List&lt;NotificationTemplate&gt;&gt; getTemplates() async {
    try {
      final response = await _client.get(
        Uri.parse(&apos;$_baseUrl/notifications/templates&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[&apos;data&apos;] as List)
            .map((item) =&gt; NotificationTemplate.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get templates: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get templates failed: $e&apos;);
    }
  }

  Future&lt;NotificationTemplate&gt; createTemplate(
    NotificationTemplate template,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/templates&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(template.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationTemplate.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to create template: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Create template failed: $e&apos;);
    }
  }

  Future&lt;NotificationTemplate&gt; updateTemplate(
    String templateId,
    NotificationTemplate template,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse(&apos;$_baseUrl/notifications/templates/$templateId&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(template.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationTemplate.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to update template: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Update template failed: $e&apos;);
    }
  }

  Future&lt;void&gt; deleteTemplate(String templateId) async {
    try {
      final response = await _client.delete(
        Uri.parse(&apos;$_baseUrl/notifications/templates/$templateId&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to delete template: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Delete template failed: $e&apos;);
    }
  }

  // Preferences Management
  Future&lt;NotificationPreferences&gt; getPreferences() async {
    try {
      final response = await _client.get(
        Uri.parse(&apos;$_baseUrl/notifications/preferences&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationPreferences.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to get preferences: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get preferences failed: $e&apos;);
    }
  }

  Future&lt;NotificationPreferences&gt; updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse(&apos;$_baseUrl/notifications/preferences&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(preferences.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationPreferences.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to update preferences: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Update preferences failed: $e&apos;);
    }
  }

  // Batch Management
  Future&lt;List&lt;NotificationBatch&gt;&gt; getBatches() async {
    try {
      final response = await _client.get(
        Uri.parse(&apos;$_baseUrl/notifications/batches&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[&apos;data&apos;] as List)
            .map((item) =&gt; NotificationBatch.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get batches: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get batches failed: $e&apos;);
    }
  }

  Future&lt;NotificationBatch&gt; createBatch({
    required String title,
    required List&lt;String&gt; recipients,
    required String templateId,
    required Map&lt;String, dynamic&gt; variables,
    DateTime? scheduledAt,
  }) async {
    try {
      final requestBody = {
        &apos;title&apos;: title,
        &apos;recipients&apos;: recipients,
        &apos;template_id&apos;: templateId,
        &apos;variables&apos;: variables,
        if (scheduledAt != null) &apos;scheduled_at&apos;: scheduledAt.toIso8601String(),
      };

      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/batches&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationBatch.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to create batch: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Create batch failed: $e&apos;);
    }
  }

  Future&lt;void&gt; cancelBatch(String batchId) async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/batches/$batchId/cancel&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to cancel batch: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Cancel batch failed: $e&apos;);
    }
  }

  // Subscription Management
  Future&lt;List&lt;NotificationSubscription&gt;&gt; getSubscriptions() async {
    try {
      final response = await _client.get(
        Uri.parse(&apos;$_baseUrl/notifications/subscriptions&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[&apos;data&apos;] as List)
            .map((item) =&gt; NotificationSubscription.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get subscriptions: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get subscriptions failed: $e&apos;);
    }
  }

  Future&lt;NotificationSubscription&gt; createSubscription({
    required NotificationChannel channel,
    required String endpoint,
    Map&lt;String, dynamic&gt;? credentials,
  }) async {
    try {
      final requestBody = {
        &apos;channel&apos;: channel.name,
        &apos;endpoint&apos;: endpoint,
        if (credentials != null) &apos;credentials&apos;: credentials,
      };

      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/subscriptions&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return NotificationSubscription.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to create subscription: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Create subscription failed: $e&apos;);
    }
  }

  Future&lt;void&gt; deleteSubscription(String subscriptionId) async {
    try {
      final response = await _client.delete(
        Uri.parse(&apos;$_baseUrl/notifications/subscriptions/$subscriptionId&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to delete subscription: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Delete subscription failed: $e&apos;);
    }
  }

  // Analytics
  Future&lt;NotificationAnalytics&gt; getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = &lt;String, String&gt;{};
      if (startDate != null) {
        queryParams[&apos;start_date&apos;] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams[&apos;end_date&apos;] = endDate.toIso8601String();
      }

      final uri = Uri.parse(&apos;$_baseUrl/notifications/analytics&apos;)
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationAnalytics.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to get analytics: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get analytics failed: $e&apos;);
    }
  }

  Future&lt;void&gt; trackNotificationAction({
    required String notificationId,
    required String actionId,
    Map&lt;String, dynamic&gt;? metadata,
  }) async {
    try {
      final requestBody = {
        &apos;notification_id&apos;: notificationId,
        &apos;action_id&apos;: actionId,
        &apos;timestamp&apos;: DateTime.now().toIso8601String(),
        if (metadata != null) &apos;metadata&apos;: metadata,
      };

      await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/analytics/actions&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(requestBody),
      );
    } catch (e) {
      // Don&apos;t throw for analytics tracking failures
      print(&apos;Failed to track notification action: $e&apos;);
    }
  }

  Future&lt;int&gt; getUnreadCount() async {
    try {
      final response = await _client.get(
        Uri.parse(&apos;$_baseUrl/notifications/unread-count&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[&apos;count&apos;] ?? 0;
      } else {
        throw Exception(&apos;Failed to get unread count: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get unread count failed: $e&apos;);
    }
  }

  // Test notification
  Future&lt;void&gt; sendTestNotification({
    required String title,
    required String content,
    NotificationType type = NotificationType.info,
    List&lt;NotificationChannel&gt;? channels,
  }) async {
    try {
      final requestBody = {
        &apos;title&apos;: title,
        &apos;content&apos;: content,
        &apos;type&apos;: type.name,
        if (channels != null) &apos;channels&apos;: channels.map((c) =&gt; c.name).toList(),
      };

      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/notifications/test&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to send test notification: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Send test notification failed: $e&apos;);
    }
  }

  Future&lt;String&gt; _getAuthToken() async {
    // Implementation depends on your auth system
    // This is a placeholder - replace with actual token retrieval
    return &apos;your-auth-token&apos;;
  }

  void dispose() {
    _client.close();
  }
}