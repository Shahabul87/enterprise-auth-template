import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_models.freezed.dart';
part 'search_models.g.dart';

@freezed
class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    required String query,
    @Default([]) List<String> filters,
    @Default(SearchType.global) SearchType type,
    @Default(0) int page,
    @Default(20) int limit,
    Map<String, dynamic>? metadata,
  }) = _SearchQuery;

  factory SearchQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryFromJson(json);
}

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required List<SearchResultItem> items,
    required int totalCount,
    required int page,
    required int limit,
    required double processingTime,
    Map<String, List<SearchSuggestion>>? suggestions,
    List<SearchFacet>? facets,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}

@freezed
class SearchResultItem with _$SearchResultItem {
  const factory SearchResultItem({
    required String id,
    required String title,
    required String description,
    required SearchItemType type,
    required double score,
    required DateTime lastModified,
    Map<String, dynamic>? metadata,
    List<String>? highlights,
    String? thumbnailUrl,
  }) = _SearchResultItem;

  factory SearchResultItem.fromJson(Map<String, dynamic> json) =>
      _$SearchResultItemFromJson(json);
}

@freezed
class SearchSuggestion with _$SearchSuggestion {
  const factory SearchSuggestion({
    required String text,
    required double score,
    required int frequency,
    SearchSuggestionType? type,
  }) = _SearchSuggestion;

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestionFromJson(json);
}

@freezed
class SearchFacet with _$SearchFacet {
  const factory SearchFacet({
    required String name,
    required String displayName,
    required List<SearchFacetValue> values,
    SearchFacetType? type,
  }) = _SearchFacet;

  factory SearchFacet.fromJson(Map<String, dynamic> json) =>
      _$SearchFacetFromJson(json);
}

@freezed
class SearchFacetValue with _$SearchFacetValue {
  const factory SearchFacetValue({
    required String value,
    required String displayValue,
    required int count,
    @Default(false) bool selected,
  }) = _SearchFacetValue;

  factory SearchFacetValue.fromJson(Map<String, dynamic> json) =>
      _$SearchFacetValueFromJson(json);
}

@freezed
class SearchIndex with _$SearchIndex {
  const factory SearchIndex({
    required String id,
    required String name,
    required String description,
    required SearchIndexType type,
    required SearchIndexStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastIndexedAt,
    required int documentCount,
    required int size,
    Map<String, dynamic>? settings,
  }) = _SearchIndex;

  factory SearchIndex.fromJson(Map<String, dynamic> json) =>
      _$SearchIndexFromJson(json);
}

@freezed
class SearchIndexSettings with _$SearchIndexSettings {
  const factory SearchIndexSettings({
    @Default(10) int maxResults,
    @Default(true) bool enableHighlighting,
    @Default(true) bool enableSuggestions,
    @Default(true) bool enableFacets,
    @Default([]) List<String> searchableFields,
    @Default([]) List<String> facetFields,
    Map<String, double>? fieldWeights,
  }) = _SearchIndexSettings;

  factory SearchIndexSettings.fromJson(Map<String, dynamic> json) =>
      _$SearchIndexSettingsFromJson(json);
}

@freezed
class SavedSearch with _$SavedSearch {
  const factory SavedSearch({
    required String id,
    required String name,
    required String query,
    required List<String> filters,
    required SearchType type,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String userId,
    @Default(false) bool isPublic,
    String? description,
    Map<String, dynamic>? metadata,
  }) = _SavedSearch;

  factory SavedSearch.fromJson(Map<String, dynamic> json) =>
      _$SavedSearchFromJson(json);
}

@freezed
class SearchAnalytics with _$SearchAnalytics {
  const factory SearchAnalytics({
    required List<SearchQueryMetric> topQueries,
    required List<SearchResultMetric> topResults,
    required SearchPerformanceMetric performance,
    required SearchUsageMetric usage,
  }) = _SearchAnalytics;

  factory SearchAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SearchAnalyticsFromJson(json);
}

@freezed
class SearchQueryMetric with _$SearchQueryMetric {
  const factory SearchQueryMetric({
    required String query,
    required int count,
    required double averageScore,
    required double averageTime,
    DateTime? lastSearched,
  }) = _SearchQueryMetric;

  factory SearchQueryMetric.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryMetricFromJson(json);
}

@freezed
class SearchResultMetric with _$SearchResultMetric {
  const factory SearchResultMetric({
    required String itemId,
    required String title,
    required SearchItemType type,
    required int clickCount,
    required double averagePosition,
    DateTime? lastClicked,
  }) = _SearchResultMetric;

  factory SearchResultMetric.fromJson(Map<String, dynamic> json) =>
      _$SearchResultMetricFromJson(json);
}

@freezed
class SearchPerformanceMetric with _$SearchPerformanceMetric {
  const factory SearchPerformanceMetric({
    required double averageQueryTime,
    required double averageIndexTime,
    required int totalQueries,
    required int successfulQueries,
    required int failedQueries,
  }) = _SearchPerformanceMetric;

  factory SearchPerformanceMetric.fromJson(Map<String, dynamic> json) =>
      _$SearchPerformanceMetricFromJson(json);
}

@freezed
class SearchUsageMetric with _$SearchUsageMetric {
  const factory SearchUsageMetric({
    required int dailyQueries,
    required int weeklyQueries,
    required int monthlyQueries,
    required int uniqueUsers,
    required List<int> queryTrends,
  }) = _SearchUsageMetric;

  factory SearchUsageMetric.fromJson(Map<String, dynamic> json) =>
      _$SearchUsageMetricFromJson(json);
}

enum SearchType {
  global,
  users,
  documents,
  logs,
  settings,
  analytics,
}

enum SearchItemType {
  user,
  document,
  logEntry,
  setting,
  report,
  webhook,
  apiKey,
  session,
}

enum SearchSuggestionType {
  query,
  filter,
  field,
}

enum SearchFacetType {
  category,
  dateRange,
  numeric,
  boolean,
}

enum SearchIndexType {
  primary,
  secondary,
  archive,
}

enum SearchIndexStatus {
  active,
  indexing,
  paused,
  error,
}

extension SearchTypeExtension on SearchType {
  String get displayName {
    switch (this) {
      case SearchType.global:
        return 'Global Search';
      case SearchType.users:
        return 'Users';
      case SearchType.documents:
        return 'Documents';
      case SearchType.logs:
        return 'Logs';
      case SearchType.settings:
        return 'Settings';
      case SearchType.analytics:
        return 'Analytics';
    }
  }

  String get endpoint {
    switch (this) {
      case SearchType.global:
        return '/search';
      case SearchType.users:
        return '/search/users';
      case SearchType.documents:
        return '/search/documents';
      case SearchType.logs:
        return '/search/logs';
      case SearchType.settings:
        return '/search/settings';
      case SearchType.analytics:
        return '/search/analytics';
    }
  }
}

extension SearchItemTypeExtension on SearchItemType {
  String get displayName {
    switch (this) {
      case SearchItemType.user:
        return 'User';
      case SearchItemType.document:
        return 'Document';
      case SearchItemType.logEntry:
        return 'Log Entry';
      case SearchItemType.setting:
        return 'Setting';
      case SearchItemType.report:
        return 'Report';
      case SearchItemType.webhook:
        return 'Webhook';
      case SearchItemType.apiKey:
        return 'API Key';
      case SearchItemType.session:
        return 'Session';
    }
  }

  String get icon {
    switch (this) {
      case SearchItemType.user:
        return 'person';
      case SearchItemType.document:
        return 'description';
      case SearchItemType.logEntry:
        return 'list_alt';
      case SearchItemType.setting:
        return 'settings';
      case SearchItemType.report:
        return 'assessment';
      case SearchItemType.webhook:
        return 'webhook';
      case SearchItemType.apiKey:
        return 'vpn_key';
      case SearchItemType.session:
        return 'schedule';
    }
  }
}

extension SearchIndexStatusExtension on SearchIndexStatus {
  String get displayName {
    switch (this) {
      case SearchIndexStatus.active:
        return 'Active';
      case SearchIndexStatus.indexing:
        return 'Indexing';
      case SearchIndexStatus.paused:
        return 'Paused';
      case SearchIndexStatus.error:
        return 'Error';
    }
  }
}