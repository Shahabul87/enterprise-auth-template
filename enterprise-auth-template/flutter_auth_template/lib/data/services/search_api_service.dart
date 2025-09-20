import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_template/core/config/app_config.dart';
import 'package:flutter_auth_template/data/models/search_models.dart';

class SearchApiService {
  final http.Client _client;
  final String _baseUrl;

  SearchApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = AppConfig.apiBaseUrl;

  Future<SearchResult> search(SearchQuery query) async {
    try {
      final queryParams = {
        'q': query.query,
        'page': query.page.toString(),
        'limit': query.limit.toString(),
        if (query.filters.isNotEmpty) 'filters': query.filters.join(','),
        if (query.metadata != null) 
          ...query.metadata!.map((k, v) => MapEntry(k, v.toString())),
      };

      final uri = Uri.parse('$_baseUrl${query.type.endpoint}')
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
        return SearchResult.fromJson(data['data']);
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<List<SearchSuggestion>> getSuggestions(
    String query, 
    SearchType type,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl${type.endpoint}/suggestions')
          .replace(queryParameters: {'q': query});

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
            .map((item) => SearchSuggestion.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get suggestions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get suggestions failed: $e');
    }
  }

  Future<List<SearchFacet>> getFacets(
    SearchQuery query,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl${query.type.endpoint}/facets')
          .replace(queryParameters: {
            'q': query.query,
            if (query.filters.isNotEmpty) 'filters': query.filters.join(','),
          });

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
            .map((item) => SearchFacet.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get facets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get facets failed: $e');
    }
  }

  Future<List<SavedSearch>> getSavedSearches() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/search/saved'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => SavedSearch.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get saved searches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get saved searches failed: $e');
    }
  }

  Future<SavedSearch> saveSearch({
    required String name,
    required String query,
    required List<String> filters,
    required SearchType type,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'query': query,
        'filters': filters,
        'type': type.name,
        'description': description,
        'is_public': isPublic,
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl/search/saved'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return SavedSearch.fromJson(data['data']);
      } else {
        throw Exception('Failed to save search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Save search failed: $e');
    }
  }

  Future<void> deleteSavedSearch(String searchId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/search/saved/$searchId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete saved search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete saved search failed: $e');
    }
  }

  Future<List<SearchIndex>> getSearchIndices() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/search/indices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((item) => SearchIndex.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get search indices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get search indices failed: $e');
    }
  }

  Future<void> rebuildIndex(String indexId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/search/indices/$indexId/rebuild'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to rebuild index: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Rebuild index failed: $e');
    }
  }

  Future<void> pauseIndex(String indexId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/search/indices/$indexId/pause'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to pause index: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Pause index failed: $e');
    }
  }

  Future<void> resumeIndex(String indexId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/search/indices/$indexId/resume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to resume index: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Resume index failed: $e');
    }
  }

  Future<SearchAnalytics> getSearchAnalytics({
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

      final uri = Uri.parse('$_baseUrl/search/analytics')
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
        return SearchAnalytics.fromJson(data['data']);
      } else {
        throw Exception('Failed to get search analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get search analytics failed: $e');
    }
  }

  Future<void> trackSearchClick({
    required String query,
    required String itemId,
    required SearchItemType itemType,
    required int position,
  }) async {
    try {
      final requestBody = {
        'query': query,
        'item_id': itemId,
        'item_type': itemType.name,
        'position': position,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _client.post(
        Uri.parse('$_baseUrl/search/analytics/clicks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(requestBody),
      );
    } catch (e) {
      // Don't throw for analytics tracking failures
      print('Failed to track search click: $e');
    }
  }

  Future<List<String>> getRecentSearches({int limit = 10}) async {
    try {
      final uri = Uri.parse('$_baseUrl/search/recent')
          .replace(queryParameters: {'limit': limit.toString()});

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data']);
      } else {
        throw Exception('Failed to get recent searches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get recent searches failed: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/search/recent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear search history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Clear search history failed: $e');
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