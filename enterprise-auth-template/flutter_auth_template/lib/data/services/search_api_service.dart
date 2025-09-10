import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../models/search_models.dart';

class SearchApiService {
  final http.Client _client;
  final String _baseUrl;

  SearchApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = AppConfig.apiBaseUrl;

  Future&lt;SearchResult&gt; search(SearchQuery query) async {
    try {
      final queryParams = {
        &apos;q&apos;: query.query,
        &apos;page&apos;: query.page.toString(),
        &apos;limit&apos;: query.limit.toString(),
        if (query.filters.isNotEmpty) &apos;filters&apos;: query.filters.join(&apos;,&apos;),
        if (query.metadata != null) 
          ...query.metadata!.map((k, v) =&gt; MapEntry(k, v.toString())),
      };

      final uri = Uri.parse(&apos;$_baseUrl${query.type.endpoint}&apos;)
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
        return SearchResult.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to search: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Search failed: $e&apos;);
    }
  }

  Future&lt;List&lt;SearchSuggestion&gt;&gt; getSuggestions(
    String query, 
    SearchType type,
  ) async {
    try {
      final uri = Uri.parse(&apos;$_baseUrl${type.endpoint}/suggestions&apos;)
          .replace(queryParameters: {&apos;q&apos;: query});

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
            .map((item) =&gt; SearchSuggestion.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get suggestions: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get suggestions failed: $e&apos;);
    }
  }

  Future&lt;List&lt;SearchFacet&gt;&gt; getFacets(
    SearchQuery query,
  ) async {
    try {
      final uri = Uri.parse(&apos;$_baseUrl${query.type.endpoint}/facets&apos;)
          .replace(queryParameters: {
            &apos;q&apos;: query.query,
            if (query.filters.isNotEmpty) &apos;filters&apos;: query.filters.join(&apos;,&apos;),
          });

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
            .map((item) =&gt; SearchFacet.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get facets: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get facets failed: $e&apos;);
    }
  }

  Future&lt;List&lt;SavedSearch&gt;&gt; getSavedSearches() async {
    try {
      final response = await _client.get(
        Uri.parse(&apos;$_baseUrl/search/saved&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[&apos;data&apos;] as List)
            .map((item) =&gt; SavedSearch.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get saved searches: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get saved searches failed: $e&apos;);
    }
  }

  Future&lt;SavedSearch&gt; saveSearch({
    required String name,
    required String query,
    required List&lt;String&gt; filters,
    required SearchType type,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final requestBody = {
        &apos;name&apos;: name,
        &apos;query&apos;: query,
        &apos;filters&apos;: filters,
        &apos;type&apos;: type.name,
        &apos;description&apos;: description,
        &apos;is_public&apos;: isPublic,
      };

      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/search/saved&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return SavedSearch.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to save search: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Save search failed: $e&apos;);
    }
  }

  Future&lt;void&gt; deleteSavedSearch(String searchId) async {
    try {
      final response = await _client.delete(
        Uri.parse(&apos;$_baseUrl/search/saved/$searchId&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to delete saved search: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Delete saved search failed: $e&apos;);
    }
  }

  Future&lt;List&lt;SearchIndex&gt;&gt; getSearchIndices() async {
    try {
      final response = await _client.get(
        Uri.parse(&apos;$_baseUrl/search/indices&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[&apos;data&apos;] as List)
            .map((item) =&gt; SearchIndex.fromJson(item))
            .toList();
      } else {
        throw Exception(&apos;Failed to get search indices: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get search indices failed: $e&apos;);
    }
  }

  Future&lt;void&gt; rebuildIndex(String indexId) async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/search/indices/$indexId/rebuild&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to rebuild index: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Rebuild index failed: $e&apos;);
    }
  }

  Future&lt;void&gt; pauseIndex(String indexId) async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/search/indices/$indexId/pause&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to pause index: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Pause index failed: $e&apos;);
    }
  }

  Future&lt;void&gt; resumeIndex(String indexId) async {
    try {
      final response = await _client.post(
        Uri.parse(&apos;$_baseUrl/search/indices/$indexId/resume&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to resume index: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Resume index failed: $e&apos;);
    }
  }

  Future&lt;SearchAnalytics&gt; getSearchAnalytics({
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

      final uri = Uri.parse(&apos;$_baseUrl/search/analytics&apos;)
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
        return SearchAnalytics.fromJson(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to get search analytics: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get search analytics failed: $e&apos;);
    }
  }

  Future&lt;void&gt; trackSearchClick({
    required String query,
    required String itemId,
    required SearchItemType itemType,
    required int position,
  }) async {
    try {
      final requestBody = {
        &apos;query&apos;: query,
        &apos;item_id&apos;: itemId,
        &apos;item_type&apos;: itemType.name,
        &apos;position&apos;: position,
        &apos;timestamp&apos;: DateTime.now().toIso8601String(),
      };

      await _client.post(
        Uri.parse(&apos;$_baseUrl/search/analytics/clicks&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
        body: json.encode(requestBody),
      );
    } catch (e) {
      // Don&apos;t throw for analytics tracking failures
      print(&apos;Failed to track search click: $e&apos;);
    }
  }

  Future&lt;List&lt;String&gt;&gt; getRecentSearches({int limit = 10}) async {
    try {
      final uri = Uri.parse(&apos;$_baseUrl/search/recent&apos;)
          .replace(queryParameters: {&apos;limit&apos;: limit.toString()});

      final response = await _client.get(
        uri,
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List&lt;String&gt;.from(data[&apos;data&apos;]);
      } else {
        throw Exception(&apos;Failed to get recent searches: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Get recent searches failed: $e&apos;);
    }
  }

  Future&lt;void&gt; clearSearchHistory() async {
    try {
      final response = await _client.delete(
        Uri.parse(&apos;$_baseUrl/search/recent&apos;),
        headers: {
          &apos;Content-Type&apos;: &apos;application/json&apos;,
          &apos;Authorization&apos;: &apos;Bearer ${await _getAuthToken()}&apos;,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(&apos;Failed to clear search history: ${response.statusCode}&apos;);
      }
    } catch (e) {
      throw Exception(&apos;Clear search history failed: $e&apos;);
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