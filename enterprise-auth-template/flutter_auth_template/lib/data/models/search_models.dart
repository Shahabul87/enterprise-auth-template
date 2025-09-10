import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_models.freezed.dart';
part 'search_models.g.dart';

@freezed
class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    required String query,
    @Default([]) List&lt;String&gt; filters,
    @Default(SearchType.global) SearchType type,
    @Default(0) int page,
    @Default(20) int limit,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _SearchQuery;

  factory SearchQuery.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SearchQueryFromJson(json);
}

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required List&lt;SearchResultItem&gt; items,
    required int totalCount,
    required int page,
    required int limit,
    required double processingTime,
    Map&lt;String, List&lt;SearchSuggestion&gt;&gt;? suggestions,
    List&lt;SearchFacet&gt;? facets,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    Map&lt;String, dynamic&gt;? metadata,
    List&lt;String&gt;? highlights,
    String? thumbnailUrl,
  }) = _SearchResultItem;

  factory SearchResultItem.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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

  factory SearchSuggestion.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SearchSuggestionFromJson(json);
}

@freezed
class SearchFacet with _$SearchFacet {
  const factory SearchFacet({
    required String name,
    required String displayName,
    required List&lt;SearchFacetValue&gt; values,
    SearchFacetType? type,
  }) = _SearchFacet;

  factory SearchFacet.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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

  factory SearchFacetValue.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
    Map&lt;String, dynamic&gt;? settings,
  }) = _SearchIndex;

  factory SearchIndex.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SearchIndexFromJson(json);
}

@freezed
class SearchIndexSettings with _$SearchIndexSettings {
  const factory SearchIndexSettings({
    @Default(10) int maxResults,
    @Default(true) bool enableHighlighting,
    @Default(true) bool enableSuggestions,
    @Default(true) bool enableFacets,
    @Default([]) List&lt;String&gt; searchableFields,
    @Default([]) List&lt;String&gt; facetFields,
    Map&lt;String, double&gt;? fieldWeights,
  }) = _SearchIndexSettings;

  factory SearchIndexSettings.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SearchIndexSettingsFromJson(json);
}

@freezed
class SavedSearch with _$SavedSearch {
  const factory SavedSearch({
    required String id,
    required String name,
    required String query,
    required List&lt;String&gt; filters,
    required SearchType type,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String userId,
    @Default(false) bool isPublic,
    String? description,
    Map&lt;String, dynamic&gt;? metadata,
  }) = _SavedSearch;

  factory SavedSearch.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SavedSearchFromJson(json);
}

@freezed
class SearchAnalytics with _$SearchAnalytics {
  const factory SearchAnalytics({
    required List&lt;SearchQueryMetric&gt; topQueries,
    required List&lt;SearchResultMetric&gt; topResults,
    required SearchPerformanceMetric performance,
    required SearchUsageMetric usage,
  }) = _SearchAnalytics;

  factory SearchAnalytics.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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

  factory SearchQueryMetric.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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

  factory SearchResultMetric.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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

  factory SearchPerformanceMetric.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
      _$SearchPerformanceMetricFromJson(json);
}

@freezed
class SearchUsageMetric with _$SearchUsageMetric {
  const factory SearchUsageMetric({
    required int dailyQueries,
    required int weeklyQueries,
    required int monthlyQueries,
    required int uniqueUsers,
    required List&lt;int&gt; queryTrends,
  }) = _SearchUsageMetric;

  factory SearchUsageMetric.fromJson(Map&lt;String, dynamic&gt; json) =&gt;
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
        return &apos;Global Search&apos;;
      case SearchType.users:
        return &apos;Users&apos;;
      case SearchType.documents:
        return &apos;Documents&apos;;
      case SearchType.logs:
        return &apos;Logs&apos;;
      case SearchType.settings:
        return &apos;Settings&apos;;
      case SearchType.analytics:
        return &apos;Analytics&apos;;
    }
  }

  String get endpoint {
    switch (this) {
      case SearchType.global:
        return &apos;/search&apos;;
      case SearchType.users:
        return &apos;/search/users&apos;;
      case SearchType.documents:
        return &apos;/search/documents&apos;;
      case SearchType.logs:
        return &apos;/search/logs&apos;;
      case SearchType.settings:
        return &apos;/search/settings&apos;;
      case SearchType.analytics:
        return &apos;/search/analytics&apos;;
    }
  }
}

extension SearchItemTypeExtension on SearchItemType {
  String get displayName {
    switch (this) {
      case SearchItemType.user:
        return &apos;User&apos;;
      case SearchItemType.document:
        return &apos;Document&apos;;
      case SearchItemType.logEntry:
        return &apos;Log Entry&apos;;
      case SearchItemType.setting:
        return &apos;Setting&apos;;
      case SearchItemType.report:
        return &apos;Report&apos;;
      case SearchItemType.webhook:
        return &apos;Webhook&apos;;
      case SearchItemType.apiKey:
        return &apos;API Key&apos;;
      case SearchItemType.session:
        return &apos;Session&apos;;
    }
  }

  String get icon {
    switch (this) {
      case SearchItemType.user:
        return &apos;person&apos;;
      case SearchItemType.document:
        return &apos;description&apos;;
      case SearchItemType.logEntry:
        return &apos;list_alt&apos;;
      case SearchItemType.setting:
        return &apos;settings&apos;;
      case SearchItemType.report:
        return &apos;assessment&apos;;
      case SearchItemType.webhook:
        return &apos;webhook&apos;;
      case SearchItemType.apiKey:
        return &apos;vpn_key&apos;;
      case SearchItemType.session:
        return &apos;schedule&apos;;
    }
  }
}

extension SearchIndexStatusExtension on SearchIndexStatus {
  String get displayName {
    switch (this) {
      case SearchIndexStatus.active:
        return &apos;Active&apos;;
      case SearchIndexStatus.indexing:
        return &apos;Indexing&apos;;
      case SearchIndexStatus.paused:
        return &apos;Paused&apos;;
      case SearchIndexStatus.error:
        return &apos;Error&apos;;
    }
  }
}