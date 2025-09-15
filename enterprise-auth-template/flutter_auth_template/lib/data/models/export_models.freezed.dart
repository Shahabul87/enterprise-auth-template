// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExportRequest _$ExportRequestFromJson(Map<String, dynamic> json) {
  return _ExportRequest.fromJson(json);
}

/// @nodoc
mixin _$ExportRequest {
  ExportType get type => throw _privateConstructorUsedError;
  ExportFormat get format => throw _privateConstructorUsedError;
  ExportFilters? get filters => throw _privateConstructorUsedError;
  ExportOptions? get options => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  List<String>? get includedFields => throw _privateConstructorUsedError;
  List<String>? get excludedFields => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ExportRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportRequestCopyWith<ExportRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportRequestCopyWith<$Res> {
  factory $ExportRequestCopyWith(
    ExportRequest value,
    $Res Function(ExportRequest) then,
  ) = _$ExportRequestCopyWithImpl<$Res, ExportRequest>;
  @useResult
  $Res call({
    ExportType type,
    ExportFormat format,
    ExportFilters? filters,
    ExportOptions? options,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? includedFields,
    List<String>? excludedFields,
    Map<String, dynamic>? metadata,
  });

  $ExportFiltersCopyWith<$Res>? get filters;
  $ExportOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class _$ExportRequestCopyWithImpl<$Res, $Val extends ExportRequest>
    implements $ExportRequestCopyWith<$Res> {
  _$ExportRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? format = null,
    Object? filters = freezed,
    Object? options = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? includedFields = freezed,
    Object? excludedFields = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ExportType,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as ExportFormat,
            filters: freezed == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as ExportFilters?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as ExportOptions?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            includedFields: freezed == includedFields
                ? _value.includedFields
                : includedFields // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            excludedFields: freezed == excludedFields
                ? _value.excludedFields
                : excludedFields // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of ExportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExportFiltersCopyWith<$Res>? get filters {
    if (_value.filters == null) {
      return null;
    }

    return $ExportFiltersCopyWith<$Res>(_value.filters!, (value) {
      return _then(_value.copyWith(filters: value) as $Val);
    });
  }

  /// Create a copy of ExportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExportOptionsCopyWith<$Res>? get options {
    if (_value.options == null) {
      return null;
    }

    return $ExportOptionsCopyWith<$Res>(_value.options!, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExportRequestImplCopyWith<$Res>
    implements $ExportRequestCopyWith<$Res> {
  factory _$$ExportRequestImplCopyWith(
    _$ExportRequestImpl value,
    $Res Function(_$ExportRequestImpl) then,
  ) = __$$ExportRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ExportType type,
    ExportFormat format,
    ExportFilters? filters,
    ExportOptions? options,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? includedFields,
    List<String>? excludedFields,
    Map<String, dynamic>? metadata,
  });

  @override
  $ExportFiltersCopyWith<$Res>? get filters;
  @override
  $ExportOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class __$$ExportRequestImplCopyWithImpl<$Res>
    extends _$ExportRequestCopyWithImpl<$Res, _$ExportRequestImpl>
    implements _$$ExportRequestImplCopyWith<$Res> {
  __$$ExportRequestImplCopyWithImpl(
    _$ExportRequestImpl _value,
    $Res Function(_$ExportRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? format = null,
    Object? filters = freezed,
    Object? options = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? includedFields = freezed,
    Object? excludedFields = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ExportRequestImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ExportType,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as ExportFormat,
        filters: freezed == filters
            ? _value.filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as ExportFilters?,
        options: freezed == options
            ? _value.options
            : options // ignore: cast_nullable_to_non_nullable
                  as ExportOptions?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        includedFields: freezed == includedFields
            ? _value._includedFields
            : includedFields // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        excludedFields: freezed == excludedFields
            ? _value._excludedFields
            : excludedFields // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
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
class _$ExportRequestImpl implements _ExportRequest {
  const _$ExportRequestImpl({
    required this.type,
    required this.format,
    this.filters,
    this.options,
    this.startDate,
    this.endDate,
    final List<String>? includedFields,
    final List<String>? excludedFields,
    final Map<String, dynamic>? metadata,
  }) : _includedFields = includedFields,
       _excludedFields = excludedFields,
       _metadata = metadata;

  factory _$ExportRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExportRequestImplFromJson(json);

  @override
  final ExportType type;
  @override
  final ExportFormat format;
  @override
  final ExportFilters? filters;
  @override
  final ExportOptions? options;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  final List<String>? _includedFields;
  @override
  List<String>? get includedFields {
    final value = _includedFields;
    if (value == null) return null;
    if (_includedFields is EqualUnmodifiableListView) return _includedFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _excludedFields;
  @override
  List<String>? get excludedFields {
    final value = _excludedFields;
    if (value == null) return null;
    if (_excludedFields is EqualUnmodifiableListView) return _excludedFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
    return 'ExportRequest(type: $type, format: $format, filters: $filters, options: $options, startDate: $startDate, endDate: $endDate, includedFields: $includedFields, excludedFields: $excludedFields, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportRequestImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.filters, filters) || other.filters == filters) &&
            (identical(other.options, options) || other.options == options) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(
              other._includedFields,
              _includedFields,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedFields,
              _excludedFields,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    format,
    filters,
    options,
    startDate,
    endDate,
    const DeepCollectionEquality().hash(_includedFields),
    const DeepCollectionEquality().hash(_excludedFields),
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ExportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportRequestImplCopyWith<_$ExportRequestImpl> get copyWith =>
      __$$ExportRequestImplCopyWithImpl<_$ExportRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExportRequestImplToJson(this);
  }
}

abstract class _ExportRequest implements ExportRequest {
  const factory _ExportRequest({
    required final ExportType type,
    required final ExportFormat format,
    final ExportFilters? filters,
    final ExportOptions? options,
    final DateTime? startDate,
    final DateTime? endDate,
    final List<String>? includedFields,
    final List<String>? excludedFields,
    final Map<String, dynamic>? metadata,
  }) = _$ExportRequestImpl;

  factory _ExportRequest.fromJson(Map<String, dynamic> json) =
      _$ExportRequestImpl.fromJson;

  @override
  ExportType get type;
  @override
  ExportFormat get format;
  @override
  ExportFilters? get filters;
  @override
  ExportOptions? get options;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  List<String>? get includedFields;
  @override
  List<String>? get excludedFields;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ExportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportRequestImplCopyWith<_$ExportRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExportJob _$ExportJobFromJson(Map<String, dynamic> json) {
  return _ExportJob.fromJson(json);
}

/// @nodoc
mixin _$ExportJob {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  ExportType get type => throw _privateConstructorUsedError;
  ExportFormat get format => throw _privateConstructorUsedError;
  ExportStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get downloadUrl => throw _privateConstructorUsedError;
  String? get fileName => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  int? get recordCount => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  double? get progress => throw _privateConstructorUsedError;
  ExportFilters? get filters => throw _privateConstructorUsedError;
  ExportOptions? get options => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ExportJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExportJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportJobCopyWith<ExportJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportJobCopyWith<$Res> {
  factory $ExportJobCopyWith(ExportJob value, $Res Function(ExportJob) then) =
      _$ExportJobCopyWithImpl<$Res, ExportJob>;
  @useResult
  $Res call({
    String id,
    String userId,
    ExportType type,
    ExportFormat format,
    ExportStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? downloadUrl,
    String? fileName,
    int? fileSize,
    int? recordCount,
    String? error,
    double? progress,
    ExportFilters? filters,
    ExportOptions? options,
    Map<String, dynamic>? metadata,
  });

  $ExportFiltersCopyWith<$Res>? get filters;
  $ExportOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class _$ExportJobCopyWithImpl<$Res, $Val extends ExportJob>
    implements $ExportJobCopyWith<$Res> {
  _$ExportJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? format = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? downloadUrl = freezed,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? recordCount = freezed,
    Object? error = freezed,
    Object? progress = freezed,
    Object? filters = freezed,
    Object? options = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ExportType,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as ExportFormat,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ExportStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            downloadUrl: freezed == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileName: freezed == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            recordCount: freezed == recordCount
                ? _value.recordCount
                : recordCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            progress: freezed == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double?,
            filters: freezed == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as ExportFilters?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as ExportOptions?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of ExportJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExportFiltersCopyWith<$Res>? get filters {
    if (_value.filters == null) {
      return null;
    }

    return $ExportFiltersCopyWith<$Res>(_value.filters!, (value) {
      return _then(_value.copyWith(filters: value) as $Val);
    });
  }

  /// Create a copy of ExportJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExportOptionsCopyWith<$Res>? get options {
    if (_value.options == null) {
      return null;
    }

    return $ExportOptionsCopyWith<$Res>(_value.options!, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExportJobImplCopyWith<$Res>
    implements $ExportJobCopyWith<$Res> {
  factory _$$ExportJobImplCopyWith(
    _$ExportJobImpl value,
    $Res Function(_$ExportJobImpl) then,
  ) = __$$ExportJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    ExportType type,
    ExportFormat format,
    ExportStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? downloadUrl,
    String? fileName,
    int? fileSize,
    int? recordCount,
    String? error,
    double? progress,
    ExportFilters? filters,
    ExportOptions? options,
    Map<String, dynamic>? metadata,
  });

  @override
  $ExportFiltersCopyWith<$Res>? get filters;
  @override
  $ExportOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class __$$ExportJobImplCopyWithImpl<$Res>
    extends _$ExportJobCopyWithImpl<$Res, _$ExportJobImpl>
    implements _$$ExportJobImplCopyWith<$Res> {
  __$$ExportJobImplCopyWithImpl(
    _$ExportJobImpl _value,
    $Res Function(_$ExportJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? format = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? downloadUrl = freezed,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? recordCount = freezed,
    Object? error = freezed,
    Object? progress = freezed,
    Object? filters = freezed,
    Object? options = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ExportJobImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ExportType,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as ExportFormat,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ExportStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        downloadUrl: freezed == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: freezed == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        recordCount: freezed == recordCount
            ? _value.recordCount
            : recordCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double?,
        filters: freezed == filters
            ? _value.filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as ExportFilters?,
        options: freezed == options
            ? _value.options
            : options // ignore: cast_nullable_to_non_nullable
                  as ExportOptions?,
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
class _$ExportJobImpl implements _ExportJob {
  const _$ExportJobImpl({
    required this.id,
    required this.userId,
    required this.type,
    required this.format,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.downloadUrl,
    this.fileName,
    this.fileSize,
    this.recordCount,
    this.error,
    this.progress,
    this.filters,
    this.options,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$ExportJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExportJobImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final ExportType type;
  @override
  final ExportFormat format;
  @override
  final ExportStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? downloadUrl;
  @override
  final String? fileName;
  @override
  final int? fileSize;
  @override
  final int? recordCount;
  @override
  final String? error;
  @override
  final double? progress;
  @override
  final ExportFilters? filters;
  @override
  final ExportOptions? options;
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
    return 'ExportJob(id: $id, userId: $userId, type: $type, format: $format, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt, downloadUrl: $downloadUrl, fileName: $fileName, fileSize: $fileSize, recordCount: $recordCount, error: $error, progress: $progress, filters: $filters, options: $options, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.recordCount, recordCount) ||
                other.recordCount == recordCount) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.filters, filters) || other.filters == filters) &&
            (identical(other.options, options) || other.options == options) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    type,
    format,
    status,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
    downloadUrl,
    fileName,
    fileSize,
    recordCount,
    error,
    progress,
    filters,
    options,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ExportJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportJobImplCopyWith<_$ExportJobImpl> get copyWith =>
      __$$ExportJobImplCopyWithImpl<_$ExportJobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExportJobImplToJson(this);
  }
}

abstract class _ExportJob implements ExportJob {
  const factory _ExportJob({
    required final String id,
    required final String userId,
    required final ExportType type,
    required final ExportFormat format,
    required final ExportStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final String? downloadUrl,
    final String? fileName,
    final int? fileSize,
    final int? recordCount,
    final String? error,
    final double? progress,
    final ExportFilters? filters,
    final ExportOptions? options,
    final Map<String, dynamic>? metadata,
  }) = _$ExportJobImpl;

  factory _ExportJob.fromJson(Map<String, dynamic> json) =
      _$ExportJobImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  ExportType get type;
  @override
  ExportFormat get format;
  @override
  ExportStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get downloadUrl;
  @override
  String? get fileName;
  @override
  int? get fileSize;
  @override
  int? get recordCount;
  @override
  String? get error;
  @override
  double? get progress;
  @override
  ExportFilters? get filters;
  @override
  ExportOptions? get options;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ExportJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportJobImplCopyWith<_$ExportJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExportFilters _$ExportFiltersFromJson(Map<String, dynamic> json) {
  return _ExportFilters.fromJson(json);
}

/// @nodoc
mixin _$ExportFilters {
  DateTime? get dateFrom => throw _privateConstructorUsedError;
  DateTime? get dateTo => throw _privateConstructorUsedError;
  List<String>? get userIds => throw _privateConstructorUsedError;
  List<String>? get roles => throw _privateConstructorUsedError;
  List<String>? get statuses => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customFilters => throw _privateConstructorUsedError;

  /// Serializes this ExportFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExportFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportFiltersCopyWith<ExportFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportFiltersCopyWith<$Res> {
  factory $ExportFiltersCopyWith(
    ExportFilters value,
    $Res Function(ExportFilters) then,
  ) = _$ExportFiltersCopyWithImpl<$Res, ExportFilters>;
  @useResult
  $Res call({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<String>? userIds,
    List<String>? roles,
    List<String>? statuses,
    String? searchQuery,
    Map<String, dynamic>? customFilters,
  });
}

/// @nodoc
class _$ExportFiltersCopyWithImpl<$Res, $Val extends ExportFilters>
    implements $ExportFiltersCopyWith<$Res> {
  _$ExportFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? userIds = freezed,
    Object? roles = freezed,
    Object? statuses = freezed,
    Object? searchQuery = freezed,
    Object? customFilters = freezed,
  }) {
    return _then(
      _value.copyWith(
            dateFrom: freezed == dateFrom
                ? _value.dateFrom
                : dateFrom // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateTo: freezed == dateTo
                ? _value.dateTo
                : dateTo // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            userIds: freezed == userIds
                ? _value.userIds
                : userIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            roles: freezed == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            statuses: freezed == statuses
                ? _value.statuses
                : statuses // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            searchQuery: freezed == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String?,
            customFilters: freezed == customFilters
                ? _value.customFilters
                : customFilters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExportFiltersImplCopyWith<$Res>
    implements $ExportFiltersCopyWith<$Res> {
  factory _$$ExportFiltersImplCopyWith(
    _$ExportFiltersImpl value,
    $Res Function(_$ExportFiltersImpl) then,
  ) = __$$ExportFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<String>? userIds,
    List<String>? roles,
    List<String>? statuses,
    String? searchQuery,
    Map<String, dynamic>? customFilters,
  });
}

/// @nodoc
class __$$ExportFiltersImplCopyWithImpl<$Res>
    extends _$ExportFiltersCopyWithImpl<$Res, _$ExportFiltersImpl>
    implements _$$ExportFiltersImplCopyWith<$Res> {
  __$$ExportFiltersImplCopyWithImpl(
    _$ExportFiltersImpl _value,
    $Res Function(_$ExportFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? userIds = freezed,
    Object? roles = freezed,
    Object? statuses = freezed,
    Object? searchQuery = freezed,
    Object? customFilters = freezed,
  }) {
    return _then(
      _$ExportFiltersImpl(
        dateFrom: freezed == dateFrom
            ? _value.dateFrom
            : dateFrom // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateTo: freezed == dateTo
            ? _value.dateTo
            : dateTo // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        userIds: freezed == userIds
            ? _value._userIds
            : userIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        roles: freezed == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        statuses: freezed == statuses
            ? _value._statuses
            : statuses // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        searchQuery: freezed == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String?,
        customFilters: freezed == customFilters
            ? _value._customFilters
            : customFilters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExportFiltersImpl implements _ExportFilters {
  const _$ExportFiltersImpl({
    this.dateFrom,
    this.dateTo,
    final List<String>? userIds,
    final List<String>? roles,
    final List<String>? statuses,
    this.searchQuery,
    final Map<String, dynamic>? customFilters,
  }) : _userIds = userIds,
       _roles = roles,
       _statuses = statuses,
       _customFilters = customFilters;

  factory _$ExportFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExportFiltersImplFromJson(json);

  @override
  final DateTime? dateFrom;
  @override
  final DateTime? dateTo;
  final List<String>? _userIds;
  @override
  List<String>? get userIds {
    final value = _userIds;
    if (value == null) return null;
    if (_userIds is EqualUnmodifiableListView) return _userIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _roles;
  @override
  List<String>? get roles {
    final value = _roles;
    if (value == null) return null;
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _statuses;
  @override
  List<String>? get statuses {
    final value = _statuses;
    if (value == null) return null;
    if (_statuses is EqualUnmodifiableListView) return _statuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? searchQuery;
  final Map<String, dynamic>? _customFilters;
  @override
  Map<String, dynamic>? get customFilters {
    final value = _customFilters;
    if (value == null) return null;
    if (_customFilters is EqualUnmodifiableMapView) return _customFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ExportFilters(dateFrom: $dateFrom, dateTo: $dateTo, userIds: $userIds, roles: $roles, statuses: $statuses, searchQuery: $searchQuery, customFilters: $customFilters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportFiltersImpl &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            const DeepCollectionEquality().equals(other._userIds, _userIds) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            const DeepCollectionEquality().equals(other._statuses, _statuses) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality().equals(
              other._customFilters,
              _customFilters,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dateFrom,
    dateTo,
    const DeepCollectionEquality().hash(_userIds),
    const DeepCollectionEquality().hash(_roles),
    const DeepCollectionEquality().hash(_statuses),
    searchQuery,
    const DeepCollectionEquality().hash(_customFilters),
  );

  /// Create a copy of ExportFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportFiltersImplCopyWith<_$ExportFiltersImpl> get copyWith =>
      __$$ExportFiltersImplCopyWithImpl<_$ExportFiltersImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExportFiltersImplToJson(this);
  }
}

abstract class _ExportFilters implements ExportFilters {
  const factory _ExportFilters({
    final DateTime? dateFrom,
    final DateTime? dateTo,
    final List<String>? userIds,
    final List<String>? roles,
    final List<String>? statuses,
    final String? searchQuery,
    final Map<String, dynamic>? customFilters,
  }) = _$ExportFiltersImpl;

  factory _ExportFilters.fromJson(Map<String, dynamic> json) =
      _$ExportFiltersImpl.fromJson;

  @override
  DateTime? get dateFrom;
  @override
  DateTime? get dateTo;
  @override
  List<String>? get userIds;
  @override
  List<String>? get roles;
  @override
  List<String>? get statuses;
  @override
  String? get searchQuery;
  @override
  Map<String, dynamic>? get customFilters;

  /// Create a copy of ExportFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportFiltersImplCopyWith<_$ExportFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExportOptions _$ExportOptionsFromJson(Map<String, dynamic> json) {
  return _ExportOptions.fromJson(json);
}

/// @nodoc
mixin _$ExportOptions {
  bool get includeHeaders => throw _privateConstructorUsedError;
  bool get compressFile => throw _privateConstructorUsedError;
  bool get encryptFile => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  int get batchSize => throw _privateConstructorUsedError;
  String get csvDelimiter => throw _privateConstructorUsedError;
  String get csvQuoteChar => throw _privateConstructorUsedError;
  bool get includeSoftDeleted => throw _privateConstructorUsedError;
  bool get includeSystemFields => throw _privateConstructorUsedError;
  Map<String, dynamic>? get formatOptions => throw _privateConstructorUsedError;

  /// Serializes this ExportOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExportOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportOptionsCopyWith<ExportOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportOptionsCopyWith<$Res> {
  factory $ExportOptionsCopyWith(
    ExportOptions value,
    $Res Function(ExportOptions) then,
  ) = _$ExportOptionsCopyWithImpl<$Res, ExportOptions>;
  @useResult
  $Res call({
    bool includeHeaders,
    bool compressFile,
    bool encryptFile,
    String? password,
    int batchSize,
    String csvDelimiter,
    String csvQuoteChar,
    bool includeSoftDeleted,
    bool includeSystemFields,
    Map<String, dynamic>? formatOptions,
  });
}

/// @nodoc
class _$ExportOptionsCopyWithImpl<$Res, $Val extends ExportOptions>
    implements $ExportOptionsCopyWith<$Res> {
  _$ExportOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? includeHeaders = null,
    Object? compressFile = null,
    Object? encryptFile = null,
    Object? password = freezed,
    Object? batchSize = null,
    Object? csvDelimiter = null,
    Object? csvQuoteChar = null,
    Object? includeSoftDeleted = null,
    Object? includeSystemFields = null,
    Object? formatOptions = freezed,
  }) {
    return _then(
      _value.copyWith(
            includeHeaders: null == includeHeaders
                ? _value.includeHeaders
                : includeHeaders // ignore: cast_nullable_to_non_nullable
                      as bool,
            compressFile: null == compressFile
                ? _value.compressFile
                : compressFile // ignore: cast_nullable_to_non_nullable
                      as bool,
            encryptFile: null == encryptFile
                ? _value.encryptFile
                : encryptFile // ignore: cast_nullable_to_non_nullable
                      as bool,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            batchSize: null == batchSize
                ? _value.batchSize
                : batchSize // ignore: cast_nullable_to_non_nullable
                      as int,
            csvDelimiter: null == csvDelimiter
                ? _value.csvDelimiter
                : csvDelimiter // ignore: cast_nullable_to_non_nullable
                      as String,
            csvQuoteChar: null == csvQuoteChar
                ? _value.csvQuoteChar
                : csvQuoteChar // ignore: cast_nullable_to_non_nullable
                      as String,
            includeSoftDeleted: null == includeSoftDeleted
                ? _value.includeSoftDeleted
                : includeSoftDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeSystemFields: null == includeSystemFields
                ? _value.includeSystemFields
                : includeSystemFields // ignore: cast_nullable_to_non_nullable
                      as bool,
            formatOptions: freezed == formatOptions
                ? _value.formatOptions
                : formatOptions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExportOptionsImplCopyWith<$Res>
    implements $ExportOptionsCopyWith<$Res> {
  factory _$$ExportOptionsImplCopyWith(
    _$ExportOptionsImpl value,
    $Res Function(_$ExportOptionsImpl) then,
  ) = __$$ExportOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool includeHeaders,
    bool compressFile,
    bool encryptFile,
    String? password,
    int batchSize,
    String csvDelimiter,
    String csvQuoteChar,
    bool includeSoftDeleted,
    bool includeSystemFields,
    Map<String, dynamic>? formatOptions,
  });
}

/// @nodoc
class __$$ExportOptionsImplCopyWithImpl<$Res>
    extends _$ExportOptionsCopyWithImpl<$Res, _$ExportOptionsImpl>
    implements _$$ExportOptionsImplCopyWith<$Res> {
  __$$ExportOptionsImplCopyWithImpl(
    _$ExportOptionsImpl _value,
    $Res Function(_$ExportOptionsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? includeHeaders = null,
    Object? compressFile = null,
    Object? encryptFile = null,
    Object? password = freezed,
    Object? batchSize = null,
    Object? csvDelimiter = null,
    Object? csvQuoteChar = null,
    Object? includeSoftDeleted = null,
    Object? includeSystemFields = null,
    Object? formatOptions = freezed,
  }) {
    return _then(
      _$ExportOptionsImpl(
        includeHeaders: null == includeHeaders
            ? _value.includeHeaders
            : includeHeaders // ignore: cast_nullable_to_non_nullable
                  as bool,
        compressFile: null == compressFile
            ? _value.compressFile
            : compressFile // ignore: cast_nullable_to_non_nullable
                  as bool,
        encryptFile: null == encryptFile
            ? _value.encryptFile
            : encryptFile // ignore: cast_nullable_to_non_nullable
                  as bool,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        batchSize: null == batchSize
            ? _value.batchSize
            : batchSize // ignore: cast_nullable_to_non_nullable
                  as int,
        csvDelimiter: null == csvDelimiter
            ? _value.csvDelimiter
            : csvDelimiter // ignore: cast_nullable_to_non_nullable
                  as String,
        csvQuoteChar: null == csvQuoteChar
            ? _value.csvQuoteChar
            : csvQuoteChar // ignore: cast_nullable_to_non_nullable
                  as String,
        includeSoftDeleted: null == includeSoftDeleted
            ? _value.includeSoftDeleted
            : includeSoftDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeSystemFields: null == includeSystemFields
            ? _value.includeSystemFields
            : includeSystemFields // ignore: cast_nullable_to_non_nullable
                  as bool,
        formatOptions: freezed == formatOptions
            ? _value._formatOptions
            : formatOptions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExportOptionsImpl implements _ExportOptions {
  const _$ExportOptionsImpl({
    this.includeHeaders = true,
    this.compressFile = false,
    this.encryptFile = false,
    this.password,
    this.batchSize = 10000,
    this.csvDelimiter = ',',
    this.csvQuoteChar = '"',
    this.includeSoftDeleted = true,
    this.includeSystemFields = false,
    final Map<String, dynamic>? formatOptions,
  }) : _formatOptions = formatOptions;

  factory _$ExportOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExportOptionsImplFromJson(json);

  @override
  @JsonKey()
  final bool includeHeaders;
  @override
  @JsonKey()
  final bool compressFile;
  @override
  @JsonKey()
  final bool encryptFile;
  @override
  final String? password;
  @override
  @JsonKey()
  final int batchSize;
  @override
  @JsonKey()
  final String csvDelimiter;
  @override
  @JsonKey()
  final String csvQuoteChar;
  @override
  @JsonKey()
  final bool includeSoftDeleted;
  @override
  @JsonKey()
  final bool includeSystemFields;
  final Map<String, dynamic>? _formatOptions;
  @override
  Map<String, dynamic>? get formatOptions {
    final value = _formatOptions;
    if (value == null) return null;
    if (_formatOptions is EqualUnmodifiableMapView) return _formatOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ExportOptions(includeHeaders: $includeHeaders, compressFile: $compressFile, encryptFile: $encryptFile, password: $password, batchSize: $batchSize, csvDelimiter: $csvDelimiter, csvQuoteChar: $csvQuoteChar, includeSoftDeleted: $includeSoftDeleted, includeSystemFields: $includeSystemFields, formatOptions: $formatOptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportOptionsImpl &&
            (identical(other.includeHeaders, includeHeaders) ||
                other.includeHeaders == includeHeaders) &&
            (identical(other.compressFile, compressFile) ||
                other.compressFile == compressFile) &&
            (identical(other.encryptFile, encryptFile) ||
                other.encryptFile == encryptFile) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.batchSize, batchSize) ||
                other.batchSize == batchSize) &&
            (identical(other.csvDelimiter, csvDelimiter) ||
                other.csvDelimiter == csvDelimiter) &&
            (identical(other.csvQuoteChar, csvQuoteChar) ||
                other.csvQuoteChar == csvQuoteChar) &&
            (identical(other.includeSoftDeleted, includeSoftDeleted) ||
                other.includeSoftDeleted == includeSoftDeleted) &&
            (identical(other.includeSystemFields, includeSystemFields) ||
                other.includeSystemFields == includeSystemFields) &&
            const DeepCollectionEquality().equals(
              other._formatOptions,
              _formatOptions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    includeHeaders,
    compressFile,
    encryptFile,
    password,
    batchSize,
    csvDelimiter,
    csvQuoteChar,
    includeSoftDeleted,
    includeSystemFields,
    const DeepCollectionEquality().hash(_formatOptions),
  );

  /// Create a copy of ExportOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportOptionsImplCopyWith<_$ExportOptionsImpl> get copyWith =>
      __$$ExportOptionsImplCopyWithImpl<_$ExportOptionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExportOptionsImplToJson(this);
  }
}

abstract class _ExportOptions implements ExportOptions {
  const factory _ExportOptions({
    final bool includeHeaders,
    final bool compressFile,
    final bool encryptFile,
    final String? password,
    final int batchSize,
    final String csvDelimiter,
    final String csvQuoteChar,
    final bool includeSoftDeleted,
    final bool includeSystemFields,
    final Map<String, dynamic>? formatOptions,
  }) = _$ExportOptionsImpl;

  factory _ExportOptions.fromJson(Map<String, dynamic> json) =
      _$ExportOptionsImpl.fromJson;

  @override
  bool get includeHeaders;
  @override
  bool get compressFile;
  @override
  bool get encryptFile;
  @override
  String? get password;
  @override
  int get batchSize;
  @override
  String get csvDelimiter;
  @override
  String get csvQuoteChar;
  @override
  bool get includeSoftDeleted;
  @override
  bool get includeSystemFields;
  @override
  Map<String, dynamic>? get formatOptions;

  /// Create a copy of ExportOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportOptionsImplCopyWith<_$ExportOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExportJobList _$ExportJobListFromJson(Map<String, dynamic> json) {
  return _ExportJobList.fromJson(json);
}

/// @nodoc
mixin _$ExportJobList {
  List<ExportJob> get jobs => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrevious => throw _privateConstructorUsedError;

  /// Serializes this ExportJobList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExportJobList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportJobListCopyWith<ExportJobList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportJobListCopyWith<$Res> {
  factory $ExportJobListCopyWith(
    ExportJobList value,
    $Res Function(ExportJobList) then,
  ) = _$ExportJobListCopyWithImpl<$Res, ExportJobList>;
  @useResult
  $Res call({
    List<ExportJob> jobs,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class _$ExportJobListCopyWithImpl<$Res, $Val extends ExportJobList>
    implements $ExportJobListCopyWith<$Res> {
  _$ExportJobListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportJobList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobs = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _value.copyWith(
            jobs: null == jobs
                ? _value.jobs
                : jobs // ignore: cast_nullable_to_non_nullable
                      as List<ExportJob>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPrevious: null == hasPrevious
                ? _value.hasPrevious
                : hasPrevious // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExportJobListImplCopyWith<$Res>
    implements $ExportJobListCopyWith<$Res> {
  factory _$$ExportJobListImplCopyWith(
    _$ExportJobListImpl value,
    $Res Function(_$ExportJobListImpl) then,
  ) = __$$ExportJobListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ExportJob> jobs,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class __$$ExportJobListImplCopyWithImpl<$Res>
    extends _$ExportJobListCopyWithImpl<$Res, _$ExportJobListImpl>
    implements _$$ExportJobListImplCopyWith<$Res> {
  __$$ExportJobListImplCopyWithImpl(
    _$ExportJobListImpl _value,
    $Res Function(_$ExportJobListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportJobList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobs = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _$ExportJobListImpl(
        jobs: null == jobs
            ? _value._jobs
            : jobs // ignore: cast_nullable_to_non_nullable
                  as List<ExportJob>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPrevious: null == hasPrevious
            ? _value.hasPrevious
            : hasPrevious // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExportJobListImpl implements _ExportJobList {
  const _$ExportJobListImpl({
    required final List<ExportJob> jobs,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  }) : _jobs = jobs;

  factory _$ExportJobListImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExportJobListImplFromJson(json);

  final List<ExportJob> _jobs;
  @override
  List<ExportJob> get jobs {
    if (_jobs is EqualUnmodifiableListView) return _jobs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jobs);
  }

  @override
  final int total;
  @override
  final int page;
  @override
  final int limit;
  @override
  final bool hasNext;
  @override
  final bool hasPrevious;

  @override
  String toString() {
    return 'ExportJobList(jobs: $jobs, total: $total, page: $page, limit: $limit, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportJobListImpl &&
            const DeepCollectionEquality().equals(other._jobs, _jobs) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrevious, hasPrevious) ||
                other.hasPrevious == hasPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_jobs),
    total,
    page,
    limit,
    hasNext,
    hasPrevious,
  );

  /// Create a copy of ExportJobList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportJobListImplCopyWith<_$ExportJobListImpl> get copyWith =>
      __$$ExportJobListImplCopyWithImpl<_$ExportJobListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExportJobListImplToJson(this);
  }
}

abstract class _ExportJobList implements ExportJobList {
  const factory _ExportJobList({
    required final List<ExportJob> jobs,
    required final int total,
    required final int page,
    required final int limit,
    required final bool hasNext,
    required final bool hasPrevious,
  }) = _$ExportJobListImpl;

  factory _ExportJobList.fromJson(Map<String, dynamic> json) =
      _$ExportJobListImpl.fromJson;

  @override
  List<ExportJob> get jobs;
  @override
  int get total;
  @override
  int get page;
  @override
  int get limit;
  @override
  bool get hasNext;
  @override
  bool get hasPrevious;

  /// Create a copy of ExportJobList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportJobListImplCopyWith<_$ExportJobListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExportStats _$ExportStatsFromJson(Map<String, dynamic> json) {
  return _ExportStats.fromJson(json);
}

/// @nodoc
mixin _$ExportStats {
  int get totalJobs => throw _privateConstructorUsedError;
  int get completedJobs => throw _privateConstructorUsedError;
  int get failedJobs => throw _privateConstructorUsedError;
  int get runningJobs => throw _privateConstructorUsedError;
  Map<String, int> get jobsByType => throw _privateConstructorUsedError;
  Map<String, int> get jobsByFormat => throw _privateConstructorUsedError;
  List<ExportJob> get recentJobs => throw _privateConstructorUsedError;
  double get averageExportTime => throw _privateConstructorUsedError;
  int get totalExportedRecords => throw _privateConstructorUsedError;

  /// Serializes this ExportStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExportStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportStatsCopyWith<ExportStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportStatsCopyWith<$Res> {
  factory $ExportStatsCopyWith(
    ExportStats value,
    $Res Function(ExportStats) then,
  ) = _$ExportStatsCopyWithImpl<$Res, ExportStats>;
  @useResult
  $Res call({
    int totalJobs,
    int completedJobs,
    int failedJobs,
    int runningJobs,
    Map<String, int> jobsByType,
    Map<String, int> jobsByFormat,
    List<ExportJob> recentJobs,
    double averageExportTime,
    int totalExportedRecords,
  });
}

/// @nodoc
class _$ExportStatsCopyWithImpl<$Res, $Val extends ExportStats>
    implements $ExportStatsCopyWith<$Res> {
  _$ExportStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalJobs = null,
    Object? completedJobs = null,
    Object? failedJobs = null,
    Object? runningJobs = null,
    Object? jobsByType = null,
    Object? jobsByFormat = null,
    Object? recentJobs = null,
    Object? averageExportTime = null,
    Object? totalExportedRecords = null,
  }) {
    return _then(
      _value.copyWith(
            totalJobs: null == totalJobs
                ? _value.totalJobs
                : totalJobs // ignore: cast_nullable_to_non_nullable
                      as int,
            completedJobs: null == completedJobs
                ? _value.completedJobs
                : completedJobs // ignore: cast_nullable_to_non_nullable
                      as int,
            failedJobs: null == failedJobs
                ? _value.failedJobs
                : failedJobs // ignore: cast_nullable_to_non_nullable
                      as int,
            runningJobs: null == runningJobs
                ? _value.runningJobs
                : runningJobs // ignore: cast_nullable_to_non_nullable
                      as int,
            jobsByType: null == jobsByType
                ? _value.jobsByType
                : jobsByType // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            jobsByFormat: null == jobsByFormat
                ? _value.jobsByFormat
                : jobsByFormat // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            recentJobs: null == recentJobs
                ? _value.recentJobs
                : recentJobs // ignore: cast_nullable_to_non_nullable
                      as List<ExportJob>,
            averageExportTime: null == averageExportTime
                ? _value.averageExportTime
                : averageExportTime // ignore: cast_nullable_to_non_nullable
                      as double,
            totalExportedRecords: null == totalExportedRecords
                ? _value.totalExportedRecords
                : totalExportedRecords // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExportStatsImplCopyWith<$Res>
    implements $ExportStatsCopyWith<$Res> {
  factory _$$ExportStatsImplCopyWith(
    _$ExportStatsImpl value,
    $Res Function(_$ExportStatsImpl) then,
  ) = __$$ExportStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalJobs,
    int completedJobs,
    int failedJobs,
    int runningJobs,
    Map<String, int> jobsByType,
    Map<String, int> jobsByFormat,
    List<ExportJob> recentJobs,
    double averageExportTime,
    int totalExportedRecords,
  });
}

/// @nodoc
class __$$ExportStatsImplCopyWithImpl<$Res>
    extends _$ExportStatsCopyWithImpl<$Res, _$ExportStatsImpl>
    implements _$$ExportStatsImplCopyWith<$Res> {
  __$$ExportStatsImplCopyWithImpl(
    _$ExportStatsImpl _value,
    $Res Function(_$ExportStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalJobs = null,
    Object? completedJobs = null,
    Object? failedJobs = null,
    Object? runningJobs = null,
    Object? jobsByType = null,
    Object? jobsByFormat = null,
    Object? recentJobs = null,
    Object? averageExportTime = null,
    Object? totalExportedRecords = null,
  }) {
    return _then(
      _$ExportStatsImpl(
        totalJobs: null == totalJobs
            ? _value.totalJobs
            : totalJobs // ignore: cast_nullable_to_non_nullable
                  as int,
        completedJobs: null == completedJobs
            ? _value.completedJobs
            : completedJobs // ignore: cast_nullable_to_non_nullable
                  as int,
        failedJobs: null == failedJobs
            ? _value.failedJobs
            : failedJobs // ignore: cast_nullable_to_non_nullable
                  as int,
        runningJobs: null == runningJobs
            ? _value.runningJobs
            : runningJobs // ignore: cast_nullable_to_non_nullable
                  as int,
        jobsByType: null == jobsByType
            ? _value._jobsByType
            : jobsByType // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        jobsByFormat: null == jobsByFormat
            ? _value._jobsByFormat
            : jobsByFormat // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        recentJobs: null == recentJobs
            ? _value._recentJobs
            : recentJobs // ignore: cast_nullable_to_non_nullable
                  as List<ExportJob>,
        averageExportTime: null == averageExportTime
            ? _value.averageExportTime
            : averageExportTime // ignore: cast_nullable_to_non_nullable
                  as double,
        totalExportedRecords: null == totalExportedRecords
            ? _value.totalExportedRecords
            : totalExportedRecords // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExportStatsImpl implements _ExportStats {
  const _$ExportStatsImpl({
    required this.totalJobs,
    required this.completedJobs,
    required this.failedJobs,
    required this.runningJobs,
    required final Map<String, int> jobsByType,
    required final Map<String, int> jobsByFormat,
    required final List<ExportJob> recentJobs,
    required this.averageExportTime,
    required this.totalExportedRecords,
  }) : _jobsByType = jobsByType,
       _jobsByFormat = jobsByFormat,
       _recentJobs = recentJobs;

  factory _$ExportStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExportStatsImplFromJson(json);

  @override
  final int totalJobs;
  @override
  final int completedJobs;
  @override
  final int failedJobs;
  @override
  final int runningJobs;
  final Map<String, int> _jobsByType;
  @override
  Map<String, int> get jobsByType {
    if (_jobsByType is EqualUnmodifiableMapView) return _jobsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_jobsByType);
  }

  final Map<String, int> _jobsByFormat;
  @override
  Map<String, int> get jobsByFormat {
    if (_jobsByFormat is EqualUnmodifiableMapView) return _jobsByFormat;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_jobsByFormat);
  }

  final List<ExportJob> _recentJobs;
  @override
  List<ExportJob> get recentJobs {
    if (_recentJobs is EqualUnmodifiableListView) return _recentJobs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentJobs);
  }

  @override
  final double averageExportTime;
  @override
  final int totalExportedRecords;

  @override
  String toString() {
    return 'ExportStats(totalJobs: $totalJobs, completedJobs: $completedJobs, failedJobs: $failedJobs, runningJobs: $runningJobs, jobsByType: $jobsByType, jobsByFormat: $jobsByFormat, recentJobs: $recentJobs, averageExportTime: $averageExportTime, totalExportedRecords: $totalExportedRecords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportStatsImpl &&
            (identical(other.totalJobs, totalJobs) ||
                other.totalJobs == totalJobs) &&
            (identical(other.completedJobs, completedJobs) ||
                other.completedJobs == completedJobs) &&
            (identical(other.failedJobs, failedJobs) ||
                other.failedJobs == failedJobs) &&
            (identical(other.runningJobs, runningJobs) ||
                other.runningJobs == runningJobs) &&
            const DeepCollectionEquality().equals(
              other._jobsByType,
              _jobsByType,
            ) &&
            const DeepCollectionEquality().equals(
              other._jobsByFormat,
              _jobsByFormat,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentJobs,
              _recentJobs,
            ) &&
            (identical(other.averageExportTime, averageExportTime) ||
                other.averageExportTime == averageExportTime) &&
            (identical(other.totalExportedRecords, totalExportedRecords) ||
                other.totalExportedRecords == totalExportedRecords));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalJobs,
    completedJobs,
    failedJobs,
    runningJobs,
    const DeepCollectionEquality().hash(_jobsByType),
    const DeepCollectionEquality().hash(_jobsByFormat),
    const DeepCollectionEquality().hash(_recentJobs),
    averageExportTime,
    totalExportedRecords,
  );

  /// Create a copy of ExportStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportStatsImplCopyWith<_$ExportStatsImpl> get copyWith =>
      __$$ExportStatsImplCopyWithImpl<_$ExportStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExportStatsImplToJson(this);
  }
}

abstract class _ExportStats implements ExportStats {
  const factory _ExportStats({
    required final int totalJobs,
    required final int completedJobs,
    required final int failedJobs,
    required final int runningJobs,
    required final Map<String, int> jobsByType,
    required final Map<String, int> jobsByFormat,
    required final List<ExportJob> recentJobs,
    required final double averageExportTime,
    required final int totalExportedRecords,
  }) = _$ExportStatsImpl;

  factory _ExportStats.fromJson(Map<String, dynamic> json) =
      _$ExportStatsImpl.fromJson;

  @override
  int get totalJobs;
  @override
  int get completedJobs;
  @override
  int get failedJobs;
  @override
  int get runningJobs;
  @override
  Map<String, int> get jobsByType;
  @override
  Map<String, int> get jobsByFormat;
  @override
  List<ExportJob> get recentJobs;
  @override
  double get averageExportTime;
  @override
  int get totalExportedRecords;

  /// Create a copy of ExportStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportStatsImplCopyWith<_$ExportStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackupRequest _$BackupRequestFromJson(Map<String, dynamic> json) {
  return _BackupRequest.fromJson(json);
}

/// @nodoc
mixin _$BackupRequest {
  BackupType get type => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  BackupOptions? get options => throw _privateConstructorUsedError;
  List<String>? get includedTables => throw _privateConstructorUsedError;
  List<String>? get excludedTables => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this BackupRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupRequestCopyWith<BackupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupRequestCopyWith<$Res> {
  factory $BackupRequestCopyWith(
    BackupRequest value,
    $Res Function(BackupRequest) then,
  ) = _$BackupRequestCopyWithImpl<$Res, BackupRequest>;
  @useResult
  $Res call({
    BackupType type,
    String name,
    String? description,
    BackupOptions? options,
    List<String>? includedTables,
    List<String>? excludedTables,
    Map<String, dynamic>? metadata,
  });

  $BackupOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class _$BackupRequestCopyWithImpl<$Res, $Val extends BackupRequest>
    implements $BackupRequestCopyWith<$Res> {
  _$BackupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = null,
    Object? description = freezed,
    Object? options = freezed,
    Object? includedTables = freezed,
    Object? excludedTables = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as BackupType,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as BackupOptions?,
            includedTables: freezed == includedTables
                ? _value.includedTables
                : includedTables // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            excludedTables: freezed == excludedTables
                ? _value.excludedTables
                : excludedTables // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of BackupRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BackupOptionsCopyWith<$Res>? get options {
    if (_value.options == null) {
      return null;
    }

    return $BackupOptionsCopyWith<$Res>(_value.options!, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BackupRequestImplCopyWith<$Res>
    implements $BackupRequestCopyWith<$Res> {
  factory _$$BackupRequestImplCopyWith(
    _$BackupRequestImpl value,
    $Res Function(_$BackupRequestImpl) then,
  ) = __$$BackupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BackupType type,
    String name,
    String? description,
    BackupOptions? options,
    List<String>? includedTables,
    List<String>? excludedTables,
    Map<String, dynamic>? metadata,
  });

  @override
  $BackupOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class __$$BackupRequestImplCopyWithImpl<$Res>
    extends _$BackupRequestCopyWithImpl<$Res, _$BackupRequestImpl>
    implements _$$BackupRequestImplCopyWith<$Res> {
  __$$BackupRequestImplCopyWithImpl(
    _$BackupRequestImpl _value,
    $Res Function(_$BackupRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = null,
    Object? description = freezed,
    Object? options = freezed,
    Object? includedTables = freezed,
    Object? excludedTables = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$BackupRequestImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as BackupType,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        options: freezed == options
            ? _value.options
            : options // ignore: cast_nullable_to_non_nullable
                  as BackupOptions?,
        includedTables: freezed == includedTables
            ? _value._includedTables
            : includedTables // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        excludedTables: freezed == excludedTables
            ? _value._excludedTables
            : excludedTables // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
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
class _$BackupRequestImpl implements _BackupRequest {
  const _$BackupRequestImpl({
    required this.type,
    required this.name,
    this.description,
    this.options,
    final List<String>? includedTables,
    final List<String>? excludedTables,
    final Map<String, dynamic>? metadata,
  }) : _includedTables = includedTables,
       _excludedTables = excludedTables,
       _metadata = metadata;

  factory _$BackupRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupRequestImplFromJson(json);

  @override
  final BackupType type;
  @override
  final String name;
  @override
  final String? description;
  @override
  final BackupOptions? options;
  final List<String>? _includedTables;
  @override
  List<String>? get includedTables {
    final value = _includedTables;
    if (value == null) return null;
    if (_includedTables is EqualUnmodifiableListView) return _includedTables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _excludedTables;
  @override
  List<String>? get excludedTables {
    final value = _excludedTables;
    if (value == null) return null;
    if (_excludedTables is EqualUnmodifiableListView) return _excludedTables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
    return 'BackupRequest(type: $type, name: $name, description: $description, options: $options, includedTables: $includedTables, excludedTables: $excludedTables, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupRequestImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.options, options) || other.options == options) &&
            const DeepCollectionEquality().equals(
              other._includedTables,
              _includedTables,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedTables,
              _excludedTables,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    name,
    description,
    options,
    const DeepCollectionEquality().hash(_includedTables),
    const DeepCollectionEquality().hash(_excludedTables),
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of BackupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupRequestImplCopyWith<_$BackupRequestImpl> get copyWith =>
      __$$BackupRequestImplCopyWithImpl<_$BackupRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupRequestImplToJson(this);
  }
}

abstract class _BackupRequest implements BackupRequest {
  const factory _BackupRequest({
    required final BackupType type,
    required final String name,
    final String? description,
    final BackupOptions? options,
    final List<String>? includedTables,
    final List<String>? excludedTables,
    final Map<String, dynamic>? metadata,
  }) = _$BackupRequestImpl;

  factory _BackupRequest.fromJson(Map<String, dynamic> json) =
      _$BackupRequestImpl.fromJson;

  @override
  BackupType get type;
  @override
  String get name;
  @override
  String? get description;
  @override
  BackupOptions? get options;
  @override
  List<String>? get includedTables;
  @override
  List<String>? get excludedTables;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of BackupRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupRequestImplCopyWith<_$BackupRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackupJob _$BackupJobFromJson(Map<String, dynamic> json) {
  return _BackupJob.fromJson(json);
}

/// @nodoc
mixin _$BackupJob {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  BackupType get type => throw _privateConstructorUsedError;
  BackupStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get downloadUrl => throw _privateConstructorUsedError;
  String? get fileName => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  String? get checksum => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  double? get progress => throw _privateConstructorUsedError;
  BackupOptions? get options => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this BackupJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupJobCopyWith<BackupJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupJobCopyWith<$Res> {
  factory $BackupJobCopyWith(BackupJob value, $Res Function(BackupJob) then) =
      _$BackupJobCopyWithImpl<$Res, BackupJob>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String? description,
    BackupType type,
    BackupStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? downloadUrl,
    String? fileName,
    int? fileSize,
    String? checksum,
    String? error,
    double? progress,
    BackupOptions? options,
    Map<String, dynamic>? metadata,
  });

  $BackupOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class _$BackupJobCopyWithImpl<$Res, $Val extends BackupJob>
    implements $BackupJobCopyWith<$Res> {
  _$BackupJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? downloadUrl = freezed,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? checksum = freezed,
    Object? error = freezed,
    Object? progress = freezed,
    Object? options = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as BackupType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BackupStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            downloadUrl: freezed == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileName: freezed == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            checksum: freezed == checksum
                ? _value.checksum
                : checksum // ignore: cast_nullable_to_non_nullable
                      as String?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            progress: freezed == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as BackupOptions?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of BackupJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BackupOptionsCopyWith<$Res>? get options {
    if (_value.options == null) {
      return null;
    }

    return $BackupOptionsCopyWith<$Res>(_value.options!, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BackupJobImplCopyWith<$Res>
    implements $BackupJobCopyWith<$Res> {
  factory _$$BackupJobImplCopyWith(
    _$BackupJobImpl value,
    $Res Function(_$BackupJobImpl) then,
  ) = __$$BackupJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String? description,
    BackupType type,
    BackupStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? downloadUrl,
    String? fileName,
    int? fileSize,
    String? checksum,
    String? error,
    double? progress,
    BackupOptions? options,
    Map<String, dynamic>? metadata,
  });

  @override
  $BackupOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class __$$BackupJobImplCopyWithImpl<$Res>
    extends _$BackupJobCopyWithImpl<$Res, _$BackupJobImpl>
    implements _$$BackupJobImplCopyWith<$Res> {
  __$$BackupJobImplCopyWithImpl(
    _$BackupJobImpl _value,
    $Res Function(_$BackupJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? downloadUrl = freezed,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? checksum = freezed,
    Object? error = freezed,
    Object? progress = freezed,
    Object? options = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$BackupJobImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as BackupType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BackupStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        downloadUrl: freezed == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: freezed == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        checksum: freezed == checksum
            ? _value.checksum
            : checksum // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double?,
        options: freezed == options
            ? _value.options
            : options // ignore: cast_nullable_to_non_nullable
                  as BackupOptions?,
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
class _$BackupJobImpl implements _BackupJob {
  const _$BackupJobImpl({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.downloadUrl,
    this.fileName,
    this.fileSize,
    this.checksum,
    this.error,
    this.progress,
    this.options,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$BackupJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupJobImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final BackupType type;
  @override
  final BackupStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? downloadUrl;
  @override
  final String? fileName;
  @override
  final int? fileSize;
  @override
  final String? checksum;
  @override
  final String? error;
  @override
  final double? progress;
  @override
  final BackupOptions? options;
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
    return 'BackupJob(id: $id, userId: $userId, name: $name, description: $description, type: $type, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt, downloadUrl: $downloadUrl, fileName: $fileName, fileSize: $fileSize, checksum: $checksum, error: $error, progress: $progress, options: $options, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.options, options) || other.options == options) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    name,
    description,
    type,
    status,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
    downloadUrl,
    fileName,
    fileSize,
    checksum,
    error,
    progress,
    options,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of BackupJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupJobImplCopyWith<_$BackupJobImpl> get copyWith =>
      __$$BackupJobImplCopyWithImpl<_$BackupJobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupJobImplToJson(this);
  }
}

abstract class _BackupJob implements BackupJob {
  const factory _BackupJob({
    required final String id,
    required final String userId,
    required final String name,
    final String? description,
    required final BackupType type,
    required final BackupStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final String? downloadUrl,
    final String? fileName,
    final int? fileSize,
    final String? checksum,
    final String? error,
    final double? progress,
    final BackupOptions? options,
    final Map<String, dynamic>? metadata,
  }) = _$BackupJobImpl;

  factory _BackupJob.fromJson(Map<String, dynamic> json) =
      _$BackupJobImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get description;
  @override
  BackupType get type;
  @override
  BackupStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get downloadUrl;
  @override
  String? get fileName;
  @override
  int? get fileSize;
  @override
  String? get checksum;
  @override
  String? get error;
  @override
  double? get progress;
  @override
  BackupOptions? get options;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of BackupJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupJobImplCopyWith<_$BackupJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackupOptions _$BackupOptionsFromJson(Map<String, dynamic> json) {
  return _BackupOptions.fromJson(json);
}

/// @nodoc
mixin _$BackupOptions {
  bool get compressBackup => throw _privateConstructorUsedError;
  bool get encryptBackup => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  bool get includeUserData => throw _privateConstructorUsedError;
  bool get includeSystemData => throw _privateConstructorUsedError;
  bool get includeAuditLogs => throw _privateConstructorUsedError;
  bool get includeSessions => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customOptions => throw _privateConstructorUsedError;

  /// Serializes this BackupOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupOptionsCopyWith<BackupOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupOptionsCopyWith<$Res> {
  factory $BackupOptionsCopyWith(
    BackupOptions value,
    $Res Function(BackupOptions) then,
  ) = _$BackupOptionsCopyWithImpl<$Res, BackupOptions>;
  @useResult
  $Res call({
    bool compressBackup,
    bool encryptBackup,
    String? password,
    bool includeUserData,
    bool includeSystemData,
    bool includeAuditLogs,
    bool includeSessions,
    Map<String, dynamic>? customOptions,
  });
}

/// @nodoc
class _$BackupOptionsCopyWithImpl<$Res, $Val extends BackupOptions>
    implements $BackupOptionsCopyWith<$Res> {
  _$BackupOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? compressBackup = null,
    Object? encryptBackup = null,
    Object? password = freezed,
    Object? includeUserData = null,
    Object? includeSystemData = null,
    Object? includeAuditLogs = null,
    Object? includeSessions = null,
    Object? customOptions = freezed,
  }) {
    return _then(
      _value.copyWith(
            compressBackup: null == compressBackup
                ? _value.compressBackup
                : compressBackup // ignore: cast_nullable_to_non_nullable
                      as bool,
            encryptBackup: null == encryptBackup
                ? _value.encryptBackup
                : encryptBackup // ignore: cast_nullable_to_non_nullable
                      as bool,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            includeUserData: null == includeUserData
                ? _value.includeUserData
                : includeUserData // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeSystemData: null == includeSystemData
                ? _value.includeSystemData
                : includeSystemData // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeAuditLogs: null == includeAuditLogs
                ? _value.includeAuditLogs
                : includeAuditLogs // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeSessions: null == includeSessions
                ? _value.includeSessions
                : includeSessions // ignore: cast_nullable_to_non_nullable
                      as bool,
            customOptions: freezed == customOptions
                ? _value.customOptions
                : customOptions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupOptionsImplCopyWith<$Res>
    implements $BackupOptionsCopyWith<$Res> {
  factory _$$BackupOptionsImplCopyWith(
    _$BackupOptionsImpl value,
    $Res Function(_$BackupOptionsImpl) then,
  ) = __$$BackupOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool compressBackup,
    bool encryptBackup,
    String? password,
    bool includeUserData,
    bool includeSystemData,
    bool includeAuditLogs,
    bool includeSessions,
    Map<String, dynamic>? customOptions,
  });
}

/// @nodoc
class __$$BackupOptionsImplCopyWithImpl<$Res>
    extends _$BackupOptionsCopyWithImpl<$Res, _$BackupOptionsImpl>
    implements _$$BackupOptionsImplCopyWith<$Res> {
  __$$BackupOptionsImplCopyWithImpl(
    _$BackupOptionsImpl _value,
    $Res Function(_$BackupOptionsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? compressBackup = null,
    Object? encryptBackup = null,
    Object? password = freezed,
    Object? includeUserData = null,
    Object? includeSystemData = null,
    Object? includeAuditLogs = null,
    Object? includeSessions = null,
    Object? customOptions = freezed,
  }) {
    return _then(
      _$BackupOptionsImpl(
        compressBackup: null == compressBackup
            ? _value.compressBackup
            : compressBackup // ignore: cast_nullable_to_non_nullable
                  as bool,
        encryptBackup: null == encryptBackup
            ? _value.encryptBackup
            : encryptBackup // ignore: cast_nullable_to_non_nullable
                  as bool,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        includeUserData: null == includeUserData
            ? _value.includeUserData
            : includeUserData // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeSystemData: null == includeSystemData
            ? _value.includeSystemData
            : includeSystemData // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeAuditLogs: null == includeAuditLogs
            ? _value.includeAuditLogs
            : includeAuditLogs // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeSessions: null == includeSessions
            ? _value.includeSessions
            : includeSessions // ignore: cast_nullable_to_non_nullable
                  as bool,
        customOptions: freezed == customOptions
            ? _value._customOptions
            : customOptions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupOptionsImpl implements _BackupOptions {
  const _$BackupOptionsImpl({
    this.compressBackup = true,
    this.encryptBackup = true,
    this.password,
    this.includeUserData = true,
    this.includeSystemData = true,
    this.includeAuditLogs = false,
    this.includeSessions = false,
    final Map<String, dynamic>? customOptions,
  }) : _customOptions = customOptions;

  factory _$BackupOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupOptionsImplFromJson(json);

  @override
  @JsonKey()
  final bool compressBackup;
  @override
  @JsonKey()
  final bool encryptBackup;
  @override
  final String? password;
  @override
  @JsonKey()
  final bool includeUserData;
  @override
  @JsonKey()
  final bool includeSystemData;
  @override
  @JsonKey()
  final bool includeAuditLogs;
  @override
  @JsonKey()
  final bool includeSessions;
  final Map<String, dynamic>? _customOptions;
  @override
  Map<String, dynamic>? get customOptions {
    final value = _customOptions;
    if (value == null) return null;
    if (_customOptions is EqualUnmodifiableMapView) return _customOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BackupOptions(compressBackup: $compressBackup, encryptBackup: $encryptBackup, password: $password, includeUserData: $includeUserData, includeSystemData: $includeSystemData, includeAuditLogs: $includeAuditLogs, includeSessions: $includeSessions, customOptions: $customOptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupOptionsImpl &&
            (identical(other.compressBackup, compressBackup) ||
                other.compressBackup == compressBackup) &&
            (identical(other.encryptBackup, encryptBackup) ||
                other.encryptBackup == encryptBackup) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.includeUserData, includeUserData) ||
                other.includeUserData == includeUserData) &&
            (identical(other.includeSystemData, includeSystemData) ||
                other.includeSystemData == includeSystemData) &&
            (identical(other.includeAuditLogs, includeAuditLogs) ||
                other.includeAuditLogs == includeAuditLogs) &&
            (identical(other.includeSessions, includeSessions) ||
                other.includeSessions == includeSessions) &&
            const DeepCollectionEquality().equals(
              other._customOptions,
              _customOptions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    compressBackup,
    encryptBackup,
    password,
    includeUserData,
    includeSystemData,
    includeAuditLogs,
    includeSessions,
    const DeepCollectionEquality().hash(_customOptions),
  );

  /// Create a copy of BackupOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupOptionsImplCopyWith<_$BackupOptionsImpl> get copyWith =>
      __$$BackupOptionsImplCopyWithImpl<_$BackupOptionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupOptionsImplToJson(this);
  }
}

abstract class _BackupOptions implements BackupOptions {
  const factory _BackupOptions({
    final bool compressBackup,
    final bool encryptBackup,
    final String? password,
    final bool includeUserData,
    final bool includeSystemData,
    final bool includeAuditLogs,
    final bool includeSessions,
    final Map<String, dynamic>? customOptions,
  }) = _$BackupOptionsImpl;

  factory _BackupOptions.fromJson(Map<String, dynamic> json) =
      _$BackupOptionsImpl.fromJson;

  @override
  bool get compressBackup;
  @override
  bool get encryptBackup;
  @override
  String? get password;
  @override
  bool get includeUserData;
  @override
  bool get includeSystemData;
  @override
  bool get includeAuditLogs;
  @override
  bool get includeSessions;
  @override
  Map<String, dynamic>? get customOptions;

  /// Create a copy of BackupOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupOptionsImplCopyWith<_$BackupOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RestoreRequest _$RestoreRequestFromJson(Map<String, dynamic> json) {
  return _RestoreRequest.fromJson(json);
}

/// @nodoc
mixin _$RestoreRequest {
  String get backupId => throw _privateConstructorUsedError;
  RestoreOptions get options => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this RestoreRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RestoreRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestoreRequestCopyWith<RestoreRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestoreRequestCopyWith<$Res> {
  factory $RestoreRequestCopyWith(
    RestoreRequest value,
    $Res Function(RestoreRequest) then,
  ) = _$RestoreRequestCopyWithImpl<$Res, RestoreRequest>;
  @useResult
  $Res call({
    String backupId,
    RestoreOptions options,
    Map<String, dynamic>? metadata,
  });

  $RestoreOptionsCopyWith<$Res> get options;
}

/// @nodoc
class _$RestoreRequestCopyWithImpl<$Res, $Val extends RestoreRequest>
    implements $RestoreRequestCopyWith<$Res> {
  _$RestoreRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestoreRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backupId = null,
    Object? options = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            backupId: null == backupId
                ? _value.backupId
                : backupId // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as RestoreOptions,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of RestoreRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestoreOptionsCopyWith<$Res> get options {
    return $RestoreOptionsCopyWith<$Res>(_value.options, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RestoreRequestImplCopyWith<$Res>
    implements $RestoreRequestCopyWith<$Res> {
  factory _$$RestoreRequestImplCopyWith(
    _$RestoreRequestImpl value,
    $Res Function(_$RestoreRequestImpl) then,
  ) = __$$RestoreRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String backupId,
    RestoreOptions options,
    Map<String, dynamic>? metadata,
  });

  @override
  $RestoreOptionsCopyWith<$Res> get options;
}

/// @nodoc
class __$$RestoreRequestImplCopyWithImpl<$Res>
    extends _$RestoreRequestCopyWithImpl<$Res, _$RestoreRequestImpl>
    implements _$$RestoreRequestImplCopyWith<$Res> {
  __$$RestoreRequestImplCopyWithImpl(
    _$RestoreRequestImpl _value,
    $Res Function(_$RestoreRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RestoreRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backupId = null,
    Object? options = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$RestoreRequestImpl(
        backupId: null == backupId
            ? _value.backupId
            : backupId // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value.options
            : options // ignore: cast_nullable_to_non_nullable
                  as RestoreOptions,
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
class _$RestoreRequestImpl implements _RestoreRequest {
  const _$RestoreRequestImpl({
    required this.backupId,
    required this.options,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$RestoreRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestoreRequestImplFromJson(json);

  @override
  final String backupId;
  @override
  final RestoreOptions options;
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
    return 'RestoreRequest(backupId: $backupId, options: $options, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreRequestImpl &&
            (identical(other.backupId, backupId) ||
                other.backupId == backupId) &&
            (identical(other.options, options) || other.options == options) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    backupId,
    options,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of RestoreRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreRequestImplCopyWith<_$RestoreRequestImpl> get copyWith =>
      __$$RestoreRequestImplCopyWithImpl<_$RestoreRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RestoreRequestImplToJson(this);
  }
}

abstract class _RestoreRequest implements RestoreRequest {
  const factory _RestoreRequest({
    required final String backupId,
    required final RestoreOptions options,
    final Map<String, dynamic>? metadata,
  }) = _$RestoreRequestImpl;

  factory _RestoreRequest.fromJson(Map<String, dynamic> json) =
      _$RestoreRequestImpl.fromJson;

  @override
  String get backupId;
  @override
  RestoreOptions get options;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of RestoreRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreRequestImplCopyWith<_$RestoreRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RestoreOptions _$RestoreOptionsFromJson(Map<String, dynamic> json) {
  return _RestoreOptions.fromJson(json);
}

/// @nodoc
mixin _$RestoreOptions {
  bool get overwriteExisting => throw _privateConstructorUsedError;
  bool get validateBeforeRestore => throw _privateConstructorUsedError;
  bool get createBackupBeforeRestore => throw _privateConstructorUsedError;
  List<String>? get includedTables => throw _privateConstructorUsedError;
  List<String>? get excludedTables => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customOptions => throw _privateConstructorUsedError;

  /// Serializes this RestoreOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RestoreOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestoreOptionsCopyWith<RestoreOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestoreOptionsCopyWith<$Res> {
  factory $RestoreOptionsCopyWith(
    RestoreOptions value,
    $Res Function(RestoreOptions) then,
  ) = _$RestoreOptionsCopyWithImpl<$Res, RestoreOptions>;
  @useResult
  $Res call({
    bool overwriteExisting,
    bool validateBeforeRestore,
    bool createBackupBeforeRestore,
    List<String>? includedTables,
    List<String>? excludedTables,
    Map<String, dynamic>? customOptions,
  });
}

/// @nodoc
class _$RestoreOptionsCopyWithImpl<$Res, $Val extends RestoreOptions>
    implements $RestoreOptionsCopyWith<$Res> {
  _$RestoreOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestoreOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overwriteExisting = null,
    Object? validateBeforeRestore = null,
    Object? createBackupBeforeRestore = null,
    Object? includedTables = freezed,
    Object? excludedTables = freezed,
    Object? customOptions = freezed,
  }) {
    return _then(
      _value.copyWith(
            overwriteExisting: null == overwriteExisting
                ? _value.overwriteExisting
                : overwriteExisting // ignore: cast_nullable_to_non_nullable
                      as bool,
            validateBeforeRestore: null == validateBeforeRestore
                ? _value.validateBeforeRestore
                : validateBeforeRestore // ignore: cast_nullable_to_non_nullable
                      as bool,
            createBackupBeforeRestore: null == createBackupBeforeRestore
                ? _value.createBackupBeforeRestore
                : createBackupBeforeRestore // ignore: cast_nullable_to_non_nullable
                      as bool,
            includedTables: freezed == includedTables
                ? _value.includedTables
                : includedTables // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            excludedTables: freezed == excludedTables
                ? _value.excludedTables
                : excludedTables // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            customOptions: freezed == customOptions
                ? _value.customOptions
                : customOptions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RestoreOptionsImplCopyWith<$Res>
    implements $RestoreOptionsCopyWith<$Res> {
  factory _$$RestoreOptionsImplCopyWith(
    _$RestoreOptionsImpl value,
    $Res Function(_$RestoreOptionsImpl) then,
  ) = __$$RestoreOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool overwriteExisting,
    bool validateBeforeRestore,
    bool createBackupBeforeRestore,
    List<String>? includedTables,
    List<String>? excludedTables,
    Map<String, dynamic>? customOptions,
  });
}

/// @nodoc
class __$$RestoreOptionsImplCopyWithImpl<$Res>
    extends _$RestoreOptionsCopyWithImpl<$Res, _$RestoreOptionsImpl>
    implements _$$RestoreOptionsImplCopyWith<$Res> {
  __$$RestoreOptionsImplCopyWithImpl(
    _$RestoreOptionsImpl _value,
    $Res Function(_$RestoreOptionsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RestoreOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overwriteExisting = null,
    Object? validateBeforeRestore = null,
    Object? createBackupBeforeRestore = null,
    Object? includedTables = freezed,
    Object? excludedTables = freezed,
    Object? customOptions = freezed,
  }) {
    return _then(
      _$RestoreOptionsImpl(
        overwriteExisting: null == overwriteExisting
            ? _value.overwriteExisting
            : overwriteExisting // ignore: cast_nullable_to_non_nullable
                  as bool,
        validateBeforeRestore: null == validateBeforeRestore
            ? _value.validateBeforeRestore
            : validateBeforeRestore // ignore: cast_nullable_to_non_nullable
                  as bool,
        createBackupBeforeRestore: null == createBackupBeforeRestore
            ? _value.createBackupBeforeRestore
            : createBackupBeforeRestore // ignore: cast_nullable_to_non_nullable
                  as bool,
        includedTables: freezed == includedTables
            ? _value._includedTables
            : includedTables // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        excludedTables: freezed == excludedTables
            ? _value._excludedTables
            : excludedTables // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        customOptions: freezed == customOptions
            ? _value._customOptions
            : customOptions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RestoreOptionsImpl implements _RestoreOptions {
  const _$RestoreOptionsImpl({
    this.overwriteExisting = false,
    this.validateBeforeRestore = true,
    this.createBackupBeforeRestore = true,
    final List<String>? includedTables,
    final List<String>? excludedTables,
    final Map<String, dynamic>? customOptions,
  }) : _includedTables = includedTables,
       _excludedTables = excludedTables,
       _customOptions = customOptions;

  factory _$RestoreOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestoreOptionsImplFromJson(json);

  @override
  @JsonKey()
  final bool overwriteExisting;
  @override
  @JsonKey()
  final bool validateBeforeRestore;
  @override
  @JsonKey()
  final bool createBackupBeforeRestore;
  final List<String>? _includedTables;
  @override
  List<String>? get includedTables {
    final value = _includedTables;
    if (value == null) return null;
    if (_includedTables is EqualUnmodifiableListView) return _includedTables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _excludedTables;
  @override
  List<String>? get excludedTables {
    final value = _excludedTables;
    if (value == null) return null;
    if (_excludedTables is EqualUnmodifiableListView) return _excludedTables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _customOptions;
  @override
  Map<String, dynamic>? get customOptions {
    final value = _customOptions;
    if (value == null) return null;
    if (_customOptions is EqualUnmodifiableMapView) return _customOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'RestoreOptions(overwriteExisting: $overwriteExisting, validateBeforeRestore: $validateBeforeRestore, createBackupBeforeRestore: $createBackupBeforeRestore, includedTables: $includedTables, excludedTables: $excludedTables, customOptions: $customOptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreOptionsImpl &&
            (identical(other.overwriteExisting, overwriteExisting) ||
                other.overwriteExisting == overwriteExisting) &&
            (identical(other.validateBeforeRestore, validateBeforeRestore) ||
                other.validateBeforeRestore == validateBeforeRestore) &&
            (identical(
                  other.createBackupBeforeRestore,
                  createBackupBeforeRestore,
                ) ||
                other.createBackupBeforeRestore == createBackupBeforeRestore) &&
            const DeepCollectionEquality().equals(
              other._includedTables,
              _includedTables,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedTables,
              _excludedTables,
            ) &&
            const DeepCollectionEquality().equals(
              other._customOptions,
              _customOptions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    overwriteExisting,
    validateBeforeRestore,
    createBackupBeforeRestore,
    const DeepCollectionEquality().hash(_includedTables),
    const DeepCollectionEquality().hash(_excludedTables),
    const DeepCollectionEquality().hash(_customOptions),
  );

  /// Create a copy of RestoreOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreOptionsImplCopyWith<_$RestoreOptionsImpl> get copyWith =>
      __$$RestoreOptionsImplCopyWithImpl<_$RestoreOptionsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RestoreOptionsImplToJson(this);
  }
}

abstract class _RestoreOptions implements RestoreOptions {
  const factory _RestoreOptions({
    final bool overwriteExisting,
    final bool validateBeforeRestore,
    final bool createBackupBeforeRestore,
    final List<String>? includedTables,
    final List<String>? excludedTables,
    final Map<String, dynamic>? customOptions,
  }) = _$RestoreOptionsImpl;

  factory _RestoreOptions.fromJson(Map<String, dynamic> json) =
      _$RestoreOptionsImpl.fromJson;

  @override
  bool get overwriteExisting;
  @override
  bool get validateBeforeRestore;
  @override
  bool get createBackupBeforeRestore;
  @override
  List<String>? get includedTables;
  @override
  List<String>? get excludedTables;
  @override
  Map<String, dynamic>? get customOptions;

  /// Create a copy of RestoreOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreOptionsImplCopyWith<_$RestoreOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RestoreJob _$RestoreJobFromJson(Map<String, dynamic> json) {
  return _RestoreJob.fromJson(json);
}

/// @nodoc
mixin _$RestoreJob {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get backupId => throw _privateConstructorUsedError;
  RestoreStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  double? get progress => throw _privateConstructorUsedError;
  RestoreOptions? get options => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this RestoreJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RestoreJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestoreJobCopyWith<RestoreJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestoreJobCopyWith<$Res> {
  factory $RestoreJobCopyWith(
    RestoreJob value,
    $Res Function(RestoreJob) then,
  ) = _$RestoreJobCopyWithImpl<$Res, RestoreJob>;
  @useResult
  $Res call({
    String id,
    String userId,
    String backupId,
    RestoreStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? error,
    double? progress,
    RestoreOptions? options,
    Map<String, dynamic>? metadata,
  });

  $RestoreOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class _$RestoreJobCopyWithImpl<$Res, $Val extends RestoreJob>
    implements $RestoreJobCopyWith<$Res> {
  _$RestoreJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestoreJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? backupId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? error = freezed,
    Object? progress = freezed,
    Object? options = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            backupId: null == backupId
                ? _value.backupId
                : backupId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RestoreStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            progress: freezed == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as RestoreOptions?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of RestoreJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestoreOptionsCopyWith<$Res>? get options {
    if (_value.options == null) {
      return null;
    }

    return $RestoreOptionsCopyWith<$Res>(_value.options!, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RestoreJobImplCopyWith<$Res>
    implements $RestoreJobCopyWith<$Res> {
  factory _$$RestoreJobImplCopyWith(
    _$RestoreJobImpl value,
    $Res Function(_$RestoreJobImpl) then,
  ) = __$$RestoreJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String backupId,
    RestoreStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? error,
    double? progress,
    RestoreOptions? options,
    Map<String, dynamic>? metadata,
  });

  @override
  $RestoreOptionsCopyWith<$Res>? get options;
}

/// @nodoc
class __$$RestoreJobImplCopyWithImpl<$Res>
    extends _$RestoreJobCopyWithImpl<$Res, _$RestoreJobImpl>
    implements _$$RestoreJobImplCopyWith<$Res> {
  __$$RestoreJobImplCopyWithImpl(
    _$RestoreJobImpl _value,
    $Res Function(_$RestoreJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RestoreJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? backupId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? error = freezed,
    Object? progress = freezed,
    Object? options = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$RestoreJobImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        backupId: null == backupId
            ? _value.backupId
            : backupId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RestoreStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double?,
        options: freezed == options
            ? _value.options
            : options // ignore: cast_nullable_to_non_nullable
                  as RestoreOptions?,
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
class _$RestoreJobImpl implements _RestoreJob {
  const _$RestoreJobImpl({
    required this.id,
    required this.userId,
    required this.backupId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.error,
    this.progress,
    this.options,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$RestoreJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestoreJobImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String backupId;
  @override
  final RestoreStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? error;
  @override
  final double? progress;
  @override
  final RestoreOptions? options;
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
    return 'RestoreJob(id: $id, userId: $userId, backupId: $backupId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt, error: $error, progress: $progress, options: $options, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.backupId, backupId) ||
                other.backupId == backupId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.options, options) || other.options == options) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    backupId,
    status,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
    error,
    progress,
    options,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of RestoreJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreJobImplCopyWith<_$RestoreJobImpl> get copyWith =>
      __$$RestoreJobImplCopyWithImpl<_$RestoreJobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestoreJobImplToJson(this);
  }
}

abstract class _RestoreJob implements RestoreJob {
  const factory _RestoreJob({
    required final String id,
    required final String userId,
    required final String backupId,
    required final RestoreStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final String? error,
    final double? progress,
    final RestoreOptions? options,
    final Map<String, dynamic>? metadata,
  }) = _$RestoreJobImpl;

  factory _RestoreJob.fromJson(Map<String, dynamic> json) =
      _$RestoreJobImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get backupId;
  @override
  RestoreStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get error;
  @override
  double? get progress;
  @override
  RestoreOptions? get options;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of RestoreJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreJobImplCopyWith<_$RestoreJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
