// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchQueryImpl _$$SearchQueryImplFromJson(Map<String, dynamic> json) =>
    _$SearchQueryImpl(
      query: json['query'] as String,
      filters:
          (json['filters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      type:
          $enumDecodeNullable(_$SearchTypeEnumMap, json['type']) ??
          SearchType.global,
      page: (json['page'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SearchQueryImplToJson(_$SearchQueryImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'filters': instance.filters,
      'type': _$SearchTypeEnumMap[instance.type]!,
      'page': instance.page,
      'limit': instance.limit,
      if (instance.metadata case final value?) 'metadata': value,
    };

const _$SearchTypeEnumMap = {
  SearchType.global: 'global',
  SearchType.users: 'users',
  SearchType.documents: 'documents',
  SearchType.logs: 'logs',
  SearchType.settings: 'settings',
  SearchType.analytics: 'analytics',
};

_$SearchResultImpl _$$SearchResultImplFromJson(Map<String, dynamic> json) =>
    _$SearchResultImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => SearchResultItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      processingTime: (json['processingTime'] as num).toDouble(),
      suggestions: (json['suggestions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      facets: (json['facets'] as List<dynamic>?)
          ?.map((e) => SearchFacet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SearchResultImplToJson(_$SearchResultImpl instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totalCount': instance.totalCount,
      'page': instance.page,
      'limit': instance.limit,
      'processingTime': instance.processingTime,
      if (instance.suggestions?.map(
            (k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()),
          )
          case final value?)
        'suggestions': value,
      if (instance.facets?.map((e) => e.toJson()).toList() case final value?)
        'facets': value,
    };

_$SearchResultItemImpl _$$SearchResultItemImplFromJson(
  Map<String, dynamic> json,
) => _$SearchResultItemImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$SearchItemTypeEnumMap, json['type']),
  score: (json['score'] as num).toDouble(),
  lastModified: DateTime.parse(json['lastModified'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
  highlights: (json['highlights'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
);

Map<String, dynamic> _$$SearchResultItemImplToJson(
  _$SearchResultItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$SearchItemTypeEnumMap[instance.type]!,
  'score': instance.score,
  'lastModified': instance.lastModified.toIso8601String(),
  if (instance.metadata case final value?) 'metadata': value,
  if (instance.highlights case final value?) 'highlights': value,
  if (instance.thumbnailUrl case final value?) 'thumbnailUrl': value,
};

const _$SearchItemTypeEnumMap = {
  SearchItemType.user: 'user',
  SearchItemType.document: 'document',
  SearchItemType.logEntry: 'logEntry',
  SearchItemType.setting: 'setting',
  SearchItemType.report: 'report',
  SearchItemType.webhook: 'webhook',
  SearchItemType.apiKey: 'apiKey',
  SearchItemType.session: 'session',
};

_$SearchSuggestionImpl _$$SearchSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$SearchSuggestionImpl(
  text: json['text'] as String,
  score: (json['score'] as num).toDouble(),
  frequency: (json['frequency'] as num).toInt(),
  type: $enumDecodeNullable(_$SearchSuggestionTypeEnumMap, json['type']),
);

Map<String, dynamic> _$$SearchSuggestionImplToJson(
  _$SearchSuggestionImpl instance,
) => <String, dynamic>{
  'text': instance.text,
  'score': instance.score,
  'frequency': instance.frequency,
  if (_$SearchSuggestionTypeEnumMap[instance.type] case final value?)
    'type': value,
};

const _$SearchSuggestionTypeEnumMap = {
  SearchSuggestionType.query: 'query',
  SearchSuggestionType.filter: 'filter',
  SearchSuggestionType.field: 'field',
};

_$SearchFacetImpl _$$SearchFacetImplFromJson(Map<String, dynamic> json) =>
    _$SearchFacetImpl(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      values: (json['values'] as List<dynamic>)
          .map((e) => SearchFacetValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: $enumDecodeNullable(_$SearchFacetTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$SearchFacetImplToJson(
  _$SearchFacetImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'displayName': instance.displayName,
  'values': instance.values.map((e) => e.toJson()).toList(),
  if (_$SearchFacetTypeEnumMap[instance.type] case final value?) 'type': value,
};

const _$SearchFacetTypeEnumMap = {
  SearchFacetType.category: 'category',
  SearchFacetType.dateRange: 'dateRange',
  SearchFacetType.numeric: 'numeric',
  SearchFacetType.boolean: 'boolean',
};

_$SearchFacetValueImpl _$$SearchFacetValueImplFromJson(
  Map<String, dynamic> json,
) => _$SearchFacetValueImpl(
  value: json['value'] as String,
  displayValue: json['displayValue'] as String,
  count: (json['count'] as num).toInt(),
  selected: json['selected'] as bool? ?? false,
);

Map<String, dynamic> _$$SearchFacetValueImplToJson(
  _$SearchFacetValueImpl instance,
) => <String, dynamic>{
  'value': instance.value,
  'displayValue': instance.displayValue,
  'count': instance.count,
  'selected': instance.selected,
};

_$SearchIndexImpl _$$SearchIndexImplFromJson(Map<String, dynamic> json) =>
    _$SearchIndexImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$SearchIndexTypeEnumMap, json['type']),
      status: $enumDecode(_$SearchIndexStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastIndexedAt: json['lastIndexedAt'] == null
          ? null
          : DateTime.parse(json['lastIndexedAt'] as String),
      documentCount: (json['documentCount'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SearchIndexImplToJson(_$SearchIndexImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$SearchIndexTypeEnumMap[instance.type]!,
      'status': _$SearchIndexStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.lastIndexedAt?.toIso8601String() case final value?)
        'lastIndexedAt': value,
      'documentCount': instance.documentCount,
      'size': instance.size,
      if (instance.settings case final value?) 'settings': value,
    };

const _$SearchIndexTypeEnumMap = {
  SearchIndexType.primary: 'primary',
  SearchIndexType.secondary: 'secondary',
  SearchIndexType.archive: 'archive',
};

const _$SearchIndexStatusEnumMap = {
  SearchIndexStatus.active: 'active',
  SearchIndexStatus.indexing: 'indexing',
  SearchIndexStatus.paused: 'paused',
  SearchIndexStatus.error: 'error',
};

_$SearchIndexSettingsImpl _$$SearchIndexSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$SearchIndexSettingsImpl(
  maxResults: (json['maxResults'] as num?)?.toInt() ?? 10,
  enableHighlighting: json['enableHighlighting'] as bool? ?? true,
  enableSuggestions: json['enableSuggestions'] as bool? ?? true,
  enableFacets: json['enableFacets'] as bool? ?? true,
  searchableFields:
      (json['searchableFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  facetFields:
      (json['facetFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  fieldWeights: (json['fieldWeights'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$$SearchIndexSettingsImplToJson(
  _$SearchIndexSettingsImpl instance,
) => <String, dynamic>{
  'maxResults': instance.maxResults,
  'enableHighlighting': instance.enableHighlighting,
  'enableSuggestions': instance.enableSuggestions,
  'enableFacets': instance.enableFacets,
  'searchableFields': instance.searchableFields,
  'facetFields': instance.facetFields,
  if (instance.fieldWeights case final value?) 'fieldWeights': value,
};

_$SavedSearchImpl _$$SavedSearchImplFromJson(Map<String, dynamic> json) =>
    _$SavedSearchImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      query: json['query'] as String,
      filters: (json['filters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: $enumDecode(_$SearchTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SavedSearchImplToJson(_$SavedSearchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'query': instance.query,
      'filters': instance.filters,
      'type': _$SearchTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
      'isPublic': instance.isPublic,
      if (instance.description case final value?) 'description': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

_$SearchAnalyticsImpl _$$SearchAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$SearchAnalyticsImpl(
  topQueries: (json['topQueries'] as List<dynamic>)
      .map((e) => SearchQueryMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  topResults: (json['topResults'] as List<dynamic>)
      .map((e) => SearchResultMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  performance: SearchPerformanceMetric.fromJson(
    json['performance'] as Map<String, dynamic>,
  ),
  usage: SearchUsageMetric.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$SearchAnalyticsImplToJson(
  _$SearchAnalyticsImpl instance,
) => <String, dynamic>{
  'topQueries': instance.topQueries.map((e) => e.toJson()).toList(),
  'topResults': instance.topResults.map((e) => e.toJson()).toList(),
  'performance': instance.performance.toJson(),
  'usage': instance.usage.toJson(),
};

_$SearchQueryMetricImpl _$$SearchQueryMetricImplFromJson(
  Map<String, dynamic> json,
) => _$SearchQueryMetricImpl(
  query: json['query'] as String,
  count: (json['count'] as num).toInt(),
  averageScore: (json['averageScore'] as num).toDouble(),
  averageTime: (json['averageTime'] as num).toDouble(),
  lastSearched: json['lastSearched'] == null
      ? null
      : DateTime.parse(json['lastSearched'] as String),
);

Map<String, dynamic> _$$SearchQueryMetricImplToJson(
  _$SearchQueryMetricImpl instance,
) => <String, dynamic>{
  'query': instance.query,
  'count': instance.count,
  'averageScore': instance.averageScore,
  'averageTime': instance.averageTime,
  if (instance.lastSearched?.toIso8601String() case final value?)
    'lastSearched': value,
};

_$SearchResultMetricImpl _$$SearchResultMetricImplFromJson(
  Map<String, dynamic> json,
) => _$SearchResultMetricImpl(
  itemId: json['itemId'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$SearchItemTypeEnumMap, json['type']),
  clickCount: (json['clickCount'] as num).toInt(),
  averagePosition: (json['averagePosition'] as num).toDouble(),
  lastClicked: json['lastClicked'] == null
      ? null
      : DateTime.parse(json['lastClicked'] as String),
);

Map<String, dynamic> _$$SearchResultMetricImplToJson(
  _$SearchResultMetricImpl instance,
) => <String, dynamic>{
  'itemId': instance.itemId,
  'title': instance.title,
  'type': _$SearchItemTypeEnumMap[instance.type]!,
  'clickCount': instance.clickCount,
  'averagePosition': instance.averagePosition,
  if (instance.lastClicked?.toIso8601String() case final value?)
    'lastClicked': value,
};

_$SearchPerformanceMetricImpl _$$SearchPerformanceMetricImplFromJson(
  Map<String, dynamic> json,
) => _$SearchPerformanceMetricImpl(
  averageQueryTime: (json['averageQueryTime'] as num).toDouble(),
  averageIndexTime: (json['averageIndexTime'] as num).toDouble(),
  totalQueries: (json['totalQueries'] as num).toInt(),
  successfulQueries: (json['successfulQueries'] as num).toInt(),
  failedQueries: (json['failedQueries'] as num).toInt(),
);

Map<String, dynamic> _$$SearchPerformanceMetricImplToJson(
  _$SearchPerformanceMetricImpl instance,
) => <String, dynamic>{
  'averageQueryTime': instance.averageQueryTime,
  'averageIndexTime': instance.averageIndexTime,
  'totalQueries': instance.totalQueries,
  'successfulQueries': instance.successfulQueries,
  'failedQueries': instance.failedQueries,
};

_$SearchUsageMetricImpl _$$SearchUsageMetricImplFromJson(
  Map<String, dynamic> json,
) => _$SearchUsageMetricImpl(
  dailyQueries: (json['dailyQueries'] as num).toInt(),
  weeklyQueries: (json['weeklyQueries'] as num).toInt(),
  monthlyQueries: (json['monthlyQueries'] as num).toInt(),
  uniqueUsers: (json['uniqueUsers'] as num).toInt(),
  queryTrends: (json['queryTrends'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$$SearchUsageMetricImplToJson(
  _$SearchUsageMetricImpl instance,
) => <String, dynamic>{
  'dailyQueries': instance.dailyQueries,
  'weeklyQueries': instance.weeklyQueries,
  'monthlyQueries': instance.monthlyQueries,
  'uniqueUsers': instance.uniqueUsers,
  'queryTrends': instance.queryTrends,
};
