// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchQuery _$SearchQueryFromJson(Map<String, dynamic> json) {
  return _SearchQuery.fromJson(json);
}

/// @nodoc
mixin _$SearchQuery {
  String get query => throw _privateConstructorUsedError;
  List<String> get filters => throw _privateConstructorUsedError;
  SearchType get type => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this SearchQuery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchQueryCopyWith<SearchQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchQueryCopyWith<$Res> {
  factory $SearchQueryCopyWith(
    SearchQuery value,
    $Res Function(SearchQuery) then,
  ) = _$SearchQueryCopyWithImpl<$Res, SearchQuery>;
  @useResult
  $Res call({
    String query,
    List<String> filters,
    SearchType type,
    int page,
    int limit,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$SearchQueryCopyWithImpl<$Res, $Val extends SearchQuery>
    implements $SearchQueryCopyWith<$Res> {
  _$SearchQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? filters = null,
    Object? type = null,
    Object? page = null,
    Object? limit = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SearchType,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchQueryImplCopyWith<$Res>
    implements $SearchQueryCopyWith<$Res> {
  factory _$$SearchQueryImplCopyWith(
    _$SearchQueryImpl value,
    $Res Function(_$SearchQueryImpl) then,
  ) = __$$SearchQueryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    List<String> filters,
    SearchType type,
    int page,
    int limit,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$SearchQueryImplCopyWithImpl<$Res>
    extends _$SearchQueryCopyWithImpl<$Res, _$SearchQueryImpl>
    implements _$$SearchQueryImplCopyWith<$Res> {
  __$$SearchQueryImplCopyWithImpl(
    _$SearchQueryImpl _value,
    $Res Function(_$SearchQueryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? filters = null,
    Object? type = null,
    Object? page = null,
    Object? limit = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$SearchQueryImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        filters: null == filters
            ? _value._filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SearchType,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchQueryImpl implements _SearchQuery {
  const _$SearchQueryImpl({
    required this.query,
    final List<String> filters = const [],
    this.type = SearchType.global,
    this.page = 0,
    this.limit = 20,
    final Map<String, dynamic>? metadata,
  }) : _filters = filters,
       _metadata = metadata;

  factory _$SearchQueryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchQueryImplFromJson(json);

  @override
  final String query;
  final List<String> _filters;
  @override
  @JsonKey()
  List<String> get filters {
    if (_filters is EqualUnmodifiableListView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filters);
  }

  @override
  @JsonKey()
  final SearchType type;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SearchQuery(query: $query, filters: $filters, type: $type, page: $page, limit: $limit, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchQueryImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    const DeepCollectionEquality().hash(_filters),
    type,
    page,
    limit,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of SearchQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchQueryImplCopyWith<_$SearchQueryImpl> get copyWith =>
      __$$SearchQueryImplCopyWithImpl<_$SearchQueryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchQueryImplToJson(this);
  }
}

abstract class _SearchQuery implements SearchQuery {
  const factory _SearchQuery({
    required final String query,
    final List<String> filters,
    final SearchType type,
    final int page,
    final int limit,
    final Map<String, dynamic>? metadata,
  }) = _$SearchQueryImpl;

  factory _SearchQuery.fromJson(Map<String, dynamic> json) =
      _$SearchQueryImpl.fromJson;

  @override
  String get query;
  @override
  List<String> get filters;
  @override
  SearchType get type;
  @override
  int get page;
  @override
  int get limit;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of SearchQuery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchQueryImplCopyWith<_$SearchQueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  return _SearchResult.fromJson(json);
}

/// @nodoc
mixin _$SearchResult {
  List<SearchResultItem> get items => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  double get processingTime => throw _privateConstructorUsedError;
  Map<String, List<SearchSuggestion>>? get suggestions =>
      throw _privateConstructorUsedError;
  List<SearchFacet>? get facets => throw _privateConstructorUsedError;

  /// Serializes this SearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultCopyWith<SearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultCopyWith<$Res> {
  factory $SearchResultCopyWith(
    SearchResult value,
    $Res Function(SearchResult) then,
  ) = _$SearchResultCopyWithImpl<$Res, SearchResult>;
  @useResult
  $Res call({
    List<SearchResultItem> items,
    int totalCount,
    int page,
    int limit,
    double processingTime,
    Map<String, List<SearchSuggestion>>? suggestions,
    List<SearchFacet>? facets,
  });
}

/// @nodoc
class _$SearchResultCopyWithImpl<$Res, $Val extends SearchResult>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? totalCount = null,
    Object? page = null,
    Object? limit = null,
    Object? processingTime = null,
    Object? suggestions = freezed,
    Object? facets = freezed,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<SearchResultItem>,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            processingTime: null == processingTime
                ? _value.processingTime
                : processingTime // ignore: cast_nullable_to_non_nullable
                      as double,
            suggestions: freezed == suggestions
                ? _value.suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<SearchSuggestion>>?,
            facets: freezed == facets
                ? _value.facets
                : facets // ignore: cast_nullable_to_non_nullable
                      as List<SearchFacet>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchResultImplCopyWith<$Res>
    implements $SearchResultCopyWith<$Res> {
  factory _$$SearchResultImplCopyWith(
    _$SearchResultImpl value,
    $Res Function(_$SearchResultImpl) then,
  ) = __$$SearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<SearchResultItem> items,
    int totalCount,
    int page,
    int limit,
    double processingTime,
    Map<String, List<SearchSuggestion>>? suggestions,
    List<SearchFacet>? facets,
  });
}

/// @nodoc
class __$$SearchResultImplCopyWithImpl<$Res>
    extends _$SearchResultCopyWithImpl<$Res, _$SearchResultImpl>
    implements _$$SearchResultImplCopyWith<$Res> {
  __$$SearchResultImplCopyWithImpl(
    _$SearchResultImpl _value,
    $Res Function(_$SearchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? totalCount = null,
    Object? page = null,
    Object? limit = null,
    Object? processingTime = null,
    Object? suggestions = freezed,
    Object? facets = freezed,
  }) {
    return _then(
      _$SearchResultImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<SearchResultItem>,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        processingTime: null == processingTime
            ? _value.processingTime
            : processingTime // ignore: cast_nullable_to_non_nullable
                  as double,
        suggestions: freezed == suggestions
            ? _value._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<SearchSuggestion>>?,
        facets: freezed == facets
            ? _value._facets
            : facets // ignore: cast_nullable_to_non_nullable
                  as List<SearchFacet>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResultImpl implements _SearchResult {
  const _$SearchResultImpl({
    required final List<SearchResultItem> items,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.processingTime,
    final Map<String, List<SearchSuggestion>>? suggestions,
    final List<SearchFacet>? facets,
  }) : _items = items,
       _suggestions = suggestions,
       _facets = facets;

  factory _$SearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResultImplFromJson(json);

  final List<SearchResultItem> _items;
  @override
  List<SearchResultItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int totalCount;
  @override
  final int page;
  @override
  final int limit;
  @override
  final double processingTime;
  final Map<String, List<SearchSuggestion>>? _suggestions;
  @override
  Map<String, List<SearchSuggestion>>? get suggestions {
    final value = _suggestions;
    if (value == null) return null;
    if (_suggestions is EqualUnmodifiableMapView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<SearchFacet>? _facets;
  @override
  List<SearchFacet>? get facets {
    final value = _facets;
    if (value == null) return null;
    if (_facets is EqualUnmodifiableListView) return _facets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SearchResult(items: $items, totalCount: $totalCount, page: $page, limit: $limit, processingTime: $processingTime, suggestions: $suggestions, facets: $facets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.processingTime, processingTime) ||
                other.processingTime == processingTime) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            const DeepCollectionEquality().equals(other._facets, _facets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    totalCount,
    page,
    limit,
    processingTime,
    const DeepCollectionEquality().hash(_suggestions),
    const DeepCollectionEquality().hash(_facets),
  );

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      __$$SearchResultImplCopyWithImpl<_$SearchResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResultImplToJson(this);
  }
}

abstract class _SearchResult implements SearchResult {
  const factory _SearchResult({
    required final List<SearchResultItem> items,
    required final int totalCount,
    required final int page,
    required final int limit,
    required final double processingTime,
    final Map<String, List<SearchSuggestion>>? suggestions,
    final List<SearchFacet>? facets,
  }) = _$SearchResultImpl;

  factory _SearchResult.fromJson(Map<String, dynamic> json) =
      _$SearchResultImpl.fromJson;

  @override
  List<SearchResultItem> get items;
  @override
  int get totalCount;
  @override
  int get page;
  @override
  int get limit;
  @override
  double get processingTime;
  @override
  Map<String, List<SearchSuggestion>>? get suggestions;
  @override
  List<SearchFacet>? get facets;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchResultItem _$SearchResultItemFromJson(Map<String, dynamic> json) {
  return _SearchResultItem.fromJson(json);
}

/// @nodoc
mixin _$SearchResultItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  SearchItemType get type => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  DateTime get lastModified => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String>? get highlights => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// Serializes this SearchResultItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultItemCopyWith<SearchResultItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultItemCopyWith<$Res> {
  factory $SearchResultItemCopyWith(
    SearchResultItem value,
    $Res Function(SearchResultItem) then,
  ) = _$SearchResultItemCopyWithImpl<$Res, SearchResultItem>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SearchItemType type,
    double score,
    DateTime lastModified,
    Map<String, dynamic>? metadata,
    List<String>? highlights,
    String? thumbnailUrl,
  });
}

/// @nodoc
class _$SearchResultItemCopyWithImpl<$Res, $Val extends SearchResultItem>
    implements $SearchResultItemCopyWith<$Res> {
  _$SearchResultItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? score = null,
    Object? lastModified = null,
    Object? metadata = freezed,
    Object? highlights = freezed,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SearchItemType,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            lastModified: null == lastModified
                ? _value.lastModified
                : lastModified // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            highlights: freezed == highlights
                ? _value.highlights
                : highlights // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchResultItemImplCopyWith<$Res>
    implements $SearchResultItemCopyWith<$Res> {
  factory _$$SearchResultItemImplCopyWith(
    _$SearchResultItemImpl value,
    $Res Function(_$SearchResultItemImpl) then,
  ) = __$$SearchResultItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SearchItemType type,
    double score,
    DateTime lastModified,
    Map<String, dynamic>? metadata,
    List<String>? highlights,
    String? thumbnailUrl,
  });
}

/// @nodoc
class __$$SearchResultItemImplCopyWithImpl<$Res>
    extends _$SearchResultItemCopyWithImpl<$Res, _$SearchResultItemImpl>
    implements _$$SearchResultItemImplCopyWith<$Res> {
  __$$SearchResultItemImplCopyWithImpl(
    _$SearchResultItemImpl _value,
    $Res Function(_$SearchResultItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? score = null,
    Object? lastModified = null,
    Object? metadata = freezed,
    Object? highlights = freezed,
    Object? thumbnailUrl = freezed,
  }) {
    return _then(
      _$SearchResultItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SearchItemType,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        lastModified: null == lastModified
            ? _value.lastModified
            : lastModified // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        highlights: freezed == highlights
            ? _value._highlights
            : highlights // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResultItemImpl implements _SearchResultItem {
  const _$SearchResultItemImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.score,
    required this.lastModified,
    final Map<String, dynamic>? metadata,
    final List<String>? highlights,
    this.thumbnailUrl,
  }) : _metadata = metadata,
       _highlights = highlights;

  factory _$SearchResultItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResultItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final SearchItemType type;
  @override
  final double score;
  @override
  final DateTime lastModified;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _highlights;
  @override
  List<String>? get highlights {
    final value = _highlights;
    if (value == null) return null;
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? thumbnailUrl;

  @override
  String toString() {
    return 'SearchResultItem(id: $id, title: $title, description: $description, type: $type, score: $score, lastModified: $lastModified, metadata: $metadata, highlights: $highlights, thumbnailUrl: $thumbnailUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.lastModified, lastModified) ||
                other.lastModified == lastModified) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(
              other._highlights,
              _highlights,
            ) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    type,
    score,
    lastModified,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_highlights),
    thumbnailUrl,
  );

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultItemImplCopyWith<_$SearchResultItemImpl> get copyWith =>
      __$$SearchResultItemImplCopyWithImpl<_$SearchResultItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResultItemImplToJson(this);
  }
}

abstract class _SearchResultItem implements SearchResultItem {
  const factory _SearchResultItem({
    required final String id,
    required final String title,
    required final String description,
    required final SearchItemType type,
    required final double score,
    required final DateTime lastModified,
    final Map<String, dynamic>? metadata,
    final List<String>? highlights,
    final String? thumbnailUrl,
  }) = _$SearchResultItemImpl;

  factory _SearchResultItem.fromJson(Map<String, dynamic> json) =
      _$SearchResultItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  SearchItemType get type;
  @override
  double get score;
  @override
  DateTime get lastModified;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String>? get highlights;
  @override
  String? get thumbnailUrl;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultItemImplCopyWith<_$SearchResultItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchSuggestion _$SearchSuggestionFromJson(Map<String, dynamic> json) {
  return _SearchSuggestion.fromJson(json);
}

/// @nodoc
mixin _$SearchSuggestion {
  String get text => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  int get frequency => throw _privateConstructorUsedError;
  SearchSuggestionType? get type => throw _privateConstructorUsedError;

  /// Serializes this SearchSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchSuggestionCopyWith<SearchSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchSuggestionCopyWith<$Res> {
  factory $SearchSuggestionCopyWith(
    SearchSuggestion value,
    $Res Function(SearchSuggestion) then,
  ) = _$SearchSuggestionCopyWithImpl<$Res, SearchSuggestion>;
  @useResult
  $Res call({
    String text,
    double score,
    int frequency,
    SearchSuggestionType? type,
  });
}

/// @nodoc
class _$SearchSuggestionCopyWithImpl<$Res, $Val extends SearchSuggestion>
    implements $SearchSuggestionCopyWith<$Res> {
  _$SearchSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? score = null,
    Object? frequency = null,
    Object? type = freezed,
  }) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as int,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SearchSuggestionType?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchSuggestionImplCopyWith<$Res>
    implements $SearchSuggestionCopyWith<$Res> {
  factory _$$SearchSuggestionImplCopyWith(
    _$SearchSuggestionImpl value,
    $Res Function(_$SearchSuggestionImpl) then,
  ) = __$$SearchSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String text,
    double score,
    int frequency,
    SearchSuggestionType? type,
  });
}

/// @nodoc
class __$$SearchSuggestionImplCopyWithImpl<$Res>
    extends _$SearchSuggestionCopyWithImpl<$Res, _$SearchSuggestionImpl>
    implements _$$SearchSuggestionImplCopyWith<$Res> {
  __$$SearchSuggestionImplCopyWithImpl(
    _$SearchSuggestionImpl _value,
    $Res Function(_$SearchSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? score = null,
    Object? frequency = null,
    Object? type = freezed,
  }) {
    return _then(
      _$SearchSuggestionImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as int,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SearchSuggestionType?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchSuggestionImpl implements _SearchSuggestion {
  const _$SearchSuggestionImpl({
    required this.text,
    required this.score,
    required this.frequency,
    this.type,
  });

  factory _$SearchSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchSuggestionImplFromJson(json);

  @override
  final String text;
  @override
  final double score;
  @override
  final int frequency;
  @override
  final SearchSuggestionType? type;

  @override
  String toString() {
    return 'SearchSuggestion(text: $text, score: $score, frequency: $frequency, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchSuggestionImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, score, frequency, type);

  /// Create a copy of SearchSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchSuggestionImplCopyWith<_$SearchSuggestionImpl> get copyWith =>
      __$$SearchSuggestionImplCopyWithImpl<_$SearchSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchSuggestionImplToJson(this);
  }
}

abstract class _SearchSuggestion implements SearchSuggestion {
  const factory _SearchSuggestion({
    required final String text,
    required final double score,
    required final int frequency,
    final SearchSuggestionType? type,
  }) = _$SearchSuggestionImpl;

  factory _SearchSuggestion.fromJson(Map<String, dynamic> json) =
      _$SearchSuggestionImpl.fromJson;

  @override
  String get text;
  @override
  double get score;
  @override
  int get frequency;
  @override
  SearchSuggestionType? get type;

  /// Create a copy of SearchSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchSuggestionImplCopyWith<_$SearchSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchFacet _$SearchFacetFromJson(Map<String, dynamic> json) {
  return _SearchFacet.fromJson(json);
}

/// @nodoc
mixin _$SearchFacet {
  String get name => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  List<SearchFacetValue> get values => throw _privateConstructorUsedError;
  SearchFacetType? get type => throw _privateConstructorUsedError;

  /// Serializes this SearchFacet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchFacet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchFacetCopyWith<SearchFacet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFacetCopyWith<$Res> {
  factory $SearchFacetCopyWith(
    SearchFacet value,
    $Res Function(SearchFacet) then,
  ) = _$SearchFacetCopyWithImpl<$Res, SearchFacet>;
  @useResult
  $Res call({
    String name,
    String displayName,
    List<SearchFacetValue> values,
    SearchFacetType? type,
  });
}

/// @nodoc
class _$SearchFacetCopyWithImpl<$Res, $Val extends SearchFacet>
    implements $SearchFacetCopyWith<$Res> {
  _$SearchFacetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchFacet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? displayName = null,
    Object? values = null,
    Object? type = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            values: null == values
                ? _value.values
                : values // ignore: cast_nullable_to_non_nullable
                      as List<SearchFacetValue>,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SearchFacetType?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchFacetImplCopyWith<$Res>
    implements $SearchFacetCopyWith<$Res> {
  factory _$$SearchFacetImplCopyWith(
    _$SearchFacetImpl value,
    $Res Function(_$SearchFacetImpl) then,
  ) = __$$SearchFacetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String displayName,
    List<SearchFacetValue> values,
    SearchFacetType? type,
  });
}

/// @nodoc
class __$$SearchFacetImplCopyWithImpl<$Res>
    extends _$SearchFacetCopyWithImpl<$Res, _$SearchFacetImpl>
    implements _$$SearchFacetImplCopyWith<$Res> {
  __$$SearchFacetImplCopyWithImpl(
    _$SearchFacetImpl _value,
    $Res Function(_$SearchFacetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchFacet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? displayName = null,
    Object? values = null,
    Object? type = freezed,
  }) {
    return _then(
      _$SearchFacetImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        values: null == values
            ? _value._values
            : values // ignore: cast_nullable_to_non_nullable
                  as List<SearchFacetValue>,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SearchFacetType?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchFacetImpl implements _SearchFacet {
  const _$SearchFacetImpl({
    required this.name,
    required this.displayName,
    required final List<SearchFacetValue> values,
    this.type,
  }) : _values = values;

  factory _$SearchFacetImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchFacetImplFromJson(json);

  @override
  final String name;
  @override
  final String displayName;
  final List<SearchFacetValue> _values;
  @override
  List<SearchFacetValue> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  final SearchFacetType? type;

  @override
  String toString() {
    return 'SearchFacet(name: $name, displayName: $displayName, values: $values, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFacetImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    displayName,
    const DeepCollectionEquality().hash(_values),
    type,
  );

  /// Create a copy of SearchFacet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFacetImplCopyWith<_$SearchFacetImpl> get copyWith =>
      __$$SearchFacetImplCopyWithImpl<_$SearchFacetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchFacetImplToJson(this);
  }
}

abstract class _SearchFacet implements SearchFacet {
  const factory _SearchFacet({
    required final String name,
    required final String displayName,
    required final List<SearchFacetValue> values,
    final SearchFacetType? type,
  }) = _$SearchFacetImpl;

  factory _SearchFacet.fromJson(Map<String, dynamic> json) =
      _$SearchFacetImpl.fromJson;

  @override
  String get name;
  @override
  String get displayName;
  @override
  List<SearchFacetValue> get values;
  @override
  SearchFacetType? get type;

  /// Create a copy of SearchFacet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchFacetImplCopyWith<_$SearchFacetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchFacetValue _$SearchFacetValueFromJson(Map<String, dynamic> json) {
  return _SearchFacetValue.fromJson(json);
}

/// @nodoc
mixin _$SearchFacetValue {
  String get value => throw _privateConstructorUsedError;
  String get displayValue => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  bool get selected => throw _privateConstructorUsedError;

  /// Serializes this SearchFacetValue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchFacetValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchFacetValueCopyWith<SearchFacetValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFacetValueCopyWith<$Res> {
  factory $SearchFacetValueCopyWith(
    SearchFacetValue value,
    $Res Function(SearchFacetValue) then,
  ) = _$SearchFacetValueCopyWithImpl<$Res, SearchFacetValue>;
  @useResult
  $Res call({String value, String displayValue, int count, bool selected});
}

/// @nodoc
class _$SearchFacetValueCopyWithImpl<$Res, $Val extends SearchFacetValue>
    implements $SearchFacetValueCopyWith<$Res> {
  _$SearchFacetValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchFacetValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? displayValue = null,
    Object? count = null,
    Object? selected = null,
  }) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            displayValue: null == displayValue
                ? _value.displayValue
                : displayValue // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            selected: null == selected
                ? _value.selected
                : selected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchFacetValueImplCopyWith<$Res>
    implements $SearchFacetValueCopyWith<$Res> {
  factory _$$SearchFacetValueImplCopyWith(
    _$SearchFacetValueImpl value,
    $Res Function(_$SearchFacetValueImpl) then,
  ) = __$$SearchFacetValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, String displayValue, int count, bool selected});
}

/// @nodoc
class __$$SearchFacetValueImplCopyWithImpl<$Res>
    extends _$SearchFacetValueCopyWithImpl<$Res, _$SearchFacetValueImpl>
    implements _$$SearchFacetValueImplCopyWith<$Res> {
  __$$SearchFacetValueImplCopyWithImpl(
    _$SearchFacetValueImpl _value,
    $Res Function(_$SearchFacetValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchFacetValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? displayValue = null,
    Object? count = null,
    Object? selected = null,
  }) {
    return _then(
      _$SearchFacetValueImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        displayValue: null == displayValue
            ? _value.displayValue
            : displayValue // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        selected: null == selected
            ? _value.selected
            : selected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchFacetValueImpl implements _SearchFacetValue {
  const _$SearchFacetValueImpl({
    required this.value,
    required this.displayValue,
    required this.count,
    this.selected = false,
  });

  factory _$SearchFacetValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchFacetValueImplFromJson(json);

  @override
  final String value;
  @override
  final String displayValue;
  @override
  final int count;
  @override
  @JsonKey()
  final bool selected;

  @override
  String toString() {
    return 'SearchFacetValue(value: $value, displayValue: $displayValue, count: $count, selected: $selected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFacetValueImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.displayValue, displayValue) ||
                other.displayValue == displayValue) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.selected, selected) ||
                other.selected == selected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, value, displayValue, count, selected);

  /// Create a copy of SearchFacetValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFacetValueImplCopyWith<_$SearchFacetValueImpl> get copyWith =>
      __$$SearchFacetValueImplCopyWithImpl<_$SearchFacetValueImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchFacetValueImplToJson(this);
  }
}

abstract class _SearchFacetValue implements SearchFacetValue {
  const factory _SearchFacetValue({
    required final String value,
    required final String displayValue,
    required final int count,
    final bool selected,
  }) = _$SearchFacetValueImpl;

  factory _SearchFacetValue.fromJson(Map<String, dynamic> json) =
      _$SearchFacetValueImpl.fromJson;

  @override
  String get value;
  @override
  String get displayValue;
  @override
  int get count;
  @override
  bool get selected;

  /// Create a copy of SearchFacetValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchFacetValueImplCopyWith<_$SearchFacetValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchIndex _$SearchIndexFromJson(Map<String, dynamic> json) {
  return _SearchIndex.fromJson(json);
}

/// @nodoc
mixin _$SearchIndex {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  SearchIndexType get type => throw _privateConstructorUsedError;
  SearchIndexStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastIndexedAt => throw _privateConstructorUsedError;
  int get documentCount => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  Map<String, dynamic>? get settings => throw _privateConstructorUsedError;

  /// Serializes this SearchIndex to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchIndex
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchIndexCopyWith<SearchIndex> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchIndexCopyWith<$Res> {
  factory $SearchIndexCopyWith(
    SearchIndex value,
    $Res Function(SearchIndex) then,
  ) = _$SearchIndexCopyWithImpl<$Res, SearchIndex>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    SearchIndexType type,
    SearchIndexStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastIndexedAt,
    int documentCount,
    int size,
    Map<String, dynamic>? settings,
  });
}

/// @nodoc
class _$SearchIndexCopyWithImpl<$Res, $Val extends SearchIndex>
    implements $SearchIndexCopyWith<$Res> {
  _$SearchIndexCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchIndex
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastIndexedAt = freezed,
    Object? documentCount = null,
    Object? size = null,
    Object? settings = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SearchIndexType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SearchIndexStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastIndexedAt: freezed == lastIndexedAt
                ? _value.lastIndexedAt
                : lastIndexedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            documentCount: null == documentCount
                ? _value.documentCount
                : documentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchIndexImplCopyWith<$Res>
    implements $SearchIndexCopyWith<$Res> {
  factory _$$SearchIndexImplCopyWith(
    _$SearchIndexImpl value,
    $Res Function(_$SearchIndexImpl) then,
  ) = __$$SearchIndexImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    SearchIndexType type,
    SearchIndexStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastIndexedAt,
    int documentCount,
    int size,
    Map<String, dynamic>? settings,
  });
}

/// @nodoc
class __$$SearchIndexImplCopyWithImpl<$Res>
    extends _$SearchIndexCopyWithImpl<$Res, _$SearchIndexImpl>
    implements _$$SearchIndexImplCopyWith<$Res> {
  __$$SearchIndexImplCopyWithImpl(
    _$SearchIndexImpl _value,
    $Res Function(_$SearchIndexImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchIndex
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastIndexedAt = freezed,
    Object? documentCount = null,
    Object? size = null,
    Object? settings = freezed,
  }) {
    return _then(
      _$SearchIndexImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SearchIndexType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SearchIndexStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastIndexedAt: freezed == lastIndexedAt
            ? _value.lastIndexedAt
            : lastIndexedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        documentCount: null == documentCount
            ? _value.documentCount
            : documentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        settings: freezed == settings
            ? _value._settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchIndexImpl implements _SearchIndex {
  const _$SearchIndexImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastIndexedAt,
    required this.documentCount,
    required this.size,
    final Map<String, dynamic>? settings,
  }) : _settings = settings;

  factory _$SearchIndexImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchIndexImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final SearchIndexType type;
  @override
  final SearchIndexStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? lastIndexedAt;
  @override
  final int documentCount;
  @override
  final int size;
  final Map<String, dynamic>? _settings;
  @override
  Map<String, dynamic>? get settings {
    final value = _settings;
    if (value == null) return null;
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SearchIndex(id: $id, name: $name, description: $description, type: $type, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, lastIndexedAt: $lastIndexedAt, documentCount: $documentCount, size: $size, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchIndexImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastIndexedAt, lastIndexedAt) ||
                other.lastIndexedAt == lastIndexedAt) &&
            (identical(other.documentCount, documentCount) ||
                other.documentCount == documentCount) &&
            (identical(other.size, size) || other.size == size) &&
            const DeepCollectionEquality().equals(other._settings, _settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    type,
    status,
    createdAt,
    updatedAt,
    lastIndexedAt,
    documentCount,
    size,
    const DeepCollectionEquality().hash(_settings),
  );

  /// Create a copy of SearchIndex
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchIndexImplCopyWith<_$SearchIndexImpl> get copyWith =>
      __$$SearchIndexImplCopyWithImpl<_$SearchIndexImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchIndexImplToJson(this);
  }
}

abstract class _SearchIndex implements SearchIndex {
  const factory _SearchIndex({
    required final String id,
    required final String name,
    required final String description,
    required final SearchIndexType type,
    required final SearchIndexStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? lastIndexedAt,
    required final int documentCount,
    required final int size,
    final Map<String, dynamic>? settings,
  }) = _$SearchIndexImpl;

  factory _SearchIndex.fromJson(Map<String, dynamic> json) =
      _$SearchIndexImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  SearchIndexType get type;
  @override
  SearchIndexStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get lastIndexedAt;
  @override
  int get documentCount;
  @override
  int get size;
  @override
  Map<String, dynamic>? get settings;

  /// Create a copy of SearchIndex
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchIndexImplCopyWith<_$SearchIndexImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchIndexSettings _$SearchIndexSettingsFromJson(Map<String, dynamic> json) {
  return _SearchIndexSettings.fromJson(json);
}

/// @nodoc
mixin _$SearchIndexSettings {
  int get maxResults => throw _privateConstructorUsedError;
  bool get enableHighlighting => throw _privateConstructorUsedError;
  bool get enableSuggestions => throw _privateConstructorUsedError;
  bool get enableFacets => throw _privateConstructorUsedError;
  List<String> get searchableFields => throw _privateConstructorUsedError;
  List<String> get facetFields => throw _privateConstructorUsedError;
  Map<String, double>? get fieldWeights => throw _privateConstructorUsedError;

  /// Serializes this SearchIndexSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchIndexSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchIndexSettingsCopyWith<SearchIndexSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchIndexSettingsCopyWith<$Res> {
  factory $SearchIndexSettingsCopyWith(
    SearchIndexSettings value,
    $Res Function(SearchIndexSettings) then,
  ) = _$SearchIndexSettingsCopyWithImpl<$Res, SearchIndexSettings>;
  @useResult
  $Res call({
    int maxResults,
    bool enableHighlighting,
    bool enableSuggestions,
    bool enableFacets,
    List<String> searchableFields,
    List<String> facetFields,
    Map<String, double>? fieldWeights,
  });
}

/// @nodoc
class _$SearchIndexSettingsCopyWithImpl<$Res, $Val extends SearchIndexSettings>
    implements $SearchIndexSettingsCopyWith<$Res> {
  _$SearchIndexSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchIndexSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxResults = null,
    Object? enableHighlighting = null,
    Object? enableSuggestions = null,
    Object? enableFacets = null,
    Object? searchableFields = null,
    Object? facetFields = null,
    Object? fieldWeights = freezed,
  }) {
    return _then(
      _value.copyWith(
            maxResults: null == maxResults
                ? _value.maxResults
                : maxResults // ignore: cast_nullable_to_non_nullable
                      as int,
            enableHighlighting: null == enableHighlighting
                ? _value.enableHighlighting
                : enableHighlighting // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSuggestions: null == enableSuggestions
                ? _value.enableSuggestions
                : enableSuggestions // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableFacets: null == enableFacets
                ? _value.enableFacets
                : enableFacets // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchableFields: null == searchableFields
                ? _value.searchableFields
                : searchableFields // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            facetFields: null == facetFields
                ? _value.facetFields
                : facetFields // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            fieldWeights: freezed == fieldWeights
                ? _value.fieldWeights
                : fieldWeights // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchIndexSettingsImplCopyWith<$Res>
    implements $SearchIndexSettingsCopyWith<$Res> {
  factory _$$SearchIndexSettingsImplCopyWith(
    _$SearchIndexSettingsImpl value,
    $Res Function(_$SearchIndexSettingsImpl) then,
  ) = __$$SearchIndexSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int maxResults,
    bool enableHighlighting,
    bool enableSuggestions,
    bool enableFacets,
    List<String> searchableFields,
    List<String> facetFields,
    Map<String, double>? fieldWeights,
  });
}

/// @nodoc
class __$$SearchIndexSettingsImplCopyWithImpl<$Res>
    extends _$SearchIndexSettingsCopyWithImpl<$Res, _$SearchIndexSettingsImpl>
    implements _$$SearchIndexSettingsImplCopyWith<$Res> {
  __$$SearchIndexSettingsImplCopyWithImpl(
    _$SearchIndexSettingsImpl _value,
    $Res Function(_$SearchIndexSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchIndexSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxResults = null,
    Object? enableHighlighting = null,
    Object? enableSuggestions = null,
    Object? enableFacets = null,
    Object? searchableFields = null,
    Object? facetFields = null,
    Object? fieldWeights = freezed,
  }) {
    return _then(
      _$SearchIndexSettingsImpl(
        maxResults: null == maxResults
            ? _value.maxResults
            : maxResults // ignore: cast_nullable_to_non_nullable
                  as int,
        enableHighlighting: null == enableHighlighting
            ? _value.enableHighlighting
            : enableHighlighting // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSuggestions: null == enableSuggestions
            ? _value.enableSuggestions
            : enableSuggestions // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableFacets: null == enableFacets
            ? _value.enableFacets
            : enableFacets // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchableFields: null == searchableFields
            ? _value._searchableFields
            : searchableFields // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        facetFields: null == facetFields
            ? _value._facetFields
            : facetFields // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        fieldWeights: freezed == fieldWeights
            ? _value._fieldWeights
            : fieldWeights // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchIndexSettingsImpl implements _SearchIndexSettings {
  const _$SearchIndexSettingsImpl({
    this.maxResults = 10,
    this.enableHighlighting = true,
    this.enableSuggestions = true,
    this.enableFacets = true,
    final List<String> searchableFields = const [],
    final List<String> facetFields = const [],
    final Map<String, double>? fieldWeights,
  }) : _searchableFields = searchableFields,
       _facetFields = facetFields,
       _fieldWeights = fieldWeights;

  factory _$SearchIndexSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchIndexSettingsImplFromJson(json);

  @override
  @JsonKey()
  final int maxResults;
  @override
  @JsonKey()
  final bool enableHighlighting;
  @override
  @JsonKey()
  final bool enableSuggestions;
  @override
  @JsonKey()
  final bool enableFacets;
  final List<String> _searchableFields;
  @override
  @JsonKey()
  List<String> get searchableFields {
    if (_searchableFields is EqualUnmodifiableListView)
      return _searchableFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchableFields);
  }

  final List<String> _facetFields;
  @override
  @JsonKey()
  List<String> get facetFields {
    if (_facetFields is EqualUnmodifiableListView) return _facetFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_facetFields);
  }

  final Map<String, double>? _fieldWeights;
  @override
  Map<String, double>? get fieldWeights {
    final value = _fieldWeights;
    if (value == null) return null;
    if (_fieldWeights is EqualUnmodifiableMapView) return _fieldWeights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SearchIndexSettings(maxResults: $maxResults, enableHighlighting: $enableHighlighting, enableSuggestions: $enableSuggestions, enableFacets: $enableFacets, searchableFields: $searchableFields, facetFields: $facetFields, fieldWeights: $fieldWeights)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchIndexSettingsImpl &&
            (identical(other.maxResults, maxResults) ||
                other.maxResults == maxResults) &&
            (identical(other.enableHighlighting, enableHighlighting) ||
                other.enableHighlighting == enableHighlighting) &&
            (identical(other.enableSuggestions, enableSuggestions) ||
                other.enableSuggestions == enableSuggestions) &&
            (identical(other.enableFacets, enableFacets) ||
                other.enableFacets == enableFacets) &&
            const DeepCollectionEquality().equals(
              other._searchableFields,
              _searchableFields,
            ) &&
            const DeepCollectionEquality().equals(
              other._facetFields,
              _facetFields,
            ) &&
            const DeepCollectionEquality().equals(
              other._fieldWeights,
              _fieldWeights,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    maxResults,
    enableHighlighting,
    enableSuggestions,
    enableFacets,
    const DeepCollectionEquality().hash(_searchableFields),
    const DeepCollectionEquality().hash(_facetFields),
    const DeepCollectionEquality().hash(_fieldWeights),
  );

  /// Create a copy of SearchIndexSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchIndexSettingsImplCopyWith<_$SearchIndexSettingsImpl> get copyWith =>
      __$$SearchIndexSettingsImplCopyWithImpl<_$SearchIndexSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchIndexSettingsImplToJson(this);
  }
}

abstract class _SearchIndexSettings implements SearchIndexSettings {
  const factory _SearchIndexSettings({
    final int maxResults,
    final bool enableHighlighting,
    final bool enableSuggestions,
    final bool enableFacets,
    final List<String> searchableFields,
    final List<String> facetFields,
    final Map<String, double>? fieldWeights,
  }) = _$SearchIndexSettingsImpl;

  factory _SearchIndexSettings.fromJson(Map<String, dynamic> json) =
      _$SearchIndexSettingsImpl.fromJson;

  @override
  int get maxResults;
  @override
  bool get enableHighlighting;
  @override
  bool get enableSuggestions;
  @override
  bool get enableFacets;
  @override
  List<String> get searchableFields;
  @override
  List<String> get facetFields;
  @override
  Map<String, double>? get fieldWeights;

  /// Create a copy of SearchIndexSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchIndexSettingsImplCopyWith<_$SearchIndexSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SavedSearch _$SavedSearchFromJson(Map<String, dynamic> json) {
  return _SavedSearch.fromJson(json);
}

/// @nodoc
mixin _$SavedSearch {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  List<String> get filters => throw _privateConstructorUsedError;
  SearchType get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this SavedSearch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedSearch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedSearchCopyWith<SavedSearch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedSearchCopyWith<$Res> {
  factory $SavedSearchCopyWith(
    SavedSearch value,
    $Res Function(SavedSearch) then,
  ) = _$SavedSearchCopyWithImpl<$Res, SavedSearch>;
  @useResult
  $Res call({
    String id,
    String name,
    String query,
    List<String> filters,
    SearchType type,
    DateTime createdAt,
    DateTime updatedAt,
    String userId,
    bool isPublic,
    String? description,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$SavedSearchCopyWithImpl<$Res, $Val extends SavedSearch>
    implements $SavedSearchCopyWith<$Res> {
  _$SavedSearchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedSearch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? query = null,
    Object? filters = null,
    Object? type = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userId = null,
    Object? isPublic = null,
    Object? description = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SearchType,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SavedSearchImplCopyWith<$Res>
    implements $SavedSearchCopyWith<$Res> {
  factory _$$SavedSearchImplCopyWith(
    _$SavedSearchImpl value,
    $Res Function(_$SavedSearchImpl) then,
  ) = __$$SavedSearchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String query,
    List<String> filters,
    SearchType type,
    DateTime createdAt,
    DateTime updatedAt,
    String userId,
    bool isPublic,
    String? description,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$SavedSearchImplCopyWithImpl<$Res>
    extends _$SavedSearchCopyWithImpl<$Res, _$SavedSearchImpl>
    implements _$$SavedSearchImplCopyWith<$Res> {
  __$$SavedSearchImplCopyWithImpl(
    _$SavedSearchImpl _value,
    $Res Function(_$SavedSearchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedSearch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? query = null,
    Object? filters = null,
    Object? type = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userId = null,
    Object? isPublic = null,
    Object? description = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$SavedSearchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        filters: null == filters
            ? _value._filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SearchType,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SavedSearchImpl implements _SavedSearch {
  const _$SavedSearchImpl({
    required this.id,
    required this.name,
    required this.query,
    required final List<String> filters,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isPublic = false,
    this.description,
    final Map<String, dynamic>? metadata,
  }) : _filters = filters,
       _metadata = metadata;

  factory _$SavedSearchImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedSearchImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String query;
  final List<String> _filters;
  @override
  List<String> get filters {
    if (_filters is EqualUnmodifiableListView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filters);
  }

  @override
  final SearchType type;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String userId;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  final String? description;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SavedSearch(id: $id, name: $name, query: $query, filters: $filters, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, isPublic: $isPublic, description: $description, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedSearchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    query,
    const DeepCollectionEquality().hash(_filters),
    type,
    createdAt,
    updatedAt,
    userId,
    isPublic,
    description,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of SavedSearch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedSearchImplCopyWith<_$SavedSearchImpl> get copyWith =>
      __$$SavedSearchImplCopyWithImpl<_$SavedSearchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedSearchImplToJson(this);
  }
}

abstract class _SavedSearch implements SavedSearch {
  const factory _SavedSearch({
    required final String id,
    required final String name,
    required final String query,
    required final List<String> filters,
    required final SearchType type,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final String userId,
    final bool isPublic,
    final String? description,
    final Map<String, dynamic>? metadata,
  }) = _$SavedSearchImpl;

  factory _SavedSearch.fromJson(Map<String, dynamic> json) =
      _$SavedSearchImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get query;
  @override
  List<String> get filters;
  @override
  SearchType get type;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get userId;
  @override
  bool get isPublic;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of SavedSearch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedSearchImplCopyWith<_$SavedSearchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchAnalytics _$SearchAnalyticsFromJson(Map<String, dynamic> json) {
  return _SearchAnalytics.fromJson(json);
}

/// @nodoc
mixin _$SearchAnalytics {
  List<SearchQueryMetric> get topQueries => throw _privateConstructorUsedError;
  List<SearchResultMetric> get topResults => throw _privateConstructorUsedError;
  SearchPerformanceMetric get performance => throw _privateConstructorUsedError;
  SearchUsageMetric get usage => throw _privateConstructorUsedError;

  /// Serializes this SearchAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchAnalyticsCopyWith<SearchAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchAnalyticsCopyWith<$Res> {
  factory $SearchAnalyticsCopyWith(
    SearchAnalytics value,
    $Res Function(SearchAnalytics) then,
  ) = _$SearchAnalyticsCopyWithImpl<$Res, SearchAnalytics>;
  @useResult
  $Res call({
    List<SearchQueryMetric> topQueries,
    List<SearchResultMetric> topResults,
    SearchPerformanceMetric performance,
    SearchUsageMetric usage,
  });

  $SearchPerformanceMetricCopyWith<$Res> get performance;
  $SearchUsageMetricCopyWith<$Res> get usage;
}

/// @nodoc
class _$SearchAnalyticsCopyWithImpl<$Res, $Val extends SearchAnalytics>
    implements $SearchAnalyticsCopyWith<$Res> {
  _$SearchAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topQueries = null,
    Object? topResults = null,
    Object? performance = null,
    Object? usage = null,
  }) {
    return _then(
      _value.copyWith(
            topQueries: null == topQueries
                ? _value.topQueries
                : topQueries // ignore: cast_nullable_to_non_nullable
                      as List<SearchQueryMetric>,
            topResults: null == topResults
                ? _value.topResults
                : topResults // ignore: cast_nullable_to_non_nullable
                      as List<SearchResultMetric>,
            performance: null == performance
                ? _value.performance
                : performance // ignore: cast_nullable_to_non_nullable
                      as SearchPerformanceMetric,
            usage: null == usage
                ? _value.usage
                : usage // ignore: cast_nullable_to_non_nullable
                      as SearchUsageMetric,
          )
          as $Val,
    );
  }

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchPerformanceMetricCopyWith<$Res> get performance {
    return $SearchPerformanceMetricCopyWith<$Res>(_value.performance, (value) {
      return _then(_value.copyWith(performance: value) as $Val);
    });
  }

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchUsageMetricCopyWith<$Res> get usage {
    return $SearchUsageMetricCopyWith<$Res>(_value.usage, (value) {
      return _then(_value.copyWith(usage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchAnalyticsImplCopyWith<$Res>
    implements $SearchAnalyticsCopyWith<$Res> {
  factory _$$SearchAnalyticsImplCopyWith(
    _$SearchAnalyticsImpl value,
    $Res Function(_$SearchAnalyticsImpl) then,
  ) = __$$SearchAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<SearchQueryMetric> topQueries,
    List<SearchResultMetric> topResults,
    SearchPerformanceMetric performance,
    SearchUsageMetric usage,
  });

  @override
  $SearchPerformanceMetricCopyWith<$Res> get performance;
  @override
  $SearchUsageMetricCopyWith<$Res> get usage;
}

/// @nodoc
class __$$SearchAnalyticsImplCopyWithImpl<$Res>
    extends _$SearchAnalyticsCopyWithImpl<$Res, _$SearchAnalyticsImpl>
    implements _$$SearchAnalyticsImplCopyWith<$Res> {
  __$$SearchAnalyticsImplCopyWithImpl(
    _$SearchAnalyticsImpl _value,
    $Res Function(_$SearchAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topQueries = null,
    Object? topResults = null,
    Object? performance = null,
    Object? usage = null,
  }) {
    return _then(
      _$SearchAnalyticsImpl(
        topQueries: null == topQueries
            ? _value._topQueries
            : topQueries // ignore: cast_nullable_to_non_nullable
                  as List<SearchQueryMetric>,
        topResults: null == topResults
            ? _value._topResults
            : topResults // ignore: cast_nullable_to_non_nullable
                  as List<SearchResultMetric>,
        performance: null == performance
            ? _value.performance
            : performance // ignore: cast_nullable_to_non_nullable
                  as SearchPerformanceMetric,
        usage: null == usage
            ? _value.usage
            : usage // ignore: cast_nullable_to_non_nullable
                  as SearchUsageMetric,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchAnalyticsImpl implements _SearchAnalytics {
  const _$SearchAnalyticsImpl({
    required final List<SearchQueryMetric> topQueries,
    required final List<SearchResultMetric> topResults,
    required this.performance,
    required this.usage,
  }) : _topQueries = topQueries,
       _topResults = topResults;

  factory _$SearchAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchAnalyticsImplFromJson(json);

  final List<SearchQueryMetric> _topQueries;
  @override
  List<SearchQueryMetric> get topQueries {
    if (_topQueries is EqualUnmodifiableListView) return _topQueries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topQueries);
  }

  final List<SearchResultMetric> _topResults;
  @override
  List<SearchResultMetric> get topResults {
    if (_topResults is EqualUnmodifiableListView) return _topResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topResults);
  }

  @override
  final SearchPerformanceMetric performance;
  @override
  final SearchUsageMetric usage;

  @override
  String toString() {
    return 'SearchAnalytics(topQueries: $topQueries, topResults: $topResults, performance: $performance, usage: $usage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchAnalyticsImpl &&
            const DeepCollectionEquality().equals(
              other._topQueries,
              _topQueries,
            ) &&
            const DeepCollectionEquality().equals(
              other._topResults,
              _topResults,
            ) &&
            (identical(other.performance, performance) ||
                other.performance == performance) &&
            (identical(other.usage, usage) || other.usage == usage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_topQueries),
    const DeepCollectionEquality().hash(_topResults),
    performance,
    usage,
  );

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchAnalyticsImplCopyWith<_$SearchAnalyticsImpl> get copyWith =>
      __$$SearchAnalyticsImplCopyWithImpl<_$SearchAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchAnalyticsImplToJson(this);
  }
}

abstract class _SearchAnalytics implements SearchAnalytics {
  const factory _SearchAnalytics({
    required final List<SearchQueryMetric> topQueries,
    required final List<SearchResultMetric> topResults,
    required final SearchPerformanceMetric performance,
    required final SearchUsageMetric usage,
  }) = _$SearchAnalyticsImpl;

  factory _SearchAnalytics.fromJson(Map<String, dynamic> json) =
      _$SearchAnalyticsImpl.fromJson;

  @override
  List<SearchQueryMetric> get topQueries;
  @override
  List<SearchResultMetric> get topResults;
  @override
  SearchPerformanceMetric get performance;
  @override
  SearchUsageMetric get usage;

  /// Create a copy of SearchAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchAnalyticsImplCopyWith<_$SearchAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchQueryMetric _$SearchQueryMetricFromJson(Map<String, dynamic> json) {
  return _SearchQueryMetric.fromJson(json);
}

/// @nodoc
mixin _$SearchQueryMetric {
  String get query => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get averageScore => throw _privateConstructorUsedError;
  double get averageTime => throw _privateConstructorUsedError;
  DateTime? get lastSearched => throw _privateConstructorUsedError;

  /// Serializes this SearchQueryMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchQueryMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchQueryMetricCopyWith<SearchQueryMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchQueryMetricCopyWith<$Res> {
  factory $SearchQueryMetricCopyWith(
    SearchQueryMetric value,
    $Res Function(SearchQueryMetric) then,
  ) = _$SearchQueryMetricCopyWithImpl<$Res, SearchQueryMetric>;
  @useResult
  $Res call({
    String query,
    int count,
    double averageScore,
    double averageTime,
    DateTime? lastSearched,
  });
}

/// @nodoc
class _$SearchQueryMetricCopyWithImpl<$Res, $Val extends SearchQueryMetric>
    implements $SearchQueryMetricCopyWith<$Res> {
  _$SearchQueryMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchQueryMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? count = null,
    Object? averageScore = null,
    Object? averageTime = null,
    Object? lastSearched = freezed,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            averageScore: null == averageScore
                ? _value.averageScore
                : averageScore // ignore: cast_nullable_to_non_nullable
                      as double,
            averageTime: null == averageTime
                ? _value.averageTime
                : averageTime // ignore: cast_nullable_to_non_nullable
                      as double,
            lastSearched: freezed == lastSearched
                ? _value.lastSearched
                : lastSearched // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchQueryMetricImplCopyWith<$Res>
    implements $SearchQueryMetricCopyWith<$Res> {
  factory _$$SearchQueryMetricImplCopyWith(
    _$SearchQueryMetricImpl value,
    $Res Function(_$SearchQueryMetricImpl) then,
  ) = __$$SearchQueryMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    int count,
    double averageScore,
    double averageTime,
    DateTime? lastSearched,
  });
}

/// @nodoc
class __$$SearchQueryMetricImplCopyWithImpl<$Res>
    extends _$SearchQueryMetricCopyWithImpl<$Res, _$SearchQueryMetricImpl>
    implements _$$SearchQueryMetricImplCopyWith<$Res> {
  __$$SearchQueryMetricImplCopyWithImpl(
    _$SearchQueryMetricImpl _value,
    $Res Function(_$SearchQueryMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchQueryMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? count = null,
    Object? averageScore = null,
    Object? averageTime = null,
    Object? lastSearched = freezed,
  }) {
    return _then(
      _$SearchQueryMetricImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        averageScore: null == averageScore
            ? _value.averageScore
            : averageScore // ignore: cast_nullable_to_non_nullable
                  as double,
        averageTime: null == averageTime
            ? _value.averageTime
            : averageTime // ignore: cast_nullable_to_non_nullable
                  as double,
        lastSearched: freezed == lastSearched
            ? _value.lastSearched
            : lastSearched // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchQueryMetricImpl implements _SearchQueryMetric {
  const _$SearchQueryMetricImpl({
    required this.query,
    required this.count,
    required this.averageScore,
    required this.averageTime,
    this.lastSearched,
  });

  factory _$SearchQueryMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchQueryMetricImplFromJson(json);

  @override
  final String query;
  @override
  final int count;
  @override
  final double averageScore;
  @override
  final double averageTime;
  @override
  final DateTime? lastSearched;

  @override
  String toString() {
    return 'SearchQueryMetric(query: $query, count: $count, averageScore: $averageScore, averageTime: $averageTime, lastSearched: $lastSearched)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchQueryMetricImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.averageTime, averageTime) ||
                other.averageTime == averageTime) &&
            (identical(other.lastSearched, lastSearched) ||
                other.lastSearched == lastSearched));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    count,
    averageScore,
    averageTime,
    lastSearched,
  );

  /// Create a copy of SearchQueryMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchQueryMetricImplCopyWith<_$SearchQueryMetricImpl> get copyWith =>
      __$$SearchQueryMetricImplCopyWithImpl<_$SearchQueryMetricImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchQueryMetricImplToJson(this);
  }
}

abstract class _SearchQueryMetric implements SearchQueryMetric {
  const factory _SearchQueryMetric({
    required final String query,
    required final int count,
    required final double averageScore,
    required final double averageTime,
    final DateTime? lastSearched,
  }) = _$SearchQueryMetricImpl;

  factory _SearchQueryMetric.fromJson(Map<String, dynamic> json) =
      _$SearchQueryMetricImpl.fromJson;

  @override
  String get query;
  @override
  int get count;
  @override
  double get averageScore;
  @override
  double get averageTime;
  @override
  DateTime? get lastSearched;

  /// Create a copy of SearchQueryMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchQueryMetricImplCopyWith<_$SearchQueryMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchResultMetric _$SearchResultMetricFromJson(Map<String, dynamic> json) {
  return _SearchResultMetric.fromJson(json);
}

/// @nodoc
mixin _$SearchResultMetric {
  String get itemId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  SearchItemType get type => throw _privateConstructorUsedError;
  int get clickCount => throw _privateConstructorUsedError;
  double get averagePosition => throw _privateConstructorUsedError;
  DateTime? get lastClicked => throw _privateConstructorUsedError;

  /// Serializes this SearchResultMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResultMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultMetricCopyWith<SearchResultMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultMetricCopyWith<$Res> {
  factory $SearchResultMetricCopyWith(
    SearchResultMetric value,
    $Res Function(SearchResultMetric) then,
  ) = _$SearchResultMetricCopyWithImpl<$Res, SearchResultMetric>;
  @useResult
  $Res call({
    String itemId,
    String title,
    SearchItemType type,
    int clickCount,
    double averagePosition,
    DateTime? lastClicked,
  });
}

/// @nodoc
class _$SearchResultMetricCopyWithImpl<$Res, $Val extends SearchResultMetric>
    implements $SearchResultMetricCopyWith<$Res> {
  _$SearchResultMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResultMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? title = null,
    Object? type = null,
    Object? clickCount = null,
    Object? averagePosition = null,
    Object? lastClicked = freezed,
  }) {
    return _then(
      _value.copyWith(
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SearchItemType,
            clickCount: null == clickCount
                ? _value.clickCount
                : clickCount // ignore: cast_nullable_to_non_nullable
                      as int,
            averagePosition: null == averagePosition
                ? _value.averagePosition
                : averagePosition // ignore: cast_nullable_to_non_nullable
                      as double,
            lastClicked: freezed == lastClicked
                ? _value.lastClicked
                : lastClicked // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchResultMetricImplCopyWith<$Res>
    implements $SearchResultMetricCopyWith<$Res> {
  factory _$$SearchResultMetricImplCopyWith(
    _$SearchResultMetricImpl value,
    $Res Function(_$SearchResultMetricImpl) then,
  ) = __$$SearchResultMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String itemId,
    String title,
    SearchItemType type,
    int clickCount,
    double averagePosition,
    DateTime? lastClicked,
  });
}

/// @nodoc
class __$$SearchResultMetricImplCopyWithImpl<$Res>
    extends _$SearchResultMetricCopyWithImpl<$Res, _$SearchResultMetricImpl>
    implements _$$SearchResultMetricImplCopyWith<$Res> {
  __$$SearchResultMetricImplCopyWithImpl(
    _$SearchResultMetricImpl _value,
    $Res Function(_$SearchResultMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchResultMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? title = null,
    Object? type = null,
    Object? clickCount = null,
    Object? averagePosition = null,
    Object? lastClicked = freezed,
  }) {
    return _then(
      _$SearchResultMetricImpl(
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SearchItemType,
        clickCount: null == clickCount
            ? _value.clickCount
            : clickCount // ignore: cast_nullable_to_non_nullable
                  as int,
        averagePosition: null == averagePosition
            ? _value.averagePosition
            : averagePosition // ignore: cast_nullable_to_non_nullable
                  as double,
        lastClicked: freezed == lastClicked
            ? _value.lastClicked
            : lastClicked // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResultMetricImpl implements _SearchResultMetric {
  const _$SearchResultMetricImpl({
    required this.itemId,
    required this.title,
    required this.type,
    required this.clickCount,
    required this.averagePosition,
    this.lastClicked,
  });

  factory _$SearchResultMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResultMetricImplFromJson(json);

  @override
  final String itemId;
  @override
  final String title;
  @override
  final SearchItemType type;
  @override
  final int clickCount;
  @override
  final double averagePosition;
  @override
  final DateTime? lastClicked;

  @override
  String toString() {
    return 'SearchResultMetric(itemId: $itemId, title: $title, type: $type, clickCount: $clickCount, averagePosition: $averagePosition, lastClicked: $lastClicked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultMetricImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.clickCount, clickCount) ||
                other.clickCount == clickCount) &&
            (identical(other.averagePosition, averagePosition) ||
                other.averagePosition == averagePosition) &&
            (identical(other.lastClicked, lastClicked) ||
                other.lastClicked == lastClicked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemId,
    title,
    type,
    clickCount,
    averagePosition,
    lastClicked,
  );

  /// Create a copy of SearchResultMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultMetricImplCopyWith<_$SearchResultMetricImpl> get copyWith =>
      __$$SearchResultMetricImplCopyWithImpl<_$SearchResultMetricImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResultMetricImplToJson(this);
  }
}

abstract class _SearchResultMetric implements SearchResultMetric {
  const factory _SearchResultMetric({
    required final String itemId,
    required final String title,
    required final SearchItemType type,
    required final int clickCount,
    required final double averagePosition,
    final DateTime? lastClicked,
  }) = _$SearchResultMetricImpl;

  factory _SearchResultMetric.fromJson(Map<String, dynamic> json) =
      _$SearchResultMetricImpl.fromJson;

  @override
  String get itemId;
  @override
  String get title;
  @override
  SearchItemType get type;
  @override
  int get clickCount;
  @override
  double get averagePosition;
  @override
  DateTime? get lastClicked;

  /// Create a copy of SearchResultMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultMetricImplCopyWith<_$SearchResultMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchPerformanceMetric _$SearchPerformanceMetricFromJson(
  Map<String, dynamic> json,
) {
  return _SearchPerformanceMetric.fromJson(json);
}

/// @nodoc
mixin _$SearchPerformanceMetric {
  double get averageQueryTime => throw _privateConstructorUsedError;
  double get averageIndexTime => throw _privateConstructorUsedError;
  int get totalQueries => throw _privateConstructorUsedError;
  int get successfulQueries => throw _privateConstructorUsedError;
  int get failedQueries => throw _privateConstructorUsedError;

  /// Serializes this SearchPerformanceMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchPerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchPerformanceMetricCopyWith<SearchPerformanceMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchPerformanceMetricCopyWith<$Res> {
  factory $SearchPerformanceMetricCopyWith(
    SearchPerformanceMetric value,
    $Res Function(SearchPerformanceMetric) then,
  ) = _$SearchPerformanceMetricCopyWithImpl<$Res, SearchPerformanceMetric>;
  @useResult
  $Res call({
    double averageQueryTime,
    double averageIndexTime,
    int totalQueries,
    int successfulQueries,
    int failedQueries,
  });
}

/// @nodoc
class _$SearchPerformanceMetricCopyWithImpl<
  $Res,
  $Val extends SearchPerformanceMetric
>
    implements $SearchPerformanceMetricCopyWith<$Res> {
  _$SearchPerformanceMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchPerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageQueryTime = null,
    Object? averageIndexTime = null,
    Object? totalQueries = null,
    Object? successfulQueries = null,
    Object? failedQueries = null,
  }) {
    return _then(
      _value.copyWith(
            averageQueryTime: null == averageQueryTime
                ? _value.averageQueryTime
                : averageQueryTime // ignore: cast_nullable_to_non_nullable
                      as double,
            averageIndexTime: null == averageIndexTime
                ? _value.averageIndexTime
                : averageIndexTime // ignore: cast_nullable_to_non_nullable
                      as double,
            totalQueries: null == totalQueries
                ? _value.totalQueries
                : totalQueries // ignore: cast_nullable_to_non_nullable
                      as int,
            successfulQueries: null == successfulQueries
                ? _value.successfulQueries
                : successfulQueries // ignore: cast_nullable_to_non_nullable
                      as int,
            failedQueries: null == failedQueries
                ? _value.failedQueries
                : failedQueries // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchPerformanceMetricImplCopyWith<$Res>
    implements $SearchPerformanceMetricCopyWith<$Res> {
  factory _$$SearchPerformanceMetricImplCopyWith(
    _$SearchPerformanceMetricImpl value,
    $Res Function(_$SearchPerformanceMetricImpl) then,
  ) = __$$SearchPerformanceMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double averageQueryTime,
    double averageIndexTime,
    int totalQueries,
    int successfulQueries,
    int failedQueries,
  });
}

/// @nodoc
class __$$SearchPerformanceMetricImplCopyWithImpl<$Res>
    extends
        _$SearchPerformanceMetricCopyWithImpl<
          $Res,
          _$SearchPerformanceMetricImpl
        >
    implements _$$SearchPerformanceMetricImplCopyWith<$Res> {
  __$$SearchPerformanceMetricImplCopyWithImpl(
    _$SearchPerformanceMetricImpl _value,
    $Res Function(_$SearchPerformanceMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchPerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageQueryTime = null,
    Object? averageIndexTime = null,
    Object? totalQueries = null,
    Object? successfulQueries = null,
    Object? failedQueries = null,
  }) {
    return _then(
      _$SearchPerformanceMetricImpl(
        averageQueryTime: null == averageQueryTime
            ? _value.averageQueryTime
            : averageQueryTime // ignore: cast_nullable_to_non_nullable
                  as double,
        averageIndexTime: null == averageIndexTime
            ? _value.averageIndexTime
            : averageIndexTime // ignore: cast_nullable_to_non_nullable
                  as double,
        totalQueries: null == totalQueries
            ? _value.totalQueries
            : totalQueries // ignore: cast_nullable_to_non_nullable
                  as int,
        successfulQueries: null == successfulQueries
            ? _value.successfulQueries
            : successfulQueries // ignore: cast_nullable_to_non_nullable
                  as int,
        failedQueries: null == failedQueries
            ? _value.failedQueries
            : failedQueries // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchPerformanceMetricImpl implements _SearchPerformanceMetric {
  const _$SearchPerformanceMetricImpl({
    required this.averageQueryTime,
    required this.averageIndexTime,
    required this.totalQueries,
    required this.successfulQueries,
    required this.failedQueries,
  });

  factory _$SearchPerformanceMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchPerformanceMetricImplFromJson(json);

  @override
  final double averageQueryTime;
  @override
  final double averageIndexTime;
  @override
  final int totalQueries;
  @override
  final int successfulQueries;
  @override
  final int failedQueries;

  @override
  String toString() {
    return 'SearchPerformanceMetric(averageQueryTime: $averageQueryTime, averageIndexTime: $averageIndexTime, totalQueries: $totalQueries, successfulQueries: $successfulQueries, failedQueries: $failedQueries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchPerformanceMetricImpl &&
            (identical(other.averageQueryTime, averageQueryTime) ||
                other.averageQueryTime == averageQueryTime) &&
            (identical(other.averageIndexTime, averageIndexTime) ||
                other.averageIndexTime == averageIndexTime) &&
            (identical(other.totalQueries, totalQueries) ||
                other.totalQueries == totalQueries) &&
            (identical(other.successfulQueries, successfulQueries) ||
                other.successfulQueries == successfulQueries) &&
            (identical(other.failedQueries, failedQueries) ||
                other.failedQueries == failedQueries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    averageQueryTime,
    averageIndexTime,
    totalQueries,
    successfulQueries,
    failedQueries,
  );

  /// Create a copy of SearchPerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchPerformanceMetricImplCopyWith<_$SearchPerformanceMetricImpl>
  get copyWith =>
      __$$SearchPerformanceMetricImplCopyWithImpl<
        _$SearchPerformanceMetricImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchPerformanceMetricImplToJson(this);
  }
}

abstract class _SearchPerformanceMetric implements SearchPerformanceMetric {
  const factory _SearchPerformanceMetric({
    required final double averageQueryTime,
    required final double averageIndexTime,
    required final int totalQueries,
    required final int successfulQueries,
    required final int failedQueries,
  }) = _$SearchPerformanceMetricImpl;

  factory _SearchPerformanceMetric.fromJson(Map<String, dynamic> json) =
      _$SearchPerformanceMetricImpl.fromJson;

  @override
  double get averageQueryTime;
  @override
  double get averageIndexTime;
  @override
  int get totalQueries;
  @override
  int get successfulQueries;
  @override
  int get failedQueries;

  /// Create a copy of SearchPerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchPerformanceMetricImplCopyWith<_$SearchPerformanceMetricImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SearchUsageMetric _$SearchUsageMetricFromJson(Map<String, dynamic> json) {
  return _SearchUsageMetric.fromJson(json);
}

/// @nodoc
mixin _$SearchUsageMetric {
  int get dailyQueries => throw _privateConstructorUsedError;
  int get weeklyQueries => throw _privateConstructorUsedError;
  int get monthlyQueries => throw _privateConstructorUsedError;
  int get uniqueUsers => throw _privateConstructorUsedError;
  List<int> get queryTrends => throw _privateConstructorUsedError;

  /// Serializes this SearchUsageMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchUsageMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchUsageMetricCopyWith<SearchUsageMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchUsageMetricCopyWith<$Res> {
  factory $SearchUsageMetricCopyWith(
    SearchUsageMetric value,
    $Res Function(SearchUsageMetric) then,
  ) = _$SearchUsageMetricCopyWithImpl<$Res, SearchUsageMetric>;
  @useResult
  $Res call({
    int dailyQueries,
    int weeklyQueries,
    int monthlyQueries,
    int uniqueUsers,
    List<int> queryTrends,
  });
}

/// @nodoc
class _$SearchUsageMetricCopyWithImpl<$Res, $Val extends SearchUsageMetric>
    implements $SearchUsageMetricCopyWith<$Res> {
  _$SearchUsageMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchUsageMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyQueries = null,
    Object? weeklyQueries = null,
    Object? monthlyQueries = null,
    Object? uniqueUsers = null,
    Object? queryTrends = null,
  }) {
    return _then(
      _value.copyWith(
            dailyQueries: null == dailyQueries
                ? _value.dailyQueries
                : dailyQueries // ignore: cast_nullable_to_non_nullable
                      as int,
            weeklyQueries: null == weeklyQueries
                ? _value.weeklyQueries
                : weeklyQueries // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyQueries: null == monthlyQueries
                ? _value.monthlyQueries
                : monthlyQueries // ignore: cast_nullable_to_non_nullable
                      as int,
            uniqueUsers: null == uniqueUsers
                ? _value.uniqueUsers
                : uniqueUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            queryTrends: null == queryTrends
                ? _value.queryTrends
                : queryTrends // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchUsageMetricImplCopyWith<$Res>
    implements $SearchUsageMetricCopyWith<$Res> {
  factory _$$SearchUsageMetricImplCopyWith(
    _$SearchUsageMetricImpl value,
    $Res Function(_$SearchUsageMetricImpl) then,
  ) = __$$SearchUsageMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int dailyQueries,
    int weeklyQueries,
    int monthlyQueries,
    int uniqueUsers,
    List<int> queryTrends,
  });
}

/// @nodoc
class __$$SearchUsageMetricImplCopyWithImpl<$Res>
    extends _$SearchUsageMetricCopyWithImpl<$Res, _$SearchUsageMetricImpl>
    implements _$$SearchUsageMetricImplCopyWith<$Res> {
  __$$SearchUsageMetricImplCopyWithImpl(
    _$SearchUsageMetricImpl _value,
    $Res Function(_$SearchUsageMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchUsageMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyQueries = null,
    Object? weeklyQueries = null,
    Object? monthlyQueries = null,
    Object? uniqueUsers = null,
    Object? queryTrends = null,
  }) {
    return _then(
      _$SearchUsageMetricImpl(
        dailyQueries: null == dailyQueries
            ? _value.dailyQueries
            : dailyQueries // ignore: cast_nullable_to_non_nullable
                  as int,
        weeklyQueries: null == weeklyQueries
            ? _value.weeklyQueries
            : weeklyQueries // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyQueries: null == monthlyQueries
            ? _value.monthlyQueries
            : monthlyQueries // ignore: cast_nullable_to_non_nullable
                  as int,
        uniqueUsers: null == uniqueUsers
            ? _value.uniqueUsers
            : uniqueUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        queryTrends: null == queryTrends
            ? _value._queryTrends
            : queryTrends // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchUsageMetricImpl implements _SearchUsageMetric {
  const _$SearchUsageMetricImpl({
    required this.dailyQueries,
    required this.weeklyQueries,
    required this.monthlyQueries,
    required this.uniqueUsers,
    required final List<int> queryTrends,
  }) : _queryTrends = queryTrends;

  factory _$SearchUsageMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchUsageMetricImplFromJson(json);

  @override
  final int dailyQueries;
  @override
  final int weeklyQueries;
  @override
  final int monthlyQueries;
  @override
  final int uniqueUsers;
  final List<int> _queryTrends;
  @override
  List<int> get queryTrends {
    if (_queryTrends is EqualUnmodifiableListView) return _queryTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queryTrends);
  }

  @override
  String toString() {
    return 'SearchUsageMetric(dailyQueries: $dailyQueries, weeklyQueries: $weeklyQueries, monthlyQueries: $monthlyQueries, uniqueUsers: $uniqueUsers, queryTrends: $queryTrends)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchUsageMetricImpl &&
            (identical(other.dailyQueries, dailyQueries) ||
                other.dailyQueries == dailyQueries) &&
            (identical(other.weeklyQueries, weeklyQueries) ||
                other.weeklyQueries == weeklyQueries) &&
            (identical(other.monthlyQueries, monthlyQueries) ||
                other.monthlyQueries == monthlyQueries) &&
            (identical(other.uniqueUsers, uniqueUsers) ||
                other.uniqueUsers == uniqueUsers) &&
            const DeepCollectionEquality().equals(
              other._queryTrends,
              _queryTrends,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dailyQueries,
    weeklyQueries,
    monthlyQueries,
    uniqueUsers,
    const DeepCollectionEquality().hash(_queryTrends),
  );

  /// Create a copy of SearchUsageMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchUsageMetricImplCopyWith<_$SearchUsageMetricImpl> get copyWith =>
      __$$SearchUsageMetricImplCopyWithImpl<_$SearchUsageMetricImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchUsageMetricImplToJson(this);
  }
}

abstract class _SearchUsageMetric implements SearchUsageMetric {
  const factory _SearchUsageMetric({
    required final int dailyQueries,
    required final int weeklyQueries,
    required final int monthlyQueries,
    required final int uniqueUsers,
    required final List<int> queryTrends,
  }) = _$SearchUsageMetricImpl;

  factory _SearchUsageMetric.fromJson(Map<String, dynamic> json) =
      _$SearchUsageMetricImpl.fromJson;

  @override
  int get dailyQueries;
  @override
  int get weeklyQueries;
  @override
  int get monthlyQueries;
  @override
  int get uniqueUsers;
  @override
  List<int> get queryTrends;

  /// Create a copy of SearchUsageMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchUsageMetricImplCopyWith<_$SearchUsageMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
