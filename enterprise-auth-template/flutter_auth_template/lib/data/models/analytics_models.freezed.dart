// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnalyticsDashboard _$AnalyticsDashboardFromJson(Map<String, dynamic> json) {
  return _AnalyticsDashboard.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsDashboard {
  UserAnalytics get userAnalytics => throw _privateConstructorUsedError;
  AuthenticationAnalytics get authenticationAnalytics =>
      throw _privateConstructorUsedError;
  SecurityAnalytics get securityAnalytics => throw _privateConstructorUsedError;
  ApiUsageAnalytics get apiUsageAnalytics => throw _privateConstructorUsedError;
  SystemPerformance get systemPerformance => throw _privateConstructorUsedError;

  /// Serializes this AnalyticsDashboard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsDashboardCopyWith<AnalyticsDashboard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsDashboardCopyWith<$Res> {
  factory $AnalyticsDashboardCopyWith(
    AnalyticsDashboard value,
    $Res Function(AnalyticsDashboard) then,
  ) = _$AnalyticsDashboardCopyWithImpl<$Res, AnalyticsDashboard>;
  @useResult
  $Res call({
    UserAnalytics userAnalytics,
    AuthenticationAnalytics authenticationAnalytics,
    SecurityAnalytics securityAnalytics,
    ApiUsageAnalytics apiUsageAnalytics,
    SystemPerformance systemPerformance,
  });

  $UserAnalyticsCopyWith<$Res> get userAnalytics;
  $AuthenticationAnalyticsCopyWith<$Res> get authenticationAnalytics;
  $SecurityAnalyticsCopyWith<$Res> get securityAnalytics;
  $ApiUsageAnalyticsCopyWith<$Res> get apiUsageAnalytics;
  $SystemPerformanceCopyWith<$Res> get systemPerformance;
}

/// @nodoc
class _$AnalyticsDashboardCopyWithImpl<$Res, $Val extends AnalyticsDashboard>
    implements $AnalyticsDashboardCopyWith<$Res> {
  _$AnalyticsDashboardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userAnalytics = null,
    Object? authenticationAnalytics = null,
    Object? securityAnalytics = null,
    Object? apiUsageAnalytics = null,
    Object? systemPerformance = null,
  }) {
    return _then(
      _value.copyWith(
            userAnalytics: null == userAnalytics
                ? _value.userAnalytics
                : userAnalytics // ignore: cast_nullable_to_non_nullable
                      as UserAnalytics,
            authenticationAnalytics: null == authenticationAnalytics
                ? _value.authenticationAnalytics
                : authenticationAnalytics // ignore: cast_nullable_to_non_nullable
                      as AuthenticationAnalytics,
            securityAnalytics: null == securityAnalytics
                ? _value.securityAnalytics
                : securityAnalytics // ignore: cast_nullable_to_non_nullable
                      as SecurityAnalytics,
            apiUsageAnalytics: null == apiUsageAnalytics
                ? _value.apiUsageAnalytics
                : apiUsageAnalytics // ignore: cast_nullable_to_non_nullable
                      as ApiUsageAnalytics,
            systemPerformance: null == systemPerformance
                ? _value.systemPerformance
                : systemPerformance // ignore: cast_nullable_to_non_nullable
                      as SystemPerformance,
          )
          as $Val,
    );
  }

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserAnalyticsCopyWith<$Res> get userAnalytics {
    return $UserAnalyticsCopyWith<$Res>(_value.userAnalytics, (value) {
      return _then(_value.copyWith(userAnalytics: value) as $Val);
    });
  }

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthenticationAnalyticsCopyWith<$Res> get authenticationAnalytics {
    return $AuthenticationAnalyticsCopyWith<$Res>(
      _value.authenticationAnalytics,
      (value) {
        return _then(_value.copyWith(authenticationAnalytics: value) as $Val);
      },
    );
  }

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SecurityAnalyticsCopyWith<$Res> get securityAnalytics {
    return $SecurityAnalyticsCopyWith<$Res>(_value.securityAnalytics, (value) {
      return _then(_value.copyWith(securityAnalytics: value) as $Val);
    });
  }

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ApiUsageAnalyticsCopyWith<$Res> get apiUsageAnalytics {
    return $ApiUsageAnalyticsCopyWith<$Res>(_value.apiUsageAnalytics, (value) {
      return _then(_value.copyWith(apiUsageAnalytics: value) as $Val);
    });
  }

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SystemPerformanceCopyWith<$Res> get systemPerformance {
    return $SystemPerformanceCopyWith<$Res>(_value.systemPerformance, (value) {
      return _then(_value.copyWith(systemPerformance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnalyticsDashboardImplCopyWith<$Res>
    implements $AnalyticsDashboardCopyWith<$Res> {
  factory _$$AnalyticsDashboardImplCopyWith(
    _$AnalyticsDashboardImpl value,
    $Res Function(_$AnalyticsDashboardImpl) then,
  ) = __$$AnalyticsDashboardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UserAnalytics userAnalytics,
    AuthenticationAnalytics authenticationAnalytics,
    SecurityAnalytics securityAnalytics,
    ApiUsageAnalytics apiUsageAnalytics,
    SystemPerformance systemPerformance,
  });

  @override
  $UserAnalyticsCopyWith<$Res> get userAnalytics;
  @override
  $AuthenticationAnalyticsCopyWith<$Res> get authenticationAnalytics;
  @override
  $SecurityAnalyticsCopyWith<$Res> get securityAnalytics;
  @override
  $ApiUsageAnalyticsCopyWith<$Res> get apiUsageAnalytics;
  @override
  $SystemPerformanceCopyWith<$Res> get systemPerformance;
}

/// @nodoc
class __$$AnalyticsDashboardImplCopyWithImpl<$Res>
    extends _$AnalyticsDashboardCopyWithImpl<$Res, _$AnalyticsDashboardImpl>
    implements _$$AnalyticsDashboardImplCopyWith<$Res> {
  __$$AnalyticsDashboardImplCopyWithImpl(
    _$AnalyticsDashboardImpl _value,
    $Res Function(_$AnalyticsDashboardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userAnalytics = null,
    Object? authenticationAnalytics = null,
    Object? securityAnalytics = null,
    Object? apiUsageAnalytics = null,
    Object? systemPerformance = null,
  }) {
    return _then(
      _$AnalyticsDashboardImpl(
        userAnalytics: null == userAnalytics
            ? _value.userAnalytics
            : userAnalytics // ignore: cast_nullable_to_non_nullable
                  as UserAnalytics,
        authenticationAnalytics: null == authenticationAnalytics
            ? _value.authenticationAnalytics
            : authenticationAnalytics // ignore: cast_nullable_to_non_nullable
                  as AuthenticationAnalytics,
        securityAnalytics: null == securityAnalytics
            ? _value.securityAnalytics
            : securityAnalytics // ignore: cast_nullable_to_non_nullable
                  as SecurityAnalytics,
        apiUsageAnalytics: null == apiUsageAnalytics
            ? _value.apiUsageAnalytics
            : apiUsageAnalytics // ignore: cast_nullable_to_non_nullable
                  as ApiUsageAnalytics,
        systemPerformance: null == systemPerformance
            ? _value.systemPerformance
            : systemPerformance // ignore: cast_nullable_to_non_nullable
                  as SystemPerformance,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsDashboardImpl implements _AnalyticsDashboard {
  const _$AnalyticsDashboardImpl({
    required this.userAnalytics,
    required this.authenticationAnalytics,
    required this.securityAnalytics,
    required this.apiUsageAnalytics,
    required this.systemPerformance,
  });

  factory _$AnalyticsDashboardImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsDashboardImplFromJson(json);

  @override
  final UserAnalytics userAnalytics;
  @override
  final AuthenticationAnalytics authenticationAnalytics;
  @override
  final SecurityAnalytics securityAnalytics;
  @override
  final ApiUsageAnalytics apiUsageAnalytics;
  @override
  final SystemPerformance systemPerformance;

  @override
  String toString() {
    return 'AnalyticsDashboard(userAnalytics: $userAnalytics, authenticationAnalytics: $authenticationAnalytics, securityAnalytics: $securityAnalytics, apiUsageAnalytics: $apiUsageAnalytics, systemPerformance: $systemPerformance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsDashboardImpl &&
            (identical(other.userAnalytics, userAnalytics) ||
                other.userAnalytics == userAnalytics) &&
            (identical(
                  other.authenticationAnalytics,
                  authenticationAnalytics,
                ) ||
                other.authenticationAnalytics == authenticationAnalytics) &&
            (identical(other.securityAnalytics, securityAnalytics) ||
                other.securityAnalytics == securityAnalytics) &&
            (identical(other.apiUsageAnalytics, apiUsageAnalytics) ||
                other.apiUsageAnalytics == apiUsageAnalytics) &&
            (identical(other.systemPerformance, systemPerformance) ||
                other.systemPerformance == systemPerformance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userAnalytics,
    authenticationAnalytics,
    securityAnalytics,
    apiUsageAnalytics,
    systemPerformance,
  );

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsDashboardImplCopyWith<_$AnalyticsDashboardImpl> get copyWith =>
      __$$AnalyticsDashboardImplCopyWithImpl<_$AnalyticsDashboardImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsDashboardImplToJson(this);
  }
}

abstract class _AnalyticsDashboard implements AnalyticsDashboard {
  const factory _AnalyticsDashboard({
    required final UserAnalytics userAnalytics,
    required final AuthenticationAnalytics authenticationAnalytics,
    required final SecurityAnalytics securityAnalytics,
    required final ApiUsageAnalytics apiUsageAnalytics,
    required final SystemPerformance systemPerformance,
  }) = _$AnalyticsDashboardImpl;

  factory _AnalyticsDashboard.fromJson(Map<String, dynamic> json) =
      _$AnalyticsDashboardImpl.fromJson;

  @override
  UserAnalytics get userAnalytics;
  @override
  AuthenticationAnalytics get authenticationAnalytics;
  @override
  SecurityAnalytics get securityAnalytics;
  @override
  ApiUsageAnalytics get apiUsageAnalytics;
  @override
  SystemPerformance get systemPerformance;

  /// Create a copy of AnalyticsDashboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsDashboardImplCopyWith<_$AnalyticsDashboardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserAnalytics _$UserAnalyticsFromJson(Map<String, dynamic> json) {
  return _UserAnalytics.fromJson(json);
}

/// @nodoc
mixin _$UserAnalytics {
  int get totalUsers => throw _privateConstructorUsedError;
  int get activeUsers => throw _privateConstructorUsedError;
  int get newUsersToday => throw _privateConstructorUsedError;
  int get newUsersThisWeek => throw _privateConstructorUsedError;
  int get newUsersThisMonth => throw _privateConstructorUsedError;
  double get userGrowthRate => throw _privateConstructorUsedError;
  Map<String, int> get usersByRole => throw _privateConstructorUsedError;
  Map<String, int> get usersByStatus => throw _privateConstructorUsedError;
  List<UserGrowthData> get userGrowthChart =>
      throw _privateConstructorUsedError;
  List<UserActivityData> get userActivityChart =>
      throw _privateConstructorUsedError;

  /// Serializes this UserAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserAnalyticsCopyWith<UserAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserAnalyticsCopyWith<$Res> {
  factory $UserAnalyticsCopyWith(
    UserAnalytics value,
    $Res Function(UserAnalytics) then,
  ) = _$UserAnalyticsCopyWithImpl<$Res, UserAnalytics>;
  @useResult
  $Res call({
    int totalUsers,
    int activeUsers,
    int newUsersToday,
    int newUsersThisWeek,
    int newUsersThisMonth,
    double userGrowthRate,
    Map<String, int> usersByRole,
    Map<String, int> usersByStatus,
    List<UserGrowthData> userGrowthChart,
    List<UserActivityData> userActivityChart,
  });
}

/// @nodoc
class _$UserAnalyticsCopyWithImpl<$Res, $Val extends UserAnalytics>
    implements $UserAnalyticsCopyWith<$Res> {
  _$UserAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? activeUsers = null,
    Object? newUsersToday = null,
    Object? newUsersThisWeek = null,
    Object? newUsersThisMonth = null,
    Object? userGrowthRate = null,
    Object? usersByRole = null,
    Object? usersByStatus = null,
    Object? userGrowthChart = null,
    Object? userActivityChart = null,
  }) {
    return _then(
      _value.copyWith(
            totalUsers: null == totalUsers
                ? _value.totalUsers
                : totalUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            activeUsers: null == activeUsers
                ? _value.activeUsers
                : activeUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            newUsersToday: null == newUsersToday
                ? _value.newUsersToday
                : newUsersToday // ignore: cast_nullable_to_non_nullable
                      as int,
            newUsersThisWeek: null == newUsersThisWeek
                ? _value.newUsersThisWeek
                : newUsersThisWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            newUsersThisMonth: null == newUsersThisMonth
                ? _value.newUsersThisMonth
                : newUsersThisMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            userGrowthRate: null == userGrowthRate
                ? _value.userGrowthRate
                : userGrowthRate // ignore: cast_nullable_to_non_nullable
                      as double,
            usersByRole: null == usersByRole
                ? _value.usersByRole
                : usersByRole // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            usersByStatus: null == usersByStatus
                ? _value.usersByStatus
                : usersByStatus // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            userGrowthChart: null == userGrowthChart
                ? _value.userGrowthChart
                : userGrowthChart // ignore: cast_nullable_to_non_nullable
                      as List<UserGrowthData>,
            userActivityChart: null == userActivityChart
                ? _value.userActivityChart
                : userActivityChart // ignore: cast_nullable_to_non_nullable
                      as List<UserActivityData>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserAnalyticsImplCopyWith<$Res>
    implements $UserAnalyticsCopyWith<$Res> {
  factory _$$UserAnalyticsImplCopyWith(
    _$UserAnalyticsImpl value,
    $Res Function(_$UserAnalyticsImpl) then,
  ) = __$$UserAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalUsers,
    int activeUsers,
    int newUsersToday,
    int newUsersThisWeek,
    int newUsersThisMonth,
    double userGrowthRate,
    Map<String, int> usersByRole,
    Map<String, int> usersByStatus,
    List<UserGrowthData> userGrowthChart,
    List<UserActivityData> userActivityChart,
  });
}

/// @nodoc
class __$$UserAnalyticsImplCopyWithImpl<$Res>
    extends _$UserAnalyticsCopyWithImpl<$Res, _$UserAnalyticsImpl>
    implements _$$UserAnalyticsImplCopyWith<$Res> {
  __$$UserAnalyticsImplCopyWithImpl(
    _$UserAnalyticsImpl _value,
    $Res Function(_$UserAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? activeUsers = null,
    Object? newUsersToday = null,
    Object? newUsersThisWeek = null,
    Object? newUsersThisMonth = null,
    Object? userGrowthRate = null,
    Object? usersByRole = null,
    Object? usersByStatus = null,
    Object? userGrowthChart = null,
    Object? userActivityChart = null,
  }) {
    return _then(
      _$UserAnalyticsImpl(
        totalUsers: null == totalUsers
            ? _value.totalUsers
            : totalUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        activeUsers: null == activeUsers
            ? _value.activeUsers
            : activeUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        newUsersToday: null == newUsersToday
            ? _value.newUsersToday
            : newUsersToday // ignore: cast_nullable_to_non_nullable
                  as int,
        newUsersThisWeek: null == newUsersThisWeek
            ? _value.newUsersThisWeek
            : newUsersThisWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        newUsersThisMonth: null == newUsersThisMonth
            ? _value.newUsersThisMonth
            : newUsersThisMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        userGrowthRate: null == userGrowthRate
            ? _value.userGrowthRate
            : userGrowthRate // ignore: cast_nullable_to_non_nullable
                  as double,
        usersByRole: null == usersByRole
            ? _value._usersByRole
            : usersByRole // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        usersByStatus: null == usersByStatus
            ? _value._usersByStatus
            : usersByStatus // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        userGrowthChart: null == userGrowthChart
            ? _value._userGrowthChart
            : userGrowthChart // ignore: cast_nullable_to_non_nullable
                  as List<UserGrowthData>,
        userActivityChart: null == userActivityChart
            ? _value._userActivityChart
            : userActivityChart // ignore: cast_nullable_to_non_nullable
                  as List<UserActivityData>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserAnalyticsImpl implements _UserAnalytics {
  const _$UserAnalyticsImpl({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
    required this.userGrowthRate,
    required final Map<String, int> usersByRole,
    required final Map<String, int> usersByStatus,
    required final List<UserGrowthData> userGrowthChart,
    required final List<UserActivityData> userActivityChart,
  }) : _usersByRole = usersByRole,
       _usersByStatus = usersByStatus,
       _userGrowthChart = userGrowthChart,
       _userActivityChart = userActivityChart;

  factory _$UserAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserAnalyticsImplFromJson(json);

  @override
  final int totalUsers;
  @override
  final int activeUsers;
  @override
  final int newUsersToday;
  @override
  final int newUsersThisWeek;
  @override
  final int newUsersThisMonth;
  @override
  final double userGrowthRate;
  final Map<String, int> _usersByRole;
  @override
  Map<String, int> get usersByRole {
    if (_usersByRole is EqualUnmodifiableMapView) return _usersByRole;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_usersByRole);
  }

  final Map<String, int> _usersByStatus;
  @override
  Map<String, int> get usersByStatus {
    if (_usersByStatus is EqualUnmodifiableMapView) return _usersByStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_usersByStatus);
  }

  final List<UserGrowthData> _userGrowthChart;
  @override
  List<UserGrowthData> get userGrowthChart {
    if (_userGrowthChart is EqualUnmodifiableListView) return _userGrowthChart;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userGrowthChart);
  }

  final List<UserActivityData> _userActivityChart;
  @override
  List<UserActivityData> get userActivityChart {
    if (_userActivityChart is EqualUnmodifiableListView)
      return _userActivityChart;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userActivityChart);
  }

  @override
  String toString() {
    return 'UserAnalytics(totalUsers: $totalUsers, activeUsers: $activeUsers, newUsersToday: $newUsersToday, newUsersThisWeek: $newUsersThisWeek, newUsersThisMonth: $newUsersThisMonth, userGrowthRate: $userGrowthRate, usersByRole: $usersByRole, usersByStatus: $usersByStatus, userGrowthChart: $userGrowthChart, userActivityChart: $userActivityChart)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserAnalyticsImpl &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            (identical(other.newUsersToday, newUsersToday) ||
                other.newUsersToday == newUsersToday) &&
            (identical(other.newUsersThisWeek, newUsersThisWeek) ||
                other.newUsersThisWeek == newUsersThisWeek) &&
            (identical(other.newUsersThisMonth, newUsersThisMonth) ||
                other.newUsersThisMonth == newUsersThisMonth) &&
            (identical(other.userGrowthRate, userGrowthRate) ||
                other.userGrowthRate == userGrowthRate) &&
            const DeepCollectionEquality().equals(
              other._usersByRole,
              _usersByRole,
            ) &&
            const DeepCollectionEquality().equals(
              other._usersByStatus,
              _usersByStatus,
            ) &&
            const DeepCollectionEquality().equals(
              other._userGrowthChart,
              _userGrowthChart,
            ) &&
            const DeepCollectionEquality().equals(
              other._userActivityChart,
              _userActivityChart,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalUsers,
    activeUsers,
    newUsersToday,
    newUsersThisWeek,
    newUsersThisMonth,
    userGrowthRate,
    const DeepCollectionEquality().hash(_usersByRole),
    const DeepCollectionEquality().hash(_usersByStatus),
    const DeepCollectionEquality().hash(_userGrowthChart),
    const DeepCollectionEquality().hash(_userActivityChart),
  );

  /// Create a copy of UserAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserAnalyticsImplCopyWith<_$UserAnalyticsImpl> get copyWith =>
      __$$UserAnalyticsImplCopyWithImpl<_$UserAnalyticsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserAnalyticsImplToJson(this);
  }
}

abstract class _UserAnalytics implements UserAnalytics {
  const factory _UserAnalytics({
    required final int totalUsers,
    required final int activeUsers,
    required final int newUsersToday,
    required final int newUsersThisWeek,
    required final int newUsersThisMonth,
    required final double userGrowthRate,
    required final Map<String, int> usersByRole,
    required final Map<String, int> usersByStatus,
    required final List<UserGrowthData> userGrowthChart,
    required final List<UserActivityData> userActivityChart,
  }) = _$UserAnalyticsImpl;

  factory _UserAnalytics.fromJson(Map<String, dynamic> json) =
      _$UserAnalyticsImpl.fromJson;

  @override
  int get totalUsers;
  @override
  int get activeUsers;
  @override
  int get newUsersToday;
  @override
  int get newUsersThisWeek;
  @override
  int get newUsersThisMonth;
  @override
  double get userGrowthRate;
  @override
  Map<String, int> get usersByRole;
  @override
  Map<String, int> get usersByStatus;
  @override
  List<UserGrowthData> get userGrowthChart;
  @override
  List<UserActivityData> get userActivityChart;

  /// Create a copy of UserAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserAnalyticsImplCopyWith<_$UserAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthenticationAnalytics _$AuthenticationAnalyticsFromJson(
  Map<String, dynamic> json,
) {
  return _AuthenticationAnalytics.fromJson(json);
}

/// @nodoc
mixin _$AuthenticationAnalytics {
  int get totalLogins => throw _privateConstructorUsedError;
  int get successfulLogins => throw _privateConstructorUsedError;
  int get failedLogins => throw _privateConstructorUsedError;
  double get loginSuccessRate => throw _privateConstructorUsedError;
  Map<String, int> get loginsByMethod => throw _privateConstructorUsedError;
  Map<String, int> get loginsByDevice => throw _privateConstructorUsedError;
  List<LoginTrendData> get loginTrends => throw _privateConstructorUsedError;
  List<AuthMethodUsage> get authMethodUsage =>
      throw _privateConstructorUsedError;

  /// Serializes this AuthenticationAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthenticationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthenticationAnalyticsCopyWith<AuthenticationAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthenticationAnalyticsCopyWith<$Res> {
  factory $AuthenticationAnalyticsCopyWith(
    AuthenticationAnalytics value,
    $Res Function(AuthenticationAnalytics) then,
  ) = _$AuthenticationAnalyticsCopyWithImpl<$Res, AuthenticationAnalytics>;
  @useResult
  $Res call({
    int totalLogins,
    int successfulLogins,
    int failedLogins,
    double loginSuccessRate,
    Map<String, int> loginsByMethod,
    Map<String, int> loginsByDevice,
    List<LoginTrendData> loginTrends,
    List<AuthMethodUsage> authMethodUsage,
  });
}

/// @nodoc
class _$AuthenticationAnalyticsCopyWithImpl<
  $Res,
  $Val extends AuthenticationAnalytics
>
    implements $AuthenticationAnalyticsCopyWith<$Res> {
  _$AuthenticationAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthenticationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLogins = null,
    Object? successfulLogins = null,
    Object? failedLogins = null,
    Object? loginSuccessRate = null,
    Object? loginsByMethod = null,
    Object? loginsByDevice = null,
    Object? loginTrends = null,
    Object? authMethodUsage = null,
  }) {
    return _then(
      _value.copyWith(
            totalLogins: null == totalLogins
                ? _value.totalLogins
                : totalLogins // ignore: cast_nullable_to_non_nullable
                      as int,
            successfulLogins: null == successfulLogins
                ? _value.successfulLogins
                : successfulLogins // ignore: cast_nullable_to_non_nullable
                      as int,
            failedLogins: null == failedLogins
                ? _value.failedLogins
                : failedLogins // ignore: cast_nullable_to_non_nullable
                      as int,
            loginSuccessRate: null == loginSuccessRate
                ? _value.loginSuccessRate
                : loginSuccessRate // ignore: cast_nullable_to_non_nullable
                      as double,
            loginsByMethod: null == loginsByMethod
                ? _value.loginsByMethod
                : loginsByMethod // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            loginsByDevice: null == loginsByDevice
                ? _value.loginsByDevice
                : loginsByDevice // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            loginTrends: null == loginTrends
                ? _value.loginTrends
                : loginTrends // ignore: cast_nullable_to_non_nullable
                      as List<LoginTrendData>,
            authMethodUsage: null == authMethodUsage
                ? _value.authMethodUsage
                : authMethodUsage // ignore: cast_nullable_to_non_nullable
                      as List<AuthMethodUsage>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthenticationAnalyticsImplCopyWith<$Res>
    implements $AuthenticationAnalyticsCopyWith<$Res> {
  factory _$$AuthenticationAnalyticsImplCopyWith(
    _$AuthenticationAnalyticsImpl value,
    $Res Function(_$AuthenticationAnalyticsImpl) then,
  ) = __$$AuthenticationAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalLogins,
    int successfulLogins,
    int failedLogins,
    double loginSuccessRate,
    Map<String, int> loginsByMethod,
    Map<String, int> loginsByDevice,
    List<LoginTrendData> loginTrends,
    List<AuthMethodUsage> authMethodUsage,
  });
}

/// @nodoc
class __$$AuthenticationAnalyticsImplCopyWithImpl<$Res>
    extends
        _$AuthenticationAnalyticsCopyWithImpl<
          $Res,
          _$AuthenticationAnalyticsImpl
        >
    implements _$$AuthenticationAnalyticsImplCopyWith<$Res> {
  __$$AuthenticationAnalyticsImplCopyWithImpl(
    _$AuthenticationAnalyticsImpl _value,
    $Res Function(_$AuthenticationAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthenticationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLogins = null,
    Object? successfulLogins = null,
    Object? failedLogins = null,
    Object? loginSuccessRate = null,
    Object? loginsByMethod = null,
    Object? loginsByDevice = null,
    Object? loginTrends = null,
    Object? authMethodUsage = null,
  }) {
    return _then(
      _$AuthenticationAnalyticsImpl(
        totalLogins: null == totalLogins
            ? _value.totalLogins
            : totalLogins // ignore: cast_nullable_to_non_nullable
                  as int,
        successfulLogins: null == successfulLogins
            ? _value.successfulLogins
            : successfulLogins // ignore: cast_nullable_to_non_nullable
                  as int,
        failedLogins: null == failedLogins
            ? _value.failedLogins
            : failedLogins // ignore: cast_nullable_to_non_nullable
                  as int,
        loginSuccessRate: null == loginSuccessRate
            ? _value.loginSuccessRate
            : loginSuccessRate // ignore: cast_nullable_to_non_nullable
                  as double,
        loginsByMethod: null == loginsByMethod
            ? _value._loginsByMethod
            : loginsByMethod // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        loginsByDevice: null == loginsByDevice
            ? _value._loginsByDevice
            : loginsByDevice // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        loginTrends: null == loginTrends
            ? _value._loginTrends
            : loginTrends // ignore: cast_nullable_to_non_nullable
                  as List<LoginTrendData>,
        authMethodUsage: null == authMethodUsage
            ? _value._authMethodUsage
            : authMethodUsage // ignore: cast_nullable_to_non_nullable
                  as List<AuthMethodUsage>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthenticationAnalyticsImpl implements _AuthenticationAnalytics {
  const _$AuthenticationAnalyticsImpl({
    required this.totalLogins,
    required this.successfulLogins,
    required this.failedLogins,
    required this.loginSuccessRate,
    required final Map<String, int> loginsByMethod,
    required final Map<String, int> loginsByDevice,
    required final List<LoginTrendData> loginTrends,
    required final List<AuthMethodUsage> authMethodUsage,
  }) : _loginsByMethod = loginsByMethod,
       _loginsByDevice = loginsByDevice,
       _loginTrends = loginTrends,
       _authMethodUsage = authMethodUsage;

  factory _$AuthenticationAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthenticationAnalyticsImplFromJson(json);

  @override
  final int totalLogins;
  @override
  final int successfulLogins;
  @override
  final int failedLogins;
  @override
  final double loginSuccessRate;
  final Map<String, int> _loginsByMethod;
  @override
  Map<String, int> get loginsByMethod {
    if (_loginsByMethod is EqualUnmodifiableMapView) return _loginsByMethod;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_loginsByMethod);
  }

  final Map<String, int> _loginsByDevice;
  @override
  Map<String, int> get loginsByDevice {
    if (_loginsByDevice is EqualUnmodifiableMapView) return _loginsByDevice;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_loginsByDevice);
  }

  final List<LoginTrendData> _loginTrends;
  @override
  List<LoginTrendData> get loginTrends {
    if (_loginTrends is EqualUnmodifiableListView) return _loginTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_loginTrends);
  }

  final List<AuthMethodUsage> _authMethodUsage;
  @override
  List<AuthMethodUsage> get authMethodUsage {
    if (_authMethodUsage is EqualUnmodifiableListView) return _authMethodUsage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authMethodUsage);
  }

  @override
  String toString() {
    return 'AuthenticationAnalytics(totalLogins: $totalLogins, successfulLogins: $successfulLogins, failedLogins: $failedLogins, loginSuccessRate: $loginSuccessRate, loginsByMethod: $loginsByMethod, loginsByDevice: $loginsByDevice, loginTrends: $loginTrends, authMethodUsage: $authMethodUsage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticationAnalyticsImpl &&
            (identical(other.totalLogins, totalLogins) ||
                other.totalLogins == totalLogins) &&
            (identical(other.successfulLogins, successfulLogins) ||
                other.successfulLogins == successfulLogins) &&
            (identical(other.failedLogins, failedLogins) ||
                other.failedLogins == failedLogins) &&
            (identical(other.loginSuccessRate, loginSuccessRate) ||
                other.loginSuccessRate == loginSuccessRate) &&
            const DeepCollectionEquality().equals(
              other._loginsByMethod,
              _loginsByMethod,
            ) &&
            const DeepCollectionEquality().equals(
              other._loginsByDevice,
              _loginsByDevice,
            ) &&
            const DeepCollectionEquality().equals(
              other._loginTrends,
              _loginTrends,
            ) &&
            const DeepCollectionEquality().equals(
              other._authMethodUsage,
              _authMethodUsage,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalLogins,
    successfulLogins,
    failedLogins,
    loginSuccessRate,
    const DeepCollectionEquality().hash(_loginsByMethod),
    const DeepCollectionEquality().hash(_loginsByDevice),
    const DeepCollectionEquality().hash(_loginTrends),
    const DeepCollectionEquality().hash(_authMethodUsage),
  );

  /// Create a copy of AuthenticationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticationAnalyticsImplCopyWith<_$AuthenticationAnalyticsImpl>
  get copyWith =>
      __$$AuthenticationAnalyticsImplCopyWithImpl<
        _$AuthenticationAnalyticsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthenticationAnalyticsImplToJson(this);
  }
}

abstract class _AuthenticationAnalytics implements AuthenticationAnalytics {
  const factory _AuthenticationAnalytics({
    required final int totalLogins,
    required final int successfulLogins,
    required final int failedLogins,
    required final double loginSuccessRate,
    required final Map<String, int> loginsByMethod,
    required final Map<String, int> loginsByDevice,
    required final List<LoginTrendData> loginTrends,
    required final List<AuthMethodUsage> authMethodUsage,
  }) = _$AuthenticationAnalyticsImpl;

  factory _AuthenticationAnalytics.fromJson(Map<String, dynamic> json) =
      _$AuthenticationAnalyticsImpl.fromJson;

  @override
  int get totalLogins;
  @override
  int get successfulLogins;
  @override
  int get failedLogins;
  @override
  double get loginSuccessRate;
  @override
  Map<String, int> get loginsByMethod;
  @override
  Map<String, int> get loginsByDevice;
  @override
  List<LoginTrendData> get loginTrends;
  @override
  List<AuthMethodUsage> get authMethodUsage;

  /// Create a copy of AuthenticationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticationAnalyticsImplCopyWith<_$AuthenticationAnalyticsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SecurityAnalytics _$SecurityAnalyticsFromJson(Map<String, dynamic> json) {
  return _SecurityAnalytics.fromJson(json);
}

/// @nodoc
mixin _$SecurityAnalytics {
  int get securityIncidents => throw _privateConstructorUsedError;
  int get blockedAttempts => throw _privateConstructorUsedError;
  int get suspiciousActivities => throw _privateConstructorUsedError;
  int get activeDevices => throw _privateConstructorUsedError;
  int get trustedDevices => throw _privateConstructorUsedError;
  List<SecurityIncident> get recentIncidents =>
      throw _privateConstructorUsedError;
  Map<String, int> get threatsByType => throw _privateConstructorUsedError;
  List<SecurityTrendData> get securityTrends =>
      throw _privateConstructorUsedError;

  /// Serializes this SecurityAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityAnalyticsCopyWith<SecurityAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityAnalyticsCopyWith<$Res> {
  factory $SecurityAnalyticsCopyWith(
    SecurityAnalytics value,
    $Res Function(SecurityAnalytics) then,
  ) = _$SecurityAnalyticsCopyWithImpl<$Res, SecurityAnalytics>;
  @useResult
  $Res call({
    int securityIncidents,
    int blockedAttempts,
    int suspiciousActivities,
    int activeDevices,
    int trustedDevices,
    List<SecurityIncident> recentIncidents,
    Map<String, int> threatsByType,
    List<SecurityTrendData> securityTrends,
  });
}

/// @nodoc
class _$SecurityAnalyticsCopyWithImpl<$Res, $Val extends SecurityAnalytics>
    implements $SecurityAnalyticsCopyWith<$Res> {
  _$SecurityAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? securityIncidents = null,
    Object? blockedAttempts = null,
    Object? suspiciousActivities = null,
    Object? activeDevices = null,
    Object? trustedDevices = null,
    Object? recentIncidents = null,
    Object? threatsByType = null,
    Object? securityTrends = null,
  }) {
    return _then(
      _value.copyWith(
            securityIncidents: null == securityIncidents
                ? _value.securityIncidents
                : securityIncidents // ignore: cast_nullable_to_non_nullable
                      as int,
            blockedAttempts: null == blockedAttempts
                ? _value.blockedAttempts
                : blockedAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            suspiciousActivities: null == suspiciousActivities
                ? _value.suspiciousActivities
                : suspiciousActivities // ignore: cast_nullable_to_non_nullable
                      as int,
            activeDevices: null == activeDevices
                ? _value.activeDevices
                : activeDevices // ignore: cast_nullable_to_non_nullable
                      as int,
            trustedDevices: null == trustedDevices
                ? _value.trustedDevices
                : trustedDevices // ignore: cast_nullable_to_non_nullable
                      as int,
            recentIncidents: null == recentIncidents
                ? _value.recentIncidents
                : recentIncidents // ignore: cast_nullable_to_non_nullable
                      as List<SecurityIncident>,
            threatsByType: null == threatsByType
                ? _value.threatsByType
                : threatsByType // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            securityTrends: null == securityTrends
                ? _value.securityTrends
                : securityTrends // ignore: cast_nullable_to_non_nullable
                      as List<SecurityTrendData>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecurityAnalyticsImplCopyWith<$Res>
    implements $SecurityAnalyticsCopyWith<$Res> {
  factory _$$SecurityAnalyticsImplCopyWith(
    _$SecurityAnalyticsImpl value,
    $Res Function(_$SecurityAnalyticsImpl) then,
  ) = __$$SecurityAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int securityIncidents,
    int blockedAttempts,
    int suspiciousActivities,
    int activeDevices,
    int trustedDevices,
    List<SecurityIncident> recentIncidents,
    Map<String, int> threatsByType,
    List<SecurityTrendData> securityTrends,
  });
}

/// @nodoc
class __$$SecurityAnalyticsImplCopyWithImpl<$Res>
    extends _$SecurityAnalyticsCopyWithImpl<$Res, _$SecurityAnalyticsImpl>
    implements _$$SecurityAnalyticsImplCopyWith<$Res> {
  __$$SecurityAnalyticsImplCopyWithImpl(
    _$SecurityAnalyticsImpl _value,
    $Res Function(_$SecurityAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? securityIncidents = null,
    Object? blockedAttempts = null,
    Object? suspiciousActivities = null,
    Object? activeDevices = null,
    Object? trustedDevices = null,
    Object? recentIncidents = null,
    Object? threatsByType = null,
    Object? securityTrends = null,
  }) {
    return _then(
      _$SecurityAnalyticsImpl(
        securityIncidents: null == securityIncidents
            ? _value.securityIncidents
            : securityIncidents // ignore: cast_nullable_to_non_nullable
                  as int,
        blockedAttempts: null == blockedAttempts
            ? _value.blockedAttempts
            : blockedAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        suspiciousActivities: null == suspiciousActivities
            ? _value.suspiciousActivities
            : suspiciousActivities // ignore: cast_nullable_to_non_nullable
                  as int,
        activeDevices: null == activeDevices
            ? _value.activeDevices
            : activeDevices // ignore: cast_nullable_to_non_nullable
                  as int,
        trustedDevices: null == trustedDevices
            ? _value.trustedDevices
            : trustedDevices // ignore: cast_nullable_to_non_nullable
                  as int,
        recentIncidents: null == recentIncidents
            ? _value._recentIncidents
            : recentIncidents // ignore: cast_nullable_to_non_nullable
                  as List<SecurityIncident>,
        threatsByType: null == threatsByType
            ? _value._threatsByType
            : threatsByType // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        securityTrends: null == securityTrends
            ? _value._securityTrends
            : securityTrends // ignore: cast_nullable_to_non_nullable
                  as List<SecurityTrendData>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityAnalyticsImpl implements _SecurityAnalytics {
  const _$SecurityAnalyticsImpl({
    required this.securityIncidents,
    required this.blockedAttempts,
    required this.suspiciousActivities,
    required this.activeDevices,
    required this.trustedDevices,
    required final List<SecurityIncident> recentIncidents,
    required final Map<String, int> threatsByType,
    required final List<SecurityTrendData> securityTrends,
  }) : _recentIncidents = recentIncidents,
       _threatsByType = threatsByType,
       _securityTrends = securityTrends;

  factory _$SecurityAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityAnalyticsImplFromJson(json);

  @override
  final int securityIncidents;
  @override
  final int blockedAttempts;
  @override
  final int suspiciousActivities;
  @override
  final int activeDevices;
  @override
  final int trustedDevices;
  final List<SecurityIncident> _recentIncidents;
  @override
  List<SecurityIncident> get recentIncidents {
    if (_recentIncidents is EqualUnmodifiableListView) return _recentIncidents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentIncidents);
  }

  final Map<String, int> _threatsByType;
  @override
  Map<String, int> get threatsByType {
    if (_threatsByType is EqualUnmodifiableMapView) return _threatsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_threatsByType);
  }

  final List<SecurityTrendData> _securityTrends;
  @override
  List<SecurityTrendData> get securityTrends {
    if (_securityTrends is EqualUnmodifiableListView) return _securityTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_securityTrends);
  }

  @override
  String toString() {
    return 'SecurityAnalytics(securityIncidents: $securityIncidents, blockedAttempts: $blockedAttempts, suspiciousActivities: $suspiciousActivities, activeDevices: $activeDevices, trustedDevices: $trustedDevices, recentIncidents: $recentIncidents, threatsByType: $threatsByType, securityTrends: $securityTrends)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityAnalyticsImpl &&
            (identical(other.securityIncidents, securityIncidents) ||
                other.securityIncidents == securityIncidents) &&
            (identical(other.blockedAttempts, blockedAttempts) ||
                other.blockedAttempts == blockedAttempts) &&
            (identical(other.suspiciousActivities, suspiciousActivities) ||
                other.suspiciousActivities == suspiciousActivities) &&
            (identical(other.activeDevices, activeDevices) ||
                other.activeDevices == activeDevices) &&
            (identical(other.trustedDevices, trustedDevices) ||
                other.trustedDevices == trustedDevices) &&
            const DeepCollectionEquality().equals(
              other._recentIncidents,
              _recentIncidents,
            ) &&
            const DeepCollectionEquality().equals(
              other._threatsByType,
              _threatsByType,
            ) &&
            const DeepCollectionEquality().equals(
              other._securityTrends,
              _securityTrends,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    securityIncidents,
    blockedAttempts,
    suspiciousActivities,
    activeDevices,
    trustedDevices,
    const DeepCollectionEquality().hash(_recentIncidents),
    const DeepCollectionEquality().hash(_threatsByType),
    const DeepCollectionEquality().hash(_securityTrends),
  );

  /// Create a copy of SecurityAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityAnalyticsImplCopyWith<_$SecurityAnalyticsImpl> get copyWith =>
      __$$SecurityAnalyticsImplCopyWithImpl<_$SecurityAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityAnalyticsImplToJson(this);
  }
}

abstract class _SecurityAnalytics implements SecurityAnalytics {
  const factory _SecurityAnalytics({
    required final int securityIncidents,
    required final int blockedAttempts,
    required final int suspiciousActivities,
    required final int activeDevices,
    required final int trustedDevices,
    required final List<SecurityIncident> recentIncidents,
    required final Map<String, int> threatsByType,
    required final List<SecurityTrendData> securityTrends,
  }) = _$SecurityAnalyticsImpl;

  factory _SecurityAnalytics.fromJson(Map<String, dynamic> json) =
      _$SecurityAnalyticsImpl.fromJson;

  @override
  int get securityIncidents;
  @override
  int get blockedAttempts;
  @override
  int get suspiciousActivities;
  @override
  int get activeDevices;
  @override
  int get trustedDevices;
  @override
  List<SecurityIncident> get recentIncidents;
  @override
  Map<String, int> get threatsByType;
  @override
  List<SecurityTrendData> get securityTrends;

  /// Create a copy of SecurityAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityAnalyticsImplCopyWith<_$SecurityAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiUsageAnalytics _$ApiUsageAnalyticsFromJson(Map<String, dynamic> json) {
  return _ApiUsageAnalytics.fromJson(json);
}

/// @nodoc
mixin _$ApiUsageAnalytics {
  int get totalRequests => throw _privateConstructorUsedError;
  int get successfulRequests => throw _privateConstructorUsedError;
  int get failedRequests => throw _privateConstructorUsedError;
  double get averageResponseTime => throw _privateConstructorUsedError;
  int get activeApiKeys => throw _privateConstructorUsedError;
  Map<String, int> get requestsByEndpoint => throw _privateConstructorUsedError;
  Map<String, int> get requestsByStatusCode =>
      throw _privateConstructorUsedError;
  List<ApiUsageTrend> get usageTrends => throw _privateConstructorUsedError;
  List<EndpointPerformance> get topEndpoints =>
      throw _privateConstructorUsedError;

  /// Serializes this ApiUsageAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiUsageAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiUsageAnalyticsCopyWith<ApiUsageAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiUsageAnalyticsCopyWith<$Res> {
  factory $ApiUsageAnalyticsCopyWith(
    ApiUsageAnalytics value,
    $Res Function(ApiUsageAnalytics) then,
  ) = _$ApiUsageAnalyticsCopyWithImpl<$Res, ApiUsageAnalytics>;
  @useResult
  $Res call({
    int totalRequests,
    int successfulRequests,
    int failedRequests,
    double averageResponseTime,
    int activeApiKeys,
    Map<String, int> requestsByEndpoint,
    Map<String, int> requestsByStatusCode,
    List<ApiUsageTrend> usageTrends,
    List<EndpointPerformance> topEndpoints,
  });
}

/// @nodoc
class _$ApiUsageAnalyticsCopyWithImpl<$Res, $Val extends ApiUsageAnalytics>
    implements $ApiUsageAnalyticsCopyWith<$Res> {
  _$ApiUsageAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiUsageAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRequests = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? averageResponseTime = null,
    Object? activeApiKeys = null,
    Object? requestsByEndpoint = null,
    Object? requestsByStatusCode = null,
    Object? usageTrends = null,
    Object? topEndpoints = null,
  }) {
    return _then(
      _value.copyWith(
            totalRequests: null == totalRequests
                ? _value.totalRequests
                : totalRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            successfulRequests: null == successfulRequests
                ? _value.successfulRequests
                : successfulRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            failedRequests: null == failedRequests
                ? _value.failedRequests
                : failedRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            averageResponseTime: null == averageResponseTime
                ? _value.averageResponseTime
                : averageResponseTime // ignore: cast_nullable_to_non_nullable
                      as double,
            activeApiKeys: null == activeApiKeys
                ? _value.activeApiKeys
                : activeApiKeys // ignore: cast_nullable_to_non_nullable
                      as int,
            requestsByEndpoint: null == requestsByEndpoint
                ? _value.requestsByEndpoint
                : requestsByEndpoint // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            requestsByStatusCode: null == requestsByStatusCode
                ? _value.requestsByStatusCode
                : requestsByStatusCode // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            usageTrends: null == usageTrends
                ? _value.usageTrends
                : usageTrends // ignore: cast_nullable_to_non_nullable
                      as List<ApiUsageTrend>,
            topEndpoints: null == topEndpoints
                ? _value.topEndpoints
                : topEndpoints // ignore: cast_nullable_to_non_nullable
                      as List<EndpointPerformance>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiUsageAnalyticsImplCopyWith<$Res>
    implements $ApiUsageAnalyticsCopyWith<$Res> {
  factory _$$ApiUsageAnalyticsImplCopyWith(
    _$ApiUsageAnalyticsImpl value,
    $Res Function(_$ApiUsageAnalyticsImpl) then,
  ) = __$$ApiUsageAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalRequests,
    int successfulRequests,
    int failedRequests,
    double averageResponseTime,
    int activeApiKeys,
    Map<String, int> requestsByEndpoint,
    Map<String, int> requestsByStatusCode,
    List<ApiUsageTrend> usageTrends,
    List<EndpointPerformance> topEndpoints,
  });
}

/// @nodoc
class __$$ApiUsageAnalyticsImplCopyWithImpl<$Res>
    extends _$ApiUsageAnalyticsCopyWithImpl<$Res, _$ApiUsageAnalyticsImpl>
    implements _$$ApiUsageAnalyticsImplCopyWith<$Res> {
  __$$ApiUsageAnalyticsImplCopyWithImpl(
    _$ApiUsageAnalyticsImpl _value,
    $Res Function(_$ApiUsageAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiUsageAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRequests = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? averageResponseTime = null,
    Object? activeApiKeys = null,
    Object? requestsByEndpoint = null,
    Object? requestsByStatusCode = null,
    Object? usageTrends = null,
    Object? topEndpoints = null,
  }) {
    return _then(
      _$ApiUsageAnalyticsImpl(
        totalRequests: null == totalRequests
            ? _value.totalRequests
            : totalRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        successfulRequests: null == successfulRequests
            ? _value.successfulRequests
            : successfulRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        failedRequests: null == failedRequests
            ? _value.failedRequests
            : failedRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        averageResponseTime: null == averageResponseTime
            ? _value.averageResponseTime
            : averageResponseTime // ignore: cast_nullable_to_non_nullable
                  as double,
        activeApiKeys: null == activeApiKeys
            ? _value.activeApiKeys
            : activeApiKeys // ignore: cast_nullable_to_non_nullable
                  as int,
        requestsByEndpoint: null == requestsByEndpoint
            ? _value._requestsByEndpoint
            : requestsByEndpoint // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        requestsByStatusCode: null == requestsByStatusCode
            ? _value._requestsByStatusCode
            : requestsByStatusCode // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        usageTrends: null == usageTrends
            ? _value._usageTrends
            : usageTrends // ignore: cast_nullable_to_non_nullable
                  as List<ApiUsageTrend>,
        topEndpoints: null == topEndpoints
            ? _value._topEndpoints
            : topEndpoints // ignore: cast_nullable_to_non_nullable
                  as List<EndpointPerformance>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiUsageAnalyticsImpl implements _ApiUsageAnalytics {
  const _$ApiUsageAnalyticsImpl({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageResponseTime,
    required this.activeApiKeys,
    required final Map<String, int> requestsByEndpoint,
    required final Map<String, int> requestsByStatusCode,
    required final List<ApiUsageTrend> usageTrends,
    required final List<EndpointPerformance> topEndpoints,
  }) : _requestsByEndpoint = requestsByEndpoint,
       _requestsByStatusCode = requestsByStatusCode,
       _usageTrends = usageTrends,
       _topEndpoints = topEndpoints;

  factory _$ApiUsageAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiUsageAnalyticsImplFromJson(json);

  @override
  final int totalRequests;
  @override
  final int successfulRequests;
  @override
  final int failedRequests;
  @override
  final double averageResponseTime;
  @override
  final int activeApiKeys;
  final Map<String, int> _requestsByEndpoint;
  @override
  Map<String, int> get requestsByEndpoint {
    if (_requestsByEndpoint is EqualUnmodifiableMapView)
      return _requestsByEndpoint;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_requestsByEndpoint);
  }

  final Map<String, int> _requestsByStatusCode;
  @override
  Map<String, int> get requestsByStatusCode {
    if (_requestsByStatusCode is EqualUnmodifiableMapView)
      return _requestsByStatusCode;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_requestsByStatusCode);
  }

  final List<ApiUsageTrend> _usageTrends;
  @override
  List<ApiUsageTrend> get usageTrends {
    if (_usageTrends is EqualUnmodifiableListView) return _usageTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_usageTrends);
  }

  final List<EndpointPerformance> _topEndpoints;
  @override
  List<EndpointPerformance> get topEndpoints {
    if (_topEndpoints is EqualUnmodifiableListView) return _topEndpoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topEndpoints);
  }

  @override
  String toString() {
    return 'ApiUsageAnalytics(totalRequests: $totalRequests, successfulRequests: $successfulRequests, failedRequests: $failedRequests, averageResponseTime: $averageResponseTime, activeApiKeys: $activeApiKeys, requestsByEndpoint: $requestsByEndpoint, requestsByStatusCode: $requestsByStatusCode, usageTrends: $usageTrends, topEndpoints: $topEndpoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiUsageAnalyticsImpl &&
            (identical(other.totalRequests, totalRequests) ||
                other.totalRequests == totalRequests) &&
            (identical(other.successfulRequests, successfulRequests) ||
                other.successfulRequests == successfulRequests) &&
            (identical(other.failedRequests, failedRequests) ||
                other.failedRequests == failedRequests) &&
            (identical(other.averageResponseTime, averageResponseTime) ||
                other.averageResponseTime == averageResponseTime) &&
            (identical(other.activeApiKeys, activeApiKeys) ||
                other.activeApiKeys == activeApiKeys) &&
            const DeepCollectionEquality().equals(
              other._requestsByEndpoint,
              _requestsByEndpoint,
            ) &&
            const DeepCollectionEquality().equals(
              other._requestsByStatusCode,
              _requestsByStatusCode,
            ) &&
            const DeepCollectionEquality().equals(
              other._usageTrends,
              _usageTrends,
            ) &&
            const DeepCollectionEquality().equals(
              other._topEndpoints,
              _topEndpoints,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalRequests,
    successfulRequests,
    failedRequests,
    averageResponseTime,
    activeApiKeys,
    const DeepCollectionEquality().hash(_requestsByEndpoint),
    const DeepCollectionEquality().hash(_requestsByStatusCode),
    const DeepCollectionEquality().hash(_usageTrends),
    const DeepCollectionEquality().hash(_topEndpoints),
  );

  /// Create a copy of ApiUsageAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiUsageAnalyticsImplCopyWith<_$ApiUsageAnalyticsImpl> get copyWith =>
      __$$ApiUsageAnalyticsImplCopyWithImpl<_$ApiUsageAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiUsageAnalyticsImplToJson(this);
  }
}

abstract class _ApiUsageAnalytics implements ApiUsageAnalytics {
  const factory _ApiUsageAnalytics({
    required final int totalRequests,
    required final int successfulRequests,
    required final int failedRequests,
    required final double averageResponseTime,
    required final int activeApiKeys,
    required final Map<String, int> requestsByEndpoint,
    required final Map<String, int> requestsByStatusCode,
    required final List<ApiUsageTrend> usageTrends,
    required final List<EndpointPerformance> topEndpoints,
  }) = _$ApiUsageAnalyticsImpl;

  factory _ApiUsageAnalytics.fromJson(Map<String, dynamic> json) =
      _$ApiUsageAnalyticsImpl.fromJson;

  @override
  int get totalRequests;
  @override
  int get successfulRequests;
  @override
  int get failedRequests;
  @override
  double get averageResponseTime;
  @override
  int get activeApiKeys;
  @override
  Map<String, int> get requestsByEndpoint;
  @override
  Map<String, int> get requestsByStatusCode;
  @override
  List<ApiUsageTrend> get usageTrends;
  @override
  List<EndpointPerformance> get topEndpoints;

  /// Create a copy of ApiUsageAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiUsageAnalyticsImplCopyWith<_$ApiUsageAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SystemPerformance _$SystemPerformanceFromJson(Map<String, dynamic> json) {
  return _SystemPerformance.fromJson(json);
}

/// @nodoc
mixin _$SystemPerformance {
  double get cpuUsage => throw _privateConstructorUsedError;
  double get memoryUsage => throw _privateConstructorUsedError;
  double get diskUsage => throw _privateConstructorUsedError;
  int get activeConnections => throw _privateConstructorUsedError;
  double get averageResponseTime => throw _privateConstructorUsedError;
  double get uptime => throw _privateConstructorUsedError;
  List<PerformanceMetric> get performanceHistory =>
      throw _privateConstructorUsedError;
  SystemHealthStatus get healthStatus => throw _privateConstructorUsedError;

  /// Serializes this SystemPerformance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemPerformanceCopyWith<SystemPerformance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemPerformanceCopyWith<$Res> {
  factory $SystemPerformanceCopyWith(
    SystemPerformance value,
    $Res Function(SystemPerformance) then,
  ) = _$SystemPerformanceCopyWithImpl<$Res, SystemPerformance>;
  @useResult
  $Res call({
    double cpuUsage,
    double memoryUsage,
    double diskUsage,
    int activeConnections,
    double averageResponseTime,
    double uptime,
    List<PerformanceMetric> performanceHistory,
    SystemHealthStatus healthStatus,
  });
}

/// @nodoc
class _$SystemPerformanceCopyWithImpl<$Res, $Val extends SystemPerformance>
    implements $SystemPerformanceCopyWith<$Res> {
  _$SystemPerformanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? diskUsage = null,
    Object? activeConnections = null,
    Object? averageResponseTime = null,
    Object? uptime = null,
    Object? performanceHistory = null,
    Object? healthStatus = null,
  }) {
    return _then(
      _value.copyWith(
            cpuUsage: null == cpuUsage
                ? _value.cpuUsage
                : cpuUsage // ignore: cast_nullable_to_non_nullable
                      as double,
            memoryUsage: null == memoryUsage
                ? _value.memoryUsage
                : memoryUsage // ignore: cast_nullable_to_non_nullable
                      as double,
            diskUsage: null == diskUsage
                ? _value.diskUsage
                : diskUsage // ignore: cast_nullable_to_non_nullable
                      as double,
            activeConnections: null == activeConnections
                ? _value.activeConnections
                : activeConnections // ignore: cast_nullable_to_non_nullable
                      as int,
            averageResponseTime: null == averageResponseTime
                ? _value.averageResponseTime
                : averageResponseTime // ignore: cast_nullable_to_non_nullable
                      as double,
            uptime: null == uptime
                ? _value.uptime
                : uptime // ignore: cast_nullable_to_non_nullable
                      as double,
            performanceHistory: null == performanceHistory
                ? _value.performanceHistory
                : performanceHistory // ignore: cast_nullable_to_non_nullable
                      as List<PerformanceMetric>,
            healthStatus: null == healthStatus
                ? _value.healthStatus
                : healthStatus // ignore: cast_nullable_to_non_nullable
                      as SystemHealthStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemPerformanceImplCopyWith<$Res>
    implements $SystemPerformanceCopyWith<$Res> {
  factory _$$SystemPerformanceImplCopyWith(
    _$SystemPerformanceImpl value,
    $Res Function(_$SystemPerformanceImpl) then,
  ) = __$$SystemPerformanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double cpuUsage,
    double memoryUsage,
    double diskUsage,
    int activeConnections,
    double averageResponseTime,
    double uptime,
    List<PerformanceMetric> performanceHistory,
    SystemHealthStatus healthStatus,
  });
}

/// @nodoc
class __$$SystemPerformanceImplCopyWithImpl<$Res>
    extends _$SystemPerformanceCopyWithImpl<$Res, _$SystemPerformanceImpl>
    implements _$$SystemPerformanceImplCopyWith<$Res> {
  __$$SystemPerformanceImplCopyWithImpl(
    _$SystemPerformanceImpl _value,
    $Res Function(_$SystemPerformanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? diskUsage = null,
    Object? activeConnections = null,
    Object? averageResponseTime = null,
    Object? uptime = null,
    Object? performanceHistory = null,
    Object? healthStatus = null,
  }) {
    return _then(
      _$SystemPerformanceImpl(
        cpuUsage: null == cpuUsage
            ? _value.cpuUsage
            : cpuUsage // ignore: cast_nullable_to_non_nullable
                  as double,
        memoryUsage: null == memoryUsage
            ? _value.memoryUsage
            : memoryUsage // ignore: cast_nullable_to_non_nullable
                  as double,
        diskUsage: null == diskUsage
            ? _value.diskUsage
            : diskUsage // ignore: cast_nullable_to_non_nullable
                  as double,
        activeConnections: null == activeConnections
            ? _value.activeConnections
            : activeConnections // ignore: cast_nullable_to_non_nullable
                  as int,
        averageResponseTime: null == averageResponseTime
            ? _value.averageResponseTime
            : averageResponseTime // ignore: cast_nullable_to_non_nullable
                  as double,
        uptime: null == uptime
            ? _value.uptime
            : uptime // ignore: cast_nullable_to_non_nullable
                  as double,
        performanceHistory: null == performanceHistory
            ? _value._performanceHistory
            : performanceHistory // ignore: cast_nullable_to_non_nullable
                  as List<PerformanceMetric>,
        healthStatus: null == healthStatus
            ? _value.healthStatus
            : healthStatus // ignore: cast_nullable_to_non_nullable
                  as SystemHealthStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemPerformanceImpl implements _SystemPerformance {
  const _$SystemPerformanceImpl({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.activeConnections,
    required this.averageResponseTime,
    required this.uptime,
    required final List<PerformanceMetric> performanceHistory,
    required this.healthStatus,
  }) : _performanceHistory = performanceHistory;

  factory _$SystemPerformanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemPerformanceImplFromJson(json);

  @override
  final double cpuUsage;
  @override
  final double memoryUsage;
  @override
  final double diskUsage;
  @override
  final int activeConnections;
  @override
  final double averageResponseTime;
  @override
  final double uptime;
  final List<PerformanceMetric> _performanceHistory;
  @override
  List<PerformanceMetric> get performanceHistory {
    if (_performanceHistory is EqualUnmodifiableListView)
      return _performanceHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_performanceHistory);
  }

  @override
  final SystemHealthStatus healthStatus;

  @override
  String toString() {
    return 'SystemPerformance(cpuUsage: $cpuUsage, memoryUsage: $memoryUsage, diskUsage: $diskUsage, activeConnections: $activeConnections, averageResponseTime: $averageResponseTime, uptime: $uptime, performanceHistory: $performanceHistory, healthStatus: $healthStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemPerformanceImpl &&
            (identical(other.cpuUsage, cpuUsage) ||
                other.cpuUsage == cpuUsage) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.diskUsage, diskUsage) ||
                other.diskUsage == diskUsage) &&
            (identical(other.activeConnections, activeConnections) ||
                other.activeConnections == activeConnections) &&
            (identical(other.averageResponseTime, averageResponseTime) ||
                other.averageResponseTime == averageResponseTime) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            const DeepCollectionEquality().equals(
              other._performanceHistory,
              _performanceHistory,
            ) &&
            (identical(other.healthStatus, healthStatus) ||
                other.healthStatus == healthStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    cpuUsage,
    memoryUsage,
    diskUsage,
    activeConnections,
    averageResponseTime,
    uptime,
    const DeepCollectionEquality().hash(_performanceHistory),
    healthStatus,
  );

  /// Create a copy of SystemPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemPerformanceImplCopyWith<_$SystemPerformanceImpl> get copyWith =>
      __$$SystemPerformanceImplCopyWithImpl<_$SystemPerformanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemPerformanceImplToJson(this);
  }
}

abstract class _SystemPerformance implements SystemPerformance {
  const factory _SystemPerformance({
    required final double cpuUsage,
    required final double memoryUsage,
    required final double diskUsage,
    required final int activeConnections,
    required final double averageResponseTime,
    required final double uptime,
    required final List<PerformanceMetric> performanceHistory,
    required final SystemHealthStatus healthStatus,
  }) = _$SystemPerformanceImpl;

  factory _SystemPerformance.fromJson(Map<String, dynamic> json) =
      _$SystemPerformanceImpl.fromJson;

  @override
  double get cpuUsage;
  @override
  double get memoryUsage;
  @override
  double get diskUsage;
  @override
  int get activeConnections;
  @override
  double get averageResponseTime;
  @override
  double get uptime;
  @override
  List<PerformanceMetric> get performanceHistory;
  @override
  SystemHealthStatus get healthStatus;

  /// Create a copy of SystemPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemPerformanceImplCopyWith<_$SystemPerformanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserGrowthData _$UserGrowthDataFromJson(Map<String, dynamic> json) {
  return _UserGrowthData.fromJson(json);
}

/// @nodoc
mixin _$UserGrowthData {
  DateTime get date => throw _privateConstructorUsedError;
  int get newUsers => throw _privateConstructorUsedError;
  int get totalUsers => throw _privateConstructorUsedError;

  /// Serializes this UserGrowthData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserGrowthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGrowthDataCopyWith<UserGrowthData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGrowthDataCopyWith<$Res> {
  factory $UserGrowthDataCopyWith(
    UserGrowthData value,
    $Res Function(UserGrowthData) then,
  ) = _$UserGrowthDataCopyWithImpl<$Res, UserGrowthData>;
  @useResult
  $Res call({DateTime date, int newUsers, int totalUsers});
}

/// @nodoc
class _$UserGrowthDataCopyWithImpl<$Res, $Val extends UserGrowthData>
    implements $UserGrowthDataCopyWith<$Res> {
  _$UserGrowthDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGrowthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? newUsers = null,
    Object? totalUsers = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            newUsers: null == newUsers
                ? _value.newUsers
                : newUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalUsers: null == totalUsers
                ? _value.totalUsers
                : totalUsers // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserGrowthDataImplCopyWith<$Res>
    implements $UserGrowthDataCopyWith<$Res> {
  factory _$$UserGrowthDataImplCopyWith(
    _$UserGrowthDataImpl value,
    $Res Function(_$UserGrowthDataImpl) then,
  ) = __$$UserGrowthDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int newUsers, int totalUsers});
}

/// @nodoc
class __$$UserGrowthDataImplCopyWithImpl<$Res>
    extends _$UserGrowthDataCopyWithImpl<$Res, _$UserGrowthDataImpl>
    implements _$$UserGrowthDataImplCopyWith<$Res> {
  __$$UserGrowthDataImplCopyWithImpl(
    _$UserGrowthDataImpl _value,
    $Res Function(_$UserGrowthDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserGrowthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? newUsers = null,
    Object? totalUsers = null,
  }) {
    return _then(
      _$UserGrowthDataImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        newUsers: null == newUsers
            ? _value.newUsers
            : newUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalUsers: null == totalUsers
            ? _value.totalUsers
            : totalUsers // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserGrowthDataImpl implements _UserGrowthData {
  const _$UserGrowthDataImpl({
    required this.date,
    required this.newUsers,
    required this.totalUsers,
  });

  factory _$UserGrowthDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserGrowthDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int newUsers;
  @override
  final int totalUsers;

  @override
  String toString() {
    return 'UserGrowthData(date: $date, newUsers: $newUsers, totalUsers: $totalUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGrowthDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.newUsers, newUsers) ||
                other.newUsers == newUsers) &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, newUsers, totalUsers);

  /// Create a copy of UserGrowthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGrowthDataImplCopyWith<_$UserGrowthDataImpl> get copyWith =>
      __$$UserGrowthDataImplCopyWithImpl<_$UserGrowthDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserGrowthDataImplToJson(this);
  }
}

abstract class _UserGrowthData implements UserGrowthData {
  const factory _UserGrowthData({
    required final DateTime date,
    required final int newUsers,
    required final int totalUsers,
  }) = _$UserGrowthDataImpl;

  factory _UserGrowthData.fromJson(Map<String, dynamic> json) =
      _$UserGrowthDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get newUsers;
  @override
  int get totalUsers;

  /// Create a copy of UserGrowthData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGrowthDataImplCopyWith<_$UserGrowthDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserActivityData _$UserActivityDataFromJson(Map<String, dynamic> json) {
  return _UserActivityData.fromJson(json);
}

/// @nodoc
mixin _$UserActivityData {
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get activeUsers => throw _privateConstructorUsedError;
  int get loginCount => throw _privateConstructorUsedError;

  /// Serializes this UserActivityData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserActivityData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserActivityDataCopyWith<UserActivityData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserActivityDataCopyWith<$Res> {
  factory $UserActivityDataCopyWith(
    UserActivityData value,
    $Res Function(UserActivityData) then,
  ) = _$UserActivityDataCopyWithImpl<$Res, UserActivityData>;
  @useResult
  $Res call({DateTime timestamp, int activeUsers, int loginCount});
}

/// @nodoc
class _$UserActivityDataCopyWithImpl<$Res, $Val extends UserActivityData>
    implements $UserActivityDataCopyWith<$Res> {
  _$UserActivityDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserActivityData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? activeUsers = null,
    Object? loginCount = null,
  }) {
    return _then(
      _value.copyWith(
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            activeUsers: null == activeUsers
                ? _value.activeUsers
                : activeUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            loginCount: null == loginCount
                ? _value.loginCount
                : loginCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserActivityDataImplCopyWith<$Res>
    implements $UserActivityDataCopyWith<$Res> {
  factory _$$UserActivityDataImplCopyWith(
    _$UserActivityDataImpl value,
    $Res Function(_$UserActivityDataImpl) then,
  ) = __$$UserActivityDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime timestamp, int activeUsers, int loginCount});
}

/// @nodoc
class __$$UserActivityDataImplCopyWithImpl<$Res>
    extends _$UserActivityDataCopyWithImpl<$Res, _$UserActivityDataImpl>
    implements _$$UserActivityDataImplCopyWith<$Res> {
  __$$UserActivityDataImplCopyWithImpl(
    _$UserActivityDataImpl _value,
    $Res Function(_$UserActivityDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserActivityData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? activeUsers = null,
    Object? loginCount = null,
  }) {
    return _then(
      _$UserActivityDataImpl(
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        activeUsers: null == activeUsers
            ? _value.activeUsers
            : activeUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        loginCount: null == loginCount
            ? _value.loginCount
            : loginCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserActivityDataImpl implements _UserActivityData {
  const _$UserActivityDataImpl({
    required this.timestamp,
    required this.activeUsers,
    required this.loginCount,
  });

  factory _$UserActivityDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserActivityDataImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final int activeUsers;
  @override
  final int loginCount;

  @override
  String toString() {
    return 'UserActivityData(timestamp: $timestamp, activeUsers: $activeUsers, loginCount: $loginCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserActivityDataImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            (identical(other.loginCount, loginCount) ||
                other.loginCount == loginCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, timestamp, activeUsers, loginCount);

  /// Create a copy of UserActivityData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserActivityDataImplCopyWith<_$UserActivityDataImpl> get copyWith =>
      __$$UserActivityDataImplCopyWithImpl<_$UserActivityDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserActivityDataImplToJson(this);
  }
}

abstract class _UserActivityData implements UserActivityData {
  const factory _UserActivityData({
    required final DateTime timestamp,
    required final int activeUsers,
    required final int loginCount,
  }) = _$UserActivityDataImpl;

  factory _UserActivityData.fromJson(Map<String, dynamic> json) =
      _$UserActivityDataImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  int get activeUsers;
  @override
  int get loginCount;

  /// Create a copy of UserActivityData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserActivityDataImplCopyWith<_$UserActivityDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginTrendData _$LoginTrendDataFromJson(Map<String, dynamic> json) {
  return _LoginTrendData.fromJson(json);
}

/// @nodoc
mixin _$LoginTrendData {
  DateTime get date => throw _privateConstructorUsedError;
  int get successful => throw _privateConstructorUsedError;
  int get failed => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this LoginTrendData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginTrendData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginTrendDataCopyWith<LoginTrendData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginTrendDataCopyWith<$Res> {
  factory $LoginTrendDataCopyWith(
    LoginTrendData value,
    $Res Function(LoginTrendData) then,
  ) = _$LoginTrendDataCopyWithImpl<$Res, LoginTrendData>;
  @useResult
  $Res call({DateTime date, int successful, int failed, int total});
}

/// @nodoc
class _$LoginTrendDataCopyWithImpl<$Res, $Val extends LoginTrendData>
    implements $LoginTrendDataCopyWith<$Res> {
  _$LoginTrendDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginTrendData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? successful = null,
    Object? failed = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            successful: null == successful
                ? _value.successful
                : successful // ignore: cast_nullable_to_non_nullable
                      as int,
            failed: null == failed
                ? _value.failed
                : failed // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginTrendDataImplCopyWith<$Res>
    implements $LoginTrendDataCopyWith<$Res> {
  factory _$$LoginTrendDataImplCopyWith(
    _$LoginTrendDataImpl value,
    $Res Function(_$LoginTrendDataImpl) then,
  ) = __$$LoginTrendDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int successful, int failed, int total});
}

/// @nodoc
class __$$LoginTrendDataImplCopyWithImpl<$Res>
    extends _$LoginTrendDataCopyWithImpl<$Res, _$LoginTrendDataImpl>
    implements _$$LoginTrendDataImplCopyWith<$Res> {
  __$$LoginTrendDataImplCopyWithImpl(
    _$LoginTrendDataImpl _value,
    $Res Function(_$LoginTrendDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginTrendData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? successful = null,
    Object? failed = null,
    Object? total = null,
  }) {
    return _then(
      _$LoginTrendDataImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        successful: null == successful
            ? _value.successful
            : successful // ignore: cast_nullable_to_non_nullable
                  as int,
        failed: null == failed
            ? _value.failed
            : failed // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginTrendDataImpl implements _LoginTrendData {
  const _$LoginTrendDataImpl({
    required this.date,
    required this.successful,
    required this.failed,
    required this.total,
  });

  factory _$LoginTrendDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginTrendDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int successful;
  @override
  final int failed;
  @override
  final int total;

  @override
  String toString() {
    return 'LoginTrendData(date: $date, successful: $successful, failed: $failed, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginTrendDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.successful, successful) ||
                other.successful == successful) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, successful, failed, total);

  /// Create a copy of LoginTrendData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginTrendDataImplCopyWith<_$LoginTrendDataImpl> get copyWith =>
      __$$LoginTrendDataImplCopyWithImpl<_$LoginTrendDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginTrendDataImplToJson(this);
  }
}

abstract class _LoginTrendData implements LoginTrendData {
  const factory _LoginTrendData({
    required final DateTime date,
    required final int successful,
    required final int failed,
    required final int total,
  }) = _$LoginTrendDataImpl;

  factory _LoginTrendData.fromJson(Map<String, dynamic> json) =
      _$LoginTrendDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get successful;
  @override
  int get failed;
  @override
  int get total;

  /// Create a copy of LoginTrendData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginTrendDataImplCopyWith<_$LoginTrendDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthMethodUsage _$AuthMethodUsageFromJson(Map<String, dynamic> json) {
  return _AuthMethodUsage.fromJson(json);
}

/// @nodoc
mixin _$AuthMethodUsage {
  String get method => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;

  /// Serializes this AuthMethodUsage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthMethodUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthMethodUsageCopyWith<AuthMethodUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthMethodUsageCopyWith<$Res> {
  factory $AuthMethodUsageCopyWith(
    AuthMethodUsage value,
    $Res Function(AuthMethodUsage) then,
  ) = _$AuthMethodUsageCopyWithImpl<$Res, AuthMethodUsage>;
  @useResult
  $Res call({String method, int count, double percentage, String displayName});
}

/// @nodoc
class _$AuthMethodUsageCopyWithImpl<$Res, $Val extends AuthMethodUsage>
    implements $AuthMethodUsageCopyWith<$Res> {
  _$AuthMethodUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthMethodUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? count = null,
    Object? percentage = null,
    Object? displayName = null,
  }) {
    return _then(
      _value.copyWith(
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthMethodUsageImplCopyWith<$Res>
    implements $AuthMethodUsageCopyWith<$Res> {
  factory _$$AuthMethodUsageImplCopyWith(
    _$AuthMethodUsageImpl value,
    $Res Function(_$AuthMethodUsageImpl) then,
  ) = __$$AuthMethodUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String method, int count, double percentage, String displayName});
}

/// @nodoc
class __$$AuthMethodUsageImplCopyWithImpl<$Res>
    extends _$AuthMethodUsageCopyWithImpl<$Res, _$AuthMethodUsageImpl>
    implements _$$AuthMethodUsageImplCopyWith<$Res> {
  __$$AuthMethodUsageImplCopyWithImpl(
    _$AuthMethodUsageImpl _value,
    $Res Function(_$AuthMethodUsageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthMethodUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? count = null,
    Object? percentage = null,
    Object? displayName = null,
  }) {
    return _then(
      _$AuthMethodUsageImpl(
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthMethodUsageImpl implements _AuthMethodUsage {
  const _$AuthMethodUsageImpl({
    required this.method,
    required this.count,
    required this.percentage,
    required this.displayName,
  });

  factory _$AuthMethodUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthMethodUsageImplFromJson(json);

  @override
  final String method;
  @override
  final int count;
  @override
  final double percentage;
  @override
  final String displayName;

  @override
  String toString() {
    return 'AuthMethodUsage(method: $method, count: $count, percentage: $percentage, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthMethodUsageImpl &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, method, count, percentage, displayName);

  /// Create a copy of AuthMethodUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthMethodUsageImplCopyWith<_$AuthMethodUsageImpl> get copyWith =>
      __$$AuthMethodUsageImplCopyWithImpl<_$AuthMethodUsageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthMethodUsageImplToJson(this);
  }
}

abstract class _AuthMethodUsage implements AuthMethodUsage {
  const factory _AuthMethodUsage({
    required final String method,
    required final int count,
    required final double percentage,
    required final String displayName,
  }) = _$AuthMethodUsageImpl;

  factory _AuthMethodUsage.fromJson(Map<String, dynamic> json) =
      _$AuthMethodUsageImpl.fromJson;

  @override
  String get method;
  @override
  int get count;
  @override
  double get percentage;
  @override
  String get displayName;

  /// Create a copy of AuthMethodUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthMethodUsageImplCopyWith<_$AuthMethodUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SecurityIncident _$SecurityIncidentFromJson(Map<String, dynamic> json) {
  return _SecurityIncident.fromJson(json);
}

/// @nodoc
mixin _$SecurityIncident {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this SecurityIncident to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityIncident
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityIncidentCopyWith<SecurityIncident> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityIncidentCopyWith<$Res> {
  factory $SecurityIncidentCopyWith(
    SecurityIncident value,
    $Res Function(SecurityIncident) then,
  ) = _$SecurityIncidentCopyWithImpl<$Res, SecurityIncident>;
  @useResult
  $Res call({
    String id,
    String type,
    String severity,
    String description,
    DateTime timestamp,
    String status,
    String? userId,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$SecurityIncidentCopyWithImpl<$Res, $Val extends SecurityIncident>
    implements $SecurityIncidentCopyWith<$Res> {
  _$SecurityIncidentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityIncident
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? description = null,
    Object? timestamp = null,
    Object? status = null,
    Object? userId = freezed,
    Object? ipAddress = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SecurityIncidentImplCopyWith<$Res>
    implements $SecurityIncidentCopyWith<$Res> {
  factory _$$SecurityIncidentImplCopyWith(
    _$SecurityIncidentImpl value,
    $Res Function(_$SecurityIncidentImpl) then,
  ) = __$$SecurityIncidentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String severity,
    String description,
    DateTime timestamp,
    String status,
    String? userId,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$SecurityIncidentImplCopyWithImpl<$Res>
    extends _$SecurityIncidentCopyWithImpl<$Res, _$SecurityIncidentImpl>
    implements _$$SecurityIncidentImplCopyWith<$Res> {
  __$$SecurityIncidentImplCopyWithImpl(
    _$SecurityIncidentImpl _value,
    $Res Function(_$SecurityIncidentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityIncident
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? description = null,
    Object? timestamp = null,
    Object? status = null,
    Object? userId = freezed,
    Object? ipAddress = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$SecurityIncidentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
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
class _$SecurityIncidentImpl implements _SecurityIncident {
  const _$SecurityIncidentImpl({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.timestamp,
    required this.status,
    this.userId,
    this.ipAddress,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$SecurityIncidentImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityIncidentImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String severity;
  @override
  final String description;
  @override
  final DateTime timestamp;
  @override
  final String status;
  @override
  final String? userId;
  @override
  final String? ipAddress;
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
    return 'SecurityIncident(id: $id, type: $type, severity: $severity, description: $description, timestamp: $timestamp, status: $status, userId: $userId, ipAddress: $ipAddress, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityIncidentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    severity,
    description,
    timestamp,
    status,
    userId,
    ipAddress,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of SecurityIncident
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityIncidentImplCopyWith<_$SecurityIncidentImpl> get copyWith =>
      __$$SecurityIncidentImplCopyWithImpl<_$SecurityIncidentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityIncidentImplToJson(this);
  }
}

abstract class _SecurityIncident implements SecurityIncident {
  const factory _SecurityIncident({
    required final String id,
    required final String type,
    required final String severity,
    required final String description,
    required final DateTime timestamp,
    required final String status,
    final String? userId,
    final String? ipAddress,
    final Map<String, dynamic>? metadata,
  }) = _$SecurityIncidentImpl;

  factory _SecurityIncident.fromJson(Map<String, dynamic> json) =
      _$SecurityIncidentImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get severity;
  @override
  String get description;
  @override
  DateTime get timestamp;
  @override
  String get status;
  @override
  String? get userId;
  @override
  String? get ipAddress;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of SecurityIncident
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityIncidentImplCopyWith<_$SecurityIncidentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SecurityTrendData _$SecurityTrendDataFromJson(Map<String, dynamic> json) {
  return _SecurityTrendData.fromJson(json);
}

/// @nodoc
mixin _$SecurityTrendData {
  DateTime get date => throw _privateConstructorUsedError;
  int get incidents => throw _privateConstructorUsedError;
  int get blockedAttempts => throw _privateConstructorUsedError;
  int get suspiciousActivities => throw _privateConstructorUsedError;

  /// Serializes this SecurityTrendData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityTrendData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityTrendDataCopyWith<SecurityTrendData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityTrendDataCopyWith<$Res> {
  factory $SecurityTrendDataCopyWith(
    SecurityTrendData value,
    $Res Function(SecurityTrendData) then,
  ) = _$SecurityTrendDataCopyWithImpl<$Res, SecurityTrendData>;
  @useResult
  $Res call({
    DateTime date,
    int incidents,
    int blockedAttempts,
    int suspiciousActivities,
  });
}

/// @nodoc
class _$SecurityTrendDataCopyWithImpl<$Res, $Val extends SecurityTrendData>
    implements $SecurityTrendDataCopyWith<$Res> {
  _$SecurityTrendDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityTrendData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? incidents = null,
    Object? blockedAttempts = null,
    Object? suspiciousActivities = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            incidents: null == incidents
                ? _value.incidents
                : incidents // ignore: cast_nullable_to_non_nullable
                      as int,
            blockedAttempts: null == blockedAttempts
                ? _value.blockedAttempts
                : blockedAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            suspiciousActivities: null == suspiciousActivities
                ? _value.suspiciousActivities
                : suspiciousActivities // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecurityTrendDataImplCopyWith<$Res>
    implements $SecurityTrendDataCopyWith<$Res> {
  factory _$$SecurityTrendDataImplCopyWith(
    _$SecurityTrendDataImpl value,
    $Res Function(_$SecurityTrendDataImpl) then,
  ) = __$$SecurityTrendDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    int incidents,
    int blockedAttempts,
    int suspiciousActivities,
  });
}

/// @nodoc
class __$$SecurityTrendDataImplCopyWithImpl<$Res>
    extends _$SecurityTrendDataCopyWithImpl<$Res, _$SecurityTrendDataImpl>
    implements _$$SecurityTrendDataImplCopyWith<$Res> {
  __$$SecurityTrendDataImplCopyWithImpl(
    _$SecurityTrendDataImpl _value,
    $Res Function(_$SecurityTrendDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityTrendData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? incidents = null,
    Object? blockedAttempts = null,
    Object? suspiciousActivities = null,
  }) {
    return _then(
      _$SecurityTrendDataImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        incidents: null == incidents
            ? _value.incidents
            : incidents // ignore: cast_nullable_to_non_nullable
                  as int,
        blockedAttempts: null == blockedAttempts
            ? _value.blockedAttempts
            : blockedAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        suspiciousActivities: null == suspiciousActivities
            ? _value.suspiciousActivities
            : suspiciousActivities // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityTrendDataImpl implements _SecurityTrendData {
  const _$SecurityTrendDataImpl({
    required this.date,
    required this.incidents,
    required this.blockedAttempts,
    required this.suspiciousActivities,
  });

  factory _$SecurityTrendDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityTrendDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int incidents;
  @override
  final int blockedAttempts;
  @override
  final int suspiciousActivities;

  @override
  String toString() {
    return 'SecurityTrendData(date: $date, incidents: $incidents, blockedAttempts: $blockedAttempts, suspiciousActivities: $suspiciousActivities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityTrendDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.incidents, incidents) ||
                other.incidents == incidents) &&
            (identical(other.blockedAttempts, blockedAttempts) ||
                other.blockedAttempts == blockedAttempts) &&
            (identical(other.suspiciousActivities, suspiciousActivities) ||
                other.suspiciousActivities == suspiciousActivities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    incidents,
    blockedAttempts,
    suspiciousActivities,
  );

  /// Create a copy of SecurityTrendData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityTrendDataImplCopyWith<_$SecurityTrendDataImpl> get copyWith =>
      __$$SecurityTrendDataImplCopyWithImpl<_$SecurityTrendDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityTrendDataImplToJson(this);
  }
}

abstract class _SecurityTrendData implements SecurityTrendData {
  const factory _SecurityTrendData({
    required final DateTime date,
    required final int incidents,
    required final int blockedAttempts,
    required final int suspiciousActivities,
  }) = _$SecurityTrendDataImpl;

  factory _SecurityTrendData.fromJson(Map<String, dynamic> json) =
      _$SecurityTrendDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get incidents;
  @override
  int get blockedAttempts;
  @override
  int get suspiciousActivities;

  /// Create a copy of SecurityTrendData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityTrendDataImplCopyWith<_$SecurityTrendDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiUsageTrend _$ApiUsageTrendFromJson(Map<String, dynamic> json) {
  return _ApiUsageTrend.fromJson(json);
}

/// @nodoc
mixin _$ApiUsageTrend {
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get requests => throw _privateConstructorUsedError;
  int get errors => throw _privateConstructorUsedError;
  double get responseTime => throw _privateConstructorUsedError;

  /// Serializes this ApiUsageTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiUsageTrendCopyWith<ApiUsageTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiUsageTrendCopyWith<$Res> {
  factory $ApiUsageTrendCopyWith(
    ApiUsageTrend value,
    $Res Function(ApiUsageTrend) then,
  ) = _$ApiUsageTrendCopyWithImpl<$Res, ApiUsageTrend>;
  @useResult
  $Res call({
    DateTime timestamp,
    int requests,
    int errors,
    double responseTime,
  });
}

/// @nodoc
class _$ApiUsageTrendCopyWithImpl<$Res, $Val extends ApiUsageTrend>
    implements $ApiUsageTrendCopyWith<$Res> {
  _$ApiUsageTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? requests = null,
    Object? errors = null,
    Object? responseTime = null,
  }) {
    return _then(
      _value.copyWith(
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            requests: null == requests
                ? _value.requests
                : requests // ignore: cast_nullable_to_non_nullable
                      as int,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as int,
            responseTime: null == responseTime
                ? _value.responseTime
                : responseTime // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiUsageTrendImplCopyWith<$Res>
    implements $ApiUsageTrendCopyWith<$Res> {
  factory _$$ApiUsageTrendImplCopyWith(
    _$ApiUsageTrendImpl value,
    $Res Function(_$ApiUsageTrendImpl) then,
  ) = __$$ApiUsageTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime timestamp,
    int requests,
    int errors,
    double responseTime,
  });
}

/// @nodoc
class __$$ApiUsageTrendImplCopyWithImpl<$Res>
    extends _$ApiUsageTrendCopyWithImpl<$Res, _$ApiUsageTrendImpl>
    implements _$$ApiUsageTrendImplCopyWith<$Res> {
  __$$ApiUsageTrendImplCopyWithImpl(
    _$ApiUsageTrendImpl _value,
    $Res Function(_$ApiUsageTrendImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? requests = null,
    Object? errors = null,
    Object? responseTime = null,
  }) {
    return _then(
      _$ApiUsageTrendImpl(
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        requests: null == requests
            ? _value.requests
            : requests // ignore: cast_nullable_to_non_nullable
                  as int,
        errors: null == errors
            ? _value.errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as int,
        responseTime: null == responseTime
            ? _value.responseTime
            : responseTime // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiUsageTrendImpl implements _ApiUsageTrend {
  const _$ApiUsageTrendImpl({
    required this.timestamp,
    required this.requests,
    required this.errors,
    required this.responseTime,
  });

  factory _$ApiUsageTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiUsageTrendImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final int requests;
  @override
  final int errors;
  @override
  final double responseTime;

  @override
  String toString() {
    return 'ApiUsageTrend(timestamp: $timestamp, requests: $requests, errors: $errors, responseTime: $responseTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiUsageTrendImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.requests, requests) ||
                other.requests == requests) &&
            (identical(other.errors, errors) || other.errors == errors) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, timestamp, requests, errors, responseTime);

  /// Create a copy of ApiUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiUsageTrendImplCopyWith<_$ApiUsageTrendImpl> get copyWith =>
      __$$ApiUsageTrendImplCopyWithImpl<_$ApiUsageTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiUsageTrendImplToJson(this);
  }
}

abstract class _ApiUsageTrend implements ApiUsageTrend {
  const factory _ApiUsageTrend({
    required final DateTime timestamp,
    required final int requests,
    required final int errors,
    required final double responseTime,
  }) = _$ApiUsageTrendImpl;

  factory _ApiUsageTrend.fromJson(Map<String, dynamic> json) =
      _$ApiUsageTrendImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  int get requests;
  @override
  int get errors;
  @override
  double get responseTime;

  /// Create a copy of ApiUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiUsageTrendImplCopyWith<_$ApiUsageTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EndpointPerformance _$EndpointPerformanceFromJson(Map<String, dynamic> json) {
  return _EndpointPerformance.fromJson(json);
}

/// @nodoc
mixin _$EndpointPerformance {
  String get endpoint => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  int get requestCount => throw _privateConstructorUsedError;
  double get averageResponseTime => throw _privateConstructorUsedError;
  int get errorCount => throw _privateConstructorUsedError;
  double get errorRate => throw _privateConstructorUsedError;

  /// Serializes this EndpointPerformance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EndpointPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EndpointPerformanceCopyWith<EndpointPerformance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EndpointPerformanceCopyWith<$Res> {
  factory $EndpointPerformanceCopyWith(
    EndpointPerformance value,
    $Res Function(EndpointPerformance) then,
  ) = _$EndpointPerformanceCopyWithImpl<$Res, EndpointPerformance>;
  @useResult
  $Res call({
    String endpoint,
    String method,
    int requestCount,
    double averageResponseTime,
    int errorCount,
    double errorRate,
  });
}

/// @nodoc
class _$EndpointPerformanceCopyWithImpl<$Res, $Val extends EndpointPerformance>
    implements $EndpointPerformanceCopyWith<$Res> {
  _$EndpointPerformanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EndpointPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endpoint = null,
    Object? method = null,
    Object? requestCount = null,
    Object? averageResponseTime = null,
    Object? errorCount = null,
    Object? errorRate = null,
  }) {
    return _then(
      _value.copyWith(
            endpoint: null == endpoint
                ? _value.endpoint
                : endpoint // ignore: cast_nullable_to_non_nullable
                      as String,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            requestCount: null == requestCount
                ? _value.requestCount
                : requestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            averageResponseTime: null == averageResponseTime
                ? _value.averageResponseTime
                : averageResponseTime // ignore: cast_nullable_to_non_nullable
                      as double,
            errorCount: null == errorCount
                ? _value.errorCount
                : errorCount // ignore: cast_nullable_to_non_nullable
                      as int,
            errorRate: null == errorRate
                ? _value.errorRate
                : errorRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EndpointPerformanceImplCopyWith<$Res>
    implements $EndpointPerformanceCopyWith<$Res> {
  factory _$$EndpointPerformanceImplCopyWith(
    _$EndpointPerformanceImpl value,
    $Res Function(_$EndpointPerformanceImpl) then,
  ) = __$$EndpointPerformanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String endpoint,
    String method,
    int requestCount,
    double averageResponseTime,
    int errorCount,
    double errorRate,
  });
}

/// @nodoc
class __$$EndpointPerformanceImplCopyWithImpl<$Res>
    extends _$EndpointPerformanceCopyWithImpl<$Res, _$EndpointPerformanceImpl>
    implements _$$EndpointPerformanceImplCopyWith<$Res> {
  __$$EndpointPerformanceImplCopyWithImpl(
    _$EndpointPerformanceImpl _value,
    $Res Function(_$EndpointPerformanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EndpointPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endpoint = null,
    Object? method = null,
    Object? requestCount = null,
    Object? averageResponseTime = null,
    Object? errorCount = null,
    Object? errorRate = null,
  }) {
    return _then(
      _$EndpointPerformanceImpl(
        endpoint: null == endpoint
            ? _value.endpoint
            : endpoint // ignore: cast_nullable_to_non_nullable
                  as String,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        requestCount: null == requestCount
            ? _value.requestCount
            : requestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        averageResponseTime: null == averageResponseTime
            ? _value.averageResponseTime
            : averageResponseTime // ignore: cast_nullable_to_non_nullable
                  as double,
        errorCount: null == errorCount
            ? _value.errorCount
            : errorCount // ignore: cast_nullable_to_non_nullable
                  as int,
        errorRate: null == errorRate
            ? _value.errorRate
            : errorRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EndpointPerformanceImpl implements _EndpointPerformance {
  const _$EndpointPerformanceImpl({
    required this.endpoint,
    required this.method,
    required this.requestCount,
    required this.averageResponseTime,
    required this.errorCount,
    required this.errorRate,
  });

  factory _$EndpointPerformanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$EndpointPerformanceImplFromJson(json);

  @override
  final String endpoint;
  @override
  final String method;
  @override
  final int requestCount;
  @override
  final double averageResponseTime;
  @override
  final int errorCount;
  @override
  final double errorRate;

  @override
  String toString() {
    return 'EndpointPerformance(endpoint: $endpoint, method: $method, requestCount: $requestCount, averageResponseTime: $averageResponseTime, errorCount: $errorCount, errorRate: $errorRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EndpointPerformanceImpl &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.requestCount, requestCount) ||
                other.requestCount == requestCount) &&
            (identical(other.averageResponseTime, averageResponseTime) ||
                other.averageResponseTime == averageResponseTime) &&
            (identical(other.errorCount, errorCount) ||
                other.errorCount == errorCount) &&
            (identical(other.errorRate, errorRate) ||
                other.errorRate == errorRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    endpoint,
    method,
    requestCount,
    averageResponseTime,
    errorCount,
    errorRate,
  );

  /// Create a copy of EndpointPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EndpointPerformanceImplCopyWith<_$EndpointPerformanceImpl> get copyWith =>
      __$$EndpointPerformanceImplCopyWithImpl<_$EndpointPerformanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EndpointPerformanceImplToJson(this);
  }
}

abstract class _EndpointPerformance implements EndpointPerformance {
  const factory _EndpointPerformance({
    required final String endpoint,
    required final String method,
    required final int requestCount,
    required final double averageResponseTime,
    required final int errorCount,
    required final double errorRate,
  }) = _$EndpointPerformanceImpl;

  factory _EndpointPerformance.fromJson(Map<String, dynamic> json) =
      _$EndpointPerformanceImpl.fromJson;

  @override
  String get endpoint;
  @override
  String get method;
  @override
  int get requestCount;
  @override
  double get averageResponseTime;
  @override
  int get errorCount;
  @override
  double get errorRate;

  /// Create a copy of EndpointPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EndpointPerformanceImplCopyWith<_$EndpointPerformanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PerformanceMetric _$PerformanceMetricFromJson(Map<String, dynamic> json) {
  return _PerformanceMetric.fromJson(json);
}

/// @nodoc
mixin _$PerformanceMetric {
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get cpuUsage => throw _privateConstructorUsedError;
  double get memoryUsage => throw _privateConstructorUsedError;
  double get responseTime => throw _privateConstructorUsedError;
  int get activeConnections => throw _privateConstructorUsedError;

  /// Serializes this PerformanceMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PerformanceMetricCopyWith<PerformanceMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceMetricCopyWith<$Res> {
  factory $PerformanceMetricCopyWith(
    PerformanceMetric value,
    $Res Function(PerformanceMetric) then,
  ) = _$PerformanceMetricCopyWithImpl<$Res, PerformanceMetric>;
  @useResult
  $Res call({
    DateTime timestamp,
    double cpuUsage,
    double memoryUsage,
    double responseTime,
    int activeConnections,
  });
}

/// @nodoc
class _$PerformanceMetricCopyWithImpl<$Res, $Val extends PerformanceMetric>
    implements $PerformanceMetricCopyWith<$Res> {
  _$PerformanceMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? responseTime = null,
    Object? activeConnections = null,
  }) {
    return _then(
      _value.copyWith(
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            cpuUsage: null == cpuUsage
                ? _value.cpuUsage
                : cpuUsage // ignore: cast_nullable_to_non_nullable
                      as double,
            memoryUsage: null == memoryUsage
                ? _value.memoryUsage
                : memoryUsage // ignore: cast_nullable_to_non_nullable
                      as double,
            responseTime: null == responseTime
                ? _value.responseTime
                : responseTime // ignore: cast_nullable_to_non_nullable
                      as double,
            activeConnections: null == activeConnections
                ? _value.activeConnections
                : activeConnections // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PerformanceMetricImplCopyWith<$Res>
    implements $PerformanceMetricCopyWith<$Res> {
  factory _$$PerformanceMetricImplCopyWith(
    _$PerformanceMetricImpl value,
    $Res Function(_$PerformanceMetricImpl) then,
  ) = __$$PerformanceMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime timestamp,
    double cpuUsage,
    double memoryUsage,
    double responseTime,
    int activeConnections,
  });
}

/// @nodoc
class __$$PerformanceMetricImplCopyWithImpl<$Res>
    extends _$PerformanceMetricCopyWithImpl<$Res, _$PerformanceMetricImpl>
    implements _$$PerformanceMetricImplCopyWith<$Res> {
  __$$PerformanceMetricImplCopyWithImpl(
    _$PerformanceMetricImpl _value,
    $Res Function(_$PerformanceMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? cpuUsage = null,
    Object? memoryUsage = null,
    Object? responseTime = null,
    Object? activeConnections = null,
  }) {
    return _then(
      _$PerformanceMetricImpl(
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        cpuUsage: null == cpuUsage
            ? _value.cpuUsage
            : cpuUsage // ignore: cast_nullable_to_non_nullable
                  as double,
        memoryUsage: null == memoryUsage
            ? _value.memoryUsage
            : memoryUsage // ignore: cast_nullable_to_non_nullable
                  as double,
        responseTime: null == responseTime
            ? _value.responseTime
            : responseTime // ignore: cast_nullable_to_non_nullable
                  as double,
        activeConnections: null == activeConnections
            ? _value.activeConnections
            : activeConnections // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PerformanceMetricImpl implements _PerformanceMetric {
  const _$PerformanceMetricImpl({
    required this.timestamp,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.responseTime,
    required this.activeConnections,
  });

  factory _$PerformanceMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerformanceMetricImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final double cpuUsage;
  @override
  final double memoryUsage;
  @override
  final double responseTime;
  @override
  final int activeConnections;

  @override
  String toString() {
    return 'PerformanceMetric(timestamp: $timestamp, cpuUsage: $cpuUsage, memoryUsage: $memoryUsage, responseTime: $responseTime, activeConnections: $activeConnections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceMetricImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.cpuUsage, cpuUsage) ||
                other.cpuUsage == cpuUsage) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.activeConnections, activeConnections) ||
                other.activeConnections == activeConnections));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    timestamp,
    cpuUsage,
    memoryUsage,
    responseTime,
    activeConnections,
  );

  /// Create a copy of PerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceMetricImplCopyWith<_$PerformanceMetricImpl> get copyWith =>
      __$$PerformanceMetricImplCopyWithImpl<_$PerformanceMetricImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PerformanceMetricImplToJson(this);
  }
}

abstract class _PerformanceMetric implements PerformanceMetric {
  const factory _PerformanceMetric({
    required final DateTime timestamp,
    required final double cpuUsage,
    required final double memoryUsage,
    required final double responseTime,
    required final int activeConnections,
  }) = _$PerformanceMetricImpl;

  factory _PerformanceMetric.fromJson(Map<String, dynamic> json) =
      _$PerformanceMetricImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  double get cpuUsage;
  @override
  double get memoryUsage;
  @override
  double get responseTime;
  @override
  int get activeConnections;

  /// Create a copy of PerformanceMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PerformanceMetricImplCopyWith<_$PerformanceMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnalyticsTimeRange _$AnalyticsTimeRangeFromJson(Map<String, dynamic> json) {
  return _AnalyticsTimeRange.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsTimeRange {
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;

  /// Serializes this AnalyticsTimeRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsTimeRangeCopyWith<AnalyticsTimeRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsTimeRangeCopyWith<$Res> {
  factory $AnalyticsTimeRangeCopyWith(
    AnalyticsTimeRange value,
    $Res Function(AnalyticsTimeRange) then,
  ) = _$AnalyticsTimeRangeCopyWithImpl<$Res, AnalyticsTimeRange>;
  @useResult
  $Res call({DateTime startDate, DateTime endDate, String displayName});
}

/// @nodoc
class _$AnalyticsTimeRangeCopyWithImpl<$Res, $Val extends AnalyticsTimeRange>
    implements $AnalyticsTimeRangeCopyWith<$Res> {
  _$AnalyticsTimeRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? displayName = null,
  }) {
    return _then(
      _value.copyWith(
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnalyticsTimeRangeImplCopyWith<$Res>
    implements $AnalyticsTimeRangeCopyWith<$Res> {
  factory _$$AnalyticsTimeRangeImplCopyWith(
    _$AnalyticsTimeRangeImpl value,
    $Res Function(_$AnalyticsTimeRangeImpl) then,
  ) = __$$AnalyticsTimeRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime startDate, DateTime endDate, String displayName});
}

/// @nodoc
class __$$AnalyticsTimeRangeImplCopyWithImpl<$Res>
    extends _$AnalyticsTimeRangeCopyWithImpl<$Res, _$AnalyticsTimeRangeImpl>
    implements _$$AnalyticsTimeRangeImplCopyWith<$Res> {
  __$$AnalyticsTimeRangeImplCopyWithImpl(
    _$AnalyticsTimeRangeImpl _value,
    $Res Function(_$AnalyticsTimeRangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalyticsTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? displayName = null,
  }) {
    return _then(
      _$AnalyticsTimeRangeImpl(
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsTimeRangeImpl implements _AnalyticsTimeRange {
  const _$AnalyticsTimeRangeImpl({
    required this.startDate,
    required this.endDate,
    required this.displayName,
  });

  factory _$AnalyticsTimeRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsTimeRangeImplFromJson(json);

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String displayName;

  @override
  String toString() {
    return 'AnalyticsTimeRange(startDate: $startDate, endDate: $endDate, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsTimeRangeImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate, displayName);

  /// Create a copy of AnalyticsTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsTimeRangeImplCopyWith<_$AnalyticsTimeRangeImpl> get copyWith =>
      __$$AnalyticsTimeRangeImplCopyWithImpl<_$AnalyticsTimeRangeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsTimeRangeImplToJson(this);
  }
}

abstract class _AnalyticsTimeRange implements AnalyticsTimeRange {
  const factory _AnalyticsTimeRange({
    required final DateTime startDate,
    required final DateTime endDate,
    required final String displayName,
  }) = _$AnalyticsTimeRangeImpl;

  factory _AnalyticsTimeRange.fromJson(Map<String, dynamic> json) =
      _$AnalyticsTimeRangeImpl.fromJson;

  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get displayName;

  /// Create a copy of AnalyticsTimeRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsTimeRangeImplCopyWith<_$AnalyticsTimeRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomAnalyticsQuery _$CustomAnalyticsQueryFromJson(Map<String, dynamic> json) {
  return _CustomAnalyticsQuery.fromJson(json);
}

/// @nodoc
mixin _$CustomAnalyticsQuery {
  String get metric => throw _privateConstructorUsedError;
  String get aggregation => throw _privateConstructorUsedError;
  List<AnalyticsFilter> get filters => throw _privateConstructorUsedError;
  String get timeRange => throw _privateConstructorUsedError;
  String? get groupBy => throw _privateConstructorUsedError;

  /// Serializes this CustomAnalyticsQuery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomAnalyticsQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomAnalyticsQueryCopyWith<CustomAnalyticsQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomAnalyticsQueryCopyWith<$Res> {
  factory $CustomAnalyticsQueryCopyWith(
    CustomAnalyticsQuery value,
    $Res Function(CustomAnalyticsQuery) then,
  ) = _$CustomAnalyticsQueryCopyWithImpl<$Res, CustomAnalyticsQuery>;
  @useResult
  $Res call({
    String metric,
    String aggregation,
    List<AnalyticsFilter> filters,
    String timeRange,
    String? groupBy,
  });
}

/// @nodoc
class _$CustomAnalyticsQueryCopyWithImpl<
  $Res,
  $Val extends CustomAnalyticsQuery
>
    implements $CustomAnalyticsQueryCopyWith<$Res> {
  _$CustomAnalyticsQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomAnalyticsQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? aggregation = null,
    Object? filters = null,
    Object? timeRange = null,
    Object? groupBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            metric: null == metric
                ? _value.metric
                : metric // ignore: cast_nullable_to_non_nullable
                      as String,
            aggregation: null == aggregation
                ? _value.aggregation
                : aggregation // ignore: cast_nullable_to_non_nullable
                      as String,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as List<AnalyticsFilter>,
            timeRange: null == timeRange
                ? _value.timeRange
                : timeRange // ignore: cast_nullable_to_non_nullable
                      as String,
            groupBy: freezed == groupBy
                ? _value.groupBy
                : groupBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomAnalyticsQueryImplCopyWith<$Res>
    implements $CustomAnalyticsQueryCopyWith<$Res> {
  factory _$$CustomAnalyticsQueryImplCopyWith(
    _$CustomAnalyticsQueryImpl value,
    $Res Function(_$CustomAnalyticsQueryImpl) then,
  ) = __$$CustomAnalyticsQueryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String metric,
    String aggregation,
    List<AnalyticsFilter> filters,
    String timeRange,
    String? groupBy,
  });
}

/// @nodoc
class __$$CustomAnalyticsQueryImplCopyWithImpl<$Res>
    extends _$CustomAnalyticsQueryCopyWithImpl<$Res, _$CustomAnalyticsQueryImpl>
    implements _$$CustomAnalyticsQueryImplCopyWith<$Res> {
  __$$CustomAnalyticsQueryImplCopyWithImpl(
    _$CustomAnalyticsQueryImpl _value,
    $Res Function(_$CustomAnalyticsQueryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomAnalyticsQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric = null,
    Object? aggregation = null,
    Object? filters = null,
    Object? timeRange = null,
    Object? groupBy = freezed,
  }) {
    return _then(
      _$CustomAnalyticsQueryImpl(
        metric: null == metric
            ? _value.metric
            : metric // ignore: cast_nullable_to_non_nullable
                  as String,
        aggregation: null == aggregation
            ? _value.aggregation
            : aggregation // ignore: cast_nullable_to_non_nullable
                  as String,
        filters: null == filters
            ? _value._filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as List<AnalyticsFilter>,
        timeRange: null == timeRange
            ? _value.timeRange
            : timeRange // ignore: cast_nullable_to_non_nullable
                  as String,
        groupBy: freezed == groupBy
            ? _value.groupBy
            : groupBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomAnalyticsQueryImpl implements _CustomAnalyticsQuery {
  const _$CustomAnalyticsQueryImpl({
    required this.metric,
    required this.aggregation,
    required final List<AnalyticsFilter> filters,
    required this.timeRange,
    this.groupBy,
  }) : _filters = filters;

  factory _$CustomAnalyticsQueryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomAnalyticsQueryImplFromJson(json);

  @override
  final String metric;
  @override
  final String aggregation;
  final List<AnalyticsFilter> _filters;
  @override
  List<AnalyticsFilter> get filters {
    if (_filters is EqualUnmodifiableListView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filters);
  }

  @override
  final String timeRange;
  @override
  final String? groupBy;

  @override
  String toString() {
    return 'CustomAnalyticsQuery(metric: $metric, aggregation: $aggregation, filters: $filters, timeRange: $timeRange, groupBy: $groupBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomAnalyticsQueryImpl &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.aggregation, aggregation) ||
                other.aggregation == aggregation) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.timeRange, timeRange) ||
                other.timeRange == timeRange) &&
            (identical(other.groupBy, groupBy) || other.groupBy == groupBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    metric,
    aggregation,
    const DeepCollectionEquality().hash(_filters),
    timeRange,
    groupBy,
  );

  /// Create a copy of CustomAnalyticsQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomAnalyticsQueryImplCopyWith<_$CustomAnalyticsQueryImpl>
  get copyWith =>
      __$$CustomAnalyticsQueryImplCopyWithImpl<_$CustomAnalyticsQueryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomAnalyticsQueryImplToJson(this);
  }
}

abstract class _CustomAnalyticsQuery implements CustomAnalyticsQuery {
  const factory _CustomAnalyticsQuery({
    required final String metric,
    required final String aggregation,
    required final List<AnalyticsFilter> filters,
    required final String timeRange,
    final String? groupBy,
  }) = _$CustomAnalyticsQueryImpl;

  factory _CustomAnalyticsQuery.fromJson(Map<String, dynamic> json) =
      _$CustomAnalyticsQueryImpl.fromJson;

  @override
  String get metric;
  @override
  String get aggregation;
  @override
  List<AnalyticsFilter> get filters;
  @override
  String get timeRange;
  @override
  String? get groupBy;

  /// Create a copy of CustomAnalyticsQuery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomAnalyticsQueryImplCopyWith<_$CustomAnalyticsQueryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AnalyticsFilter _$AnalyticsFilterFromJson(Map<String, dynamic> json) {
  return _AnalyticsFilter.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsFilter {
  String get field => throw _privateConstructorUsedError;
  String get operator => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;

  /// Serializes this AnalyticsFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsFilterCopyWith<AnalyticsFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsFilterCopyWith<$Res> {
  factory $AnalyticsFilterCopyWith(
    AnalyticsFilter value,
    $Res Function(AnalyticsFilter) then,
  ) = _$AnalyticsFilterCopyWithImpl<$Res, AnalyticsFilter>;
  @useResult
  $Res call({String field, String operator, dynamic value});
}

/// @nodoc
class _$AnalyticsFilterCopyWithImpl<$Res, $Val extends AnalyticsFilter>
    implements $AnalyticsFilterCopyWith<$Res> {
  _$AnalyticsFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? operator = null,
    Object? value = freezed,
  }) {
    return _then(
      _value.copyWith(
            field: null == field
                ? _value.field
                : field // ignore: cast_nullable_to_non_nullable
                      as String,
            operator: null == operator
                ? _value.operator
                : operator // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnalyticsFilterImplCopyWith<$Res>
    implements $AnalyticsFilterCopyWith<$Res> {
  factory _$$AnalyticsFilterImplCopyWith(
    _$AnalyticsFilterImpl value,
    $Res Function(_$AnalyticsFilterImpl) then,
  ) = __$$AnalyticsFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field, String operator, dynamic value});
}

/// @nodoc
class __$$AnalyticsFilterImplCopyWithImpl<$Res>
    extends _$AnalyticsFilterCopyWithImpl<$Res, _$AnalyticsFilterImpl>
    implements _$$AnalyticsFilterImplCopyWith<$Res> {
  __$$AnalyticsFilterImplCopyWithImpl(
    _$AnalyticsFilterImpl _value,
    $Res Function(_$AnalyticsFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? operator = null,
    Object? value = freezed,
  }) {
    return _then(
      _$AnalyticsFilterImpl(
        field: null == field
            ? _value.field
            : field // ignore: cast_nullable_to_non_nullable
                  as String,
        operator: null == operator
            ? _value.operator
            : operator // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsFilterImpl implements _AnalyticsFilter {
  const _$AnalyticsFilterImpl({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory _$AnalyticsFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsFilterImplFromJson(json);

  @override
  final String field;
  @override
  final String operator;
  @override
  final dynamic value;

  @override
  String toString() {
    return 'AnalyticsFilter(field: $field, operator: $operator, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsFilterImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    field,
    operator,
    const DeepCollectionEquality().hash(value),
  );

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsFilterImplCopyWith<_$AnalyticsFilterImpl> get copyWith =>
      __$$AnalyticsFilterImplCopyWithImpl<_$AnalyticsFilterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsFilterImplToJson(this);
  }
}

abstract class _AnalyticsFilter implements AnalyticsFilter {
  const factory _AnalyticsFilter({
    required final String field,
    required final String operator,
    required final dynamic value,
  }) = _$AnalyticsFilterImpl;

  factory _AnalyticsFilter.fromJson(Map<String, dynamic> json) =
      _$AnalyticsFilterImpl.fromJson;

  @override
  String get field;
  @override
  String get operator;
  @override
  dynamic get value;

  /// Create a copy of AnalyticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsFilterImplCopyWith<_$AnalyticsFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SecurityConfiguration _$SecurityConfigurationFromJson(
  Map<String, dynamic> json,
) {
  return _SecurityConfiguration.fromJson(json);
}

/// @nodoc
mixin _$SecurityConfiguration {
  bool get enableTwoFactor => throw _privateConstructorUsedError;
  bool get enableBiometric => throw _privateConstructorUsedError;
  bool get enableIpBlocking => throw _privateConstructorUsedError;
  bool get enableRateLimit => throw _privateConstructorUsedError;
  int get maxLoginAttempts => throw _privateConstructorUsedError;
  int get sessionTimeout => throw _privateConstructorUsedError;

  /// Serializes this SecurityConfiguration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityConfigurationCopyWith<SecurityConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityConfigurationCopyWith<$Res> {
  factory $SecurityConfigurationCopyWith(
    SecurityConfiguration value,
    $Res Function(SecurityConfiguration) then,
  ) = _$SecurityConfigurationCopyWithImpl<$Res, SecurityConfiguration>;
  @useResult
  $Res call({
    bool enableTwoFactor,
    bool enableBiometric,
    bool enableIpBlocking,
    bool enableRateLimit,
    int maxLoginAttempts,
    int sessionTimeout,
  });
}

/// @nodoc
class _$SecurityConfigurationCopyWithImpl<
  $Res,
  $Val extends SecurityConfiguration
>
    implements $SecurityConfigurationCopyWith<$Res> {
  _$SecurityConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableTwoFactor = null,
    Object? enableBiometric = null,
    Object? enableIpBlocking = null,
    Object? enableRateLimit = null,
    Object? maxLoginAttempts = null,
    Object? sessionTimeout = null,
  }) {
    return _then(
      _value.copyWith(
            enableTwoFactor: null == enableTwoFactor
                ? _value.enableTwoFactor
                : enableTwoFactor // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableBiometric: null == enableBiometric
                ? _value.enableBiometric
                : enableBiometric // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableIpBlocking: null == enableIpBlocking
                ? _value.enableIpBlocking
                : enableIpBlocking // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableRateLimit: null == enableRateLimit
                ? _value.enableRateLimit
                : enableRateLimit // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxLoginAttempts: null == maxLoginAttempts
                ? _value.maxLoginAttempts
                : maxLoginAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            sessionTimeout: null == sessionTimeout
                ? _value.sessionTimeout
                : sessionTimeout // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecurityConfigurationImplCopyWith<$Res>
    implements $SecurityConfigurationCopyWith<$Res> {
  factory _$$SecurityConfigurationImplCopyWith(
    _$SecurityConfigurationImpl value,
    $Res Function(_$SecurityConfigurationImpl) then,
  ) = __$$SecurityConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enableTwoFactor,
    bool enableBiometric,
    bool enableIpBlocking,
    bool enableRateLimit,
    int maxLoginAttempts,
    int sessionTimeout,
  });
}

/// @nodoc
class __$$SecurityConfigurationImplCopyWithImpl<$Res>
    extends
        _$SecurityConfigurationCopyWithImpl<$Res, _$SecurityConfigurationImpl>
    implements _$$SecurityConfigurationImplCopyWith<$Res> {
  __$$SecurityConfigurationImplCopyWithImpl(
    _$SecurityConfigurationImpl _value,
    $Res Function(_$SecurityConfigurationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableTwoFactor = null,
    Object? enableBiometric = null,
    Object? enableIpBlocking = null,
    Object? enableRateLimit = null,
    Object? maxLoginAttempts = null,
    Object? sessionTimeout = null,
  }) {
    return _then(
      _$SecurityConfigurationImpl(
        enableTwoFactor: null == enableTwoFactor
            ? _value.enableTwoFactor
            : enableTwoFactor // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableBiometric: null == enableBiometric
            ? _value.enableBiometric
            : enableBiometric // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableIpBlocking: null == enableIpBlocking
            ? _value.enableIpBlocking
            : enableIpBlocking // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableRateLimit: null == enableRateLimit
            ? _value.enableRateLimit
            : enableRateLimit // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxLoginAttempts: null == maxLoginAttempts
            ? _value.maxLoginAttempts
            : maxLoginAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        sessionTimeout: null == sessionTimeout
            ? _value.sessionTimeout
            : sessionTimeout // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityConfigurationImpl implements _SecurityConfiguration {
  const _$SecurityConfigurationImpl({
    required this.enableTwoFactor,
    required this.enableBiometric,
    required this.enableIpBlocking,
    required this.enableRateLimit,
    required this.maxLoginAttempts,
    required this.sessionTimeout,
  });

  factory _$SecurityConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityConfigurationImplFromJson(json);

  @override
  final bool enableTwoFactor;
  @override
  final bool enableBiometric;
  @override
  final bool enableIpBlocking;
  @override
  final bool enableRateLimit;
  @override
  final int maxLoginAttempts;
  @override
  final int sessionTimeout;

  @override
  String toString() {
    return 'SecurityConfiguration(enableTwoFactor: $enableTwoFactor, enableBiometric: $enableBiometric, enableIpBlocking: $enableIpBlocking, enableRateLimit: $enableRateLimit, maxLoginAttempts: $maxLoginAttempts, sessionTimeout: $sessionTimeout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityConfigurationImpl &&
            (identical(other.enableTwoFactor, enableTwoFactor) ||
                other.enableTwoFactor == enableTwoFactor) &&
            (identical(other.enableBiometric, enableBiometric) ||
                other.enableBiometric == enableBiometric) &&
            (identical(other.enableIpBlocking, enableIpBlocking) ||
                other.enableIpBlocking == enableIpBlocking) &&
            (identical(other.enableRateLimit, enableRateLimit) ||
                other.enableRateLimit == enableRateLimit) &&
            (identical(other.maxLoginAttempts, maxLoginAttempts) ||
                other.maxLoginAttempts == maxLoginAttempts) &&
            (identical(other.sessionTimeout, sessionTimeout) ||
                other.sessionTimeout == sessionTimeout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enableTwoFactor,
    enableBiometric,
    enableIpBlocking,
    enableRateLimit,
    maxLoginAttempts,
    sessionTimeout,
  );

  /// Create a copy of SecurityConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityConfigurationImplCopyWith<_$SecurityConfigurationImpl>
  get copyWith =>
      __$$SecurityConfigurationImplCopyWithImpl<_$SecurityConfigurationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityConfigurationImplToJson(this);
  }
}

abstract class _SecurityConfiguration implements SecurityConfiguration {
  const factory _SecurityConfiguration({
    required final bool enableTwoFactor,
    required final bool enableBiometric,
    required final bool enableIpBlocking,
    required final bool enableRateLimit,
    required final int maxLoginAttempts,
    required final int sessionTimeout,
  }) = _$SecurityConfigurationImpl;

  factory _SecurityConfiguration.fromJson(Map<String, dynamic> json) =
      _$SecurityConfigurationImpl.fromJson;

  @override
  bool get enableTwoFactor;
  @override
  bool get enableBiometric;
  @override
  bool get enableIpBlocking;
  @override
  bool get enableRateLimit;
  @override
  int get maxLoginAttempts;
  @override
  int get sessionTimeout;

  /// Create a copy of SecurityConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityConfigurationImplCopyWith<_$SecurityConfigurationImpl>
  get copyWith => throw _privateConstructorUsedError;
}

IpBlockRule _$IpBlockRuleFromJson(Map<String, dynamic> json) {
  return _IpBlockRule.fromJson(json);
}

/// @nodoc
mixin _$IpBlockRule {
  String get id => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  String get cidr => throw _privateConstructorUsedError;
  IpRuleType get type => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this IpBlockRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IpBlockRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IpBlockRuleCopyWith<IpBlockRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IpBlockRuleCopyWith<$Res> {
  factory $IpBlockRuleCopyWith(
    IpBlockRule value,
    $Res Function(IpBlockRule) then,
  ) = _$IpBlockRuleCopyWithImpl<$Res, IpBlockRule>;
  @useResult
  $Res call({
    String id,
    String ipAddress,
    String cidr,
    IpRuleType type,
    String reason,
    DateTime createdAt,
    DateTime? expiresAt,
    bool isActive,
  });
}

/// @nodoc
class _$IpBlockRuleCopyWithImpl<$Res, $Val extends IpBlockRule>
    implements $IpBlockRuleCopyWith<$Res> {
  _$IpBlockRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IpBlockRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ipAddress = null,
    Object? cidr = null,
    Object? type = null,
    Object? reason = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            cidr: null == cidr
                ? _value.cidr
                : cidr // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as IpRuleType,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IpBlockRuleImplCopyWith<$Res>
    implements $IpBlockRuleCopyWith<$Res> {
  factory _$$IpBlockRuleImplCopyWith(
    _$IpBlockRuleImpl value,
    $Res Function(_$IpBlockRuleImpl) then,
  ) = __$$IpBlockRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ipAddress,
    String cidr,
    IpRuleType type,
    String reason,
    DateTime createdAt,
    DateTime? expiresAt,
    bool isActive,
  });
}

/// @nodoc
class __$$IpBlockRuleImplCopyWithImpl<$Res>
    extends _$IpBlockRuleCopyWithImpl<$Res, _$IpBlockRuleImpl>
    implements _$$IpBlockRuleImplCopyWith<$Res> {
  __$$IpBlockRuleImplCopyWithImpl(
    _$IpBlockRuleImpl _value,
    $Res Function(_$IpBlockRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IpBlockRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ipAddress = null,
    Object? cidr = null,
    Object? type = null,
    Object? reason = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _$IpBlockRuleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        cidr: null == cidr
            ? _value.cidr
            : cidr // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as IpRuleType,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IpBlockRuleImpl implements _IpBlockRule {
  const _$IpBlockRuleImpl({
    required this.id,
    required this.ipAddress,
    required this.cidr,
    required this.type,
    required this.reason,
    required this.createdAt,
    this.expiresAt,
    required this.isActive,
  });

  factory _$IpBlockRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$IpBlockRuleImplFromJson(json);

  @override
  final String id;
  @override
  final String ipAddress;
  @override
  final String cidr;
  @override
  final IpRuleType type;
  @override
  final String reason;
  @override
  final DateTime createdAt;
  @override
  final DateTime? expiresAt;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'IpBlockRule(id: $id, ipAddress: $ipAddress, cidr: $cidr, type: $type, reason: $reason, createdAt: $createdAt, expiresAt: $expiresAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IpBlockRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.cidr, cidr) || other.cidr == cidr) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ipAddress,
    cidr,
    type,
    reason,
    createdAt,
    expiresAt,
    isActive,
  );

  /// Create a copy of IpBlockRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IpBlockRuleImplCopyWith<_$IpBlockRuleImpl> get copyWith =>
      __$$IpBlockRuleImplCopyWithImpl<_$IpBlockRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IpBlockRuleImplToJson(this);
  }
}

abstract class _IpBlockRule implements IpBlockRule {
  const factory _IpBlockRule({
    required final String id,
    required final String ipAddress,
    required final String cidr,
    required final IpRuleType type,
    required final String reason,
    required final DateTime createdAt,
    final DateTime? expiresAt,
    required final bool isActive,
  }) = _$IpBlockRuleImpl;

  factory _IpBlockRule.fromJson(Map<String, dynamic> json) =
      _$IpBlockRuleImpl.fromJson;

  @override
  String get id;
  @override
  String get ipAddress;
  @override
  String get cidr;
  @override
  IpRuleType get type;
  @override
  String get reason;
  @override
  DateTime get createdAt;
  @override
  DateTime? get expiresAt;
  @override
  bool get isActive;

  /// Create a copy of IpBlockRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IpBlockRuleImplCopyWith<_$IpBlockRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RateLimitRule _$RateLimitRuleFromJson(Map<String, dynamic> json) {
  return _RateLimitRule.fromJson(json);
}

/// @nodoc
mixin _$RateLimitRule {
  String get id => throw _privateConstructorUsedError;
  String get endpoint => throw _privateConstructorUsedError;
  int get maxRequests => throw _privateConstructorUsedError;
  int get timeWindowSeconds => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this RateLimitRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RateLimitRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RateLimitRuleCopyWith<RateLimitRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateLimitRuleCopyWith<$Res> {
  factory $RateLimitRuleCopyWith(
    RateLimitRule value,
    $Res Function(RateLimitRule) then,
  ) = _$RateLimitRuleCopyWithImpl<$Res, RateLimitRule>;
  @useResult
  $Res call({
    String id,
    String endpoint,
    int maxRequests,
    int timeWindowSeconds,
    String action,
    DateTime createdAt,
    bool isActive,
  });
}

/// @nodoc
class _$RateLimitRuleCopyWithImpl<$Res, $Val extends RateLimitRule>
    implements $RateLimitRuleCopyWith<$Res> {
  _$RateLimitRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RateLimitRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? endpoint = null,
    Object? maxRequests = null,
    Object? timeWindowSeconds = null,
    Object? action = null,
    Object? createdAt = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            endpoint: null == endpoint
                ? _value.endpoint
                : endpoint // ignore: cast_nullable_to_non_nullable
                      as String,
            maxRequests: null == maxRequests
                ? _value.maxRequests
                : maxRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            timeWindowSeconds: null == timeWindowSeconds
                ? _value.timeWindowSeconds
                : timeWindowSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RateLimitRuleImplCopyWith<$Res>
    implements $RateLimitRuleCopyWith<$Res> {
  factory _$$RateLimitRuleImplCopyWith(
    _$RateLimitRuleImpl value,
    $Res Function(_$RateLimitRuleImpl) then,
  ) = __$$RateLimitRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String endpoint,
    int maxRequests,
    int timeWindowSeconds,
    String action,
    DateTime createdAt,
    bool isActive,
  });
}

/// @nodoc
class __$$RateLimitRuleImplCopyWithImpl<$Res>
    extends _$RateLimitRuleCopyWithImpl<$Res, _$RateLimitRuleImpl>
    implements _$$RateLimitRuleImplCopyWith<$Res> {
  __$$RateLimitRuleImplCopyWithImpl(
    _$RateLimitRuleImpl _value,
    $Res Function(_$RateLimitRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RateLimitRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? endpoint = null,
    Object? maxRequests = null,
    Object? timeWindowSeconds = null,
    Object? action = null,
    Object? createdAt = null,
    Object? isActive = null,
  }) {
    return _then(
      _$RateLimitRuleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        endpoint: null == endpoint
            ? _value.endpoint
            : endpoint // ignore: cast_nullable_to_non_nullable
                  as String,
        maxRequests: null == maxRequests
            ? _value.maxRequests
            : maxRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        timeWindowSeconds: null == timeWindowSeconds
            ? _value.timeWindowSeconds
            : timeWindowSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RateLimitRuleImpl implements _RateLimitRule {
  const _$RateLimitRuleImpl({
    required this.id,
    required this.endpoint,
    required this.maxRequests,
    required this.timeWindowSeconds,
    required this.action,
    required this.createdAt,
    required this.isActive,
  });

  factory _$RateLimitRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RateLimitRuleImplFromJson(json);

  @override
  final String id;
  @override
  final String endpoint;
  @override
  final int maxRequests;
  @override
  final int timeWindowSeconds;
  @override
  final String action;
  @override
  final DateTime createdAt;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'RateLimitRule(id: $id, endpoint: $endpoint, maxRequests: $maxRequests, timeWindowSeconds: $timeWindowSeconds, action: $action, createdAt: $createdAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.maxRequests, maxRequests) ||
                other.maxRequests == maxRequests) &&
            (identical(other.timeWindowSeconds, timeWindowSeconds) ||
                other.timeWindowSeconds == timeWindowSeconds) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    endpoint,
    maxRequests,
    timeWindowSeconds,
    action,
    createdAt,
    isActive,
  );

  /// Create a copy of RateLimitRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitRuleImplCopyWith<_$RateLimitRuleImpl> get copyWith =>
      __$$RateLimitRuleImplCopyWithImpl<_$RateLimitRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RateLimitRuleImplToJson(this);
  }
}

abstract class _RateLimitRule implements RateLimitRule {
  const factory _RateLimitRule({
    required final String id,
    required final String endpoint,
    required final int maxRequests,
    required final int timeWindowSeconds,
    required final String action,
    required final DateTime createdAt,
    required final bool isActive,
  }) = _$RateLimitRuleImpl;

  factory _RateLimitRule.fromJson(Map<String, dynamic> json) =
      _$RateLimitRuleImpl.fromJson;

  @override
  String get id;
  @override
  String get endpoint;
  @override
  int get maxRequests;
  @override
  int get timeWindowSeconds;
  @override
  String get action;
  @override
  DateTime get createdAt;
  @override
  bool get isActive;

  /// Create a copy of RateLimitRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitRuleImplCopyWith<_$RateLimitRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SecurityEvent _$SecurityEventFromJson(Map<String, dynamic> json) {
  return _SecurityEvent.fromJson(json);
}

/// @nodoc
mixin _$SecurityEvent {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  SecurityEventSeverity get severity => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get resolved => throw _privateConstructorUsedError;

  /// Serializes this SecurityEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityEventCopyWith<SecurityEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityEventCopyWith<$Res> {
  factory $SecurityEventCopyWith(
    SecurityEvent value,
    $Res Function(SecurityEvent) then,
  ) = _$SecurityEventCopyWithImpl<$Res, SecurityEvent>;
  @useResult
  $Res call({
    String id,
    String type,
    SecurityEventSeverity severity,
    String description,
    String ipAddress,
    String? userId,
    Map<String, dynamic> metadata,
    DateTime timestamp,
    bool resolved,
  });
}

/// @nodoc
class _$SecurityEventCopyWithImpl<$Res, $Val extends SecurityEvent>
    implements $SecurityEventCopyWith<$Res> {
  _$SecurityEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? description = null,
    Object? ipAddress = null,
    Object? userId = freezed,
    Object? metadata = null,
    Object? timestamp = null,
    Object? resolved = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as SecurityEventSeverity,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            resolved: null == resolved
                ? _value.resolved
                : resolved // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecurityEventImplCopyWith<$Res>
    implements $SecurityEventCopyWith<$Res> {
  factory _$$SecurityEventImplCopyWith(
    _$SecurityEventImpl value,
    $Res Function(_$SecurityEventImpl) then,
  ) = __$$SecurityEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    SecurityEventSeverity severity,
    String description,
    String ipAddress,
    String? userId,
    Map<String, dynamic> metadata,
    DateTime timestamp,
    bool resolved,
  });
}

/// @nodoc
class __$$SecurityEventImplCopyWithImpl<$Res>
    extends _$SecurityEventCopyWithImpl<$Res, _$SecurityEventImpl>
    implements _$$SecurityEventImplCopyWith<$Res> {
  __$$SecurityEventImplCopyWithImpl(
    _$SecurityEventImpl _value,
    $Res Function(_$SecurityEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? description = null,
    Object? ipAddress = null,
    Object? userId = freezed,
    Object? metadata = null,
    Object? timestamp = null,
    Object? resolved = null,
  }) {
    return _then(
      _$SecurityEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as SecurityEventSeverity,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        resolved: null == resolved
            ? _value.resolved
            : resolved // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityEventImpl implements _SecurityEvent {
  const _$SecurityEventImpl({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.ipAddress,
    this.userId,
    required final Map<String, dynamic> metadata,
    required this.timestamp,
    required this.resolved,
  }) : _metadata = metadata;

  factory _$SecurityEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityEventImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final SecurityEventSeverity severity;
  @override
  final String description;
  @override
  final String ipAddress;
  @override
  final String? userId;
  final Map<String, dynamic> _metadata;
  @override
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final DateTime timestamp;
  @override
  final bool resolved;

  @override
  String toString() {
    return 'SecurityEvent(id: $id, type: $type, severity: $severity, description: $description, ipAddress: $ipAddress, userId: $userId, metadata: $metadata, timestamp: $timestamp, resolved: $resolved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.resolved, resolved) ||
                other.resolved == resolved));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    severity,
    description,
    ipAddress,
    userId,
    const DeepCollectionEquality().hash(_metadata),
    timestamp,
    resolved,
  );

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityEventImplCopyWith<_$SecurityEventImpl> get copyWith =>
      __$$SecurityEventImplCopyWithImpl<_$SecurityEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityEventImplToJson(this);
  }
}

abstract class _SecurityEvent implements SecurityEvent {
  const factory _SecurityEvent({
    required final String id,
    required final String type,
    required final SecurityEventSeverity severity,
    required final String description,
    required final String ipAddress,
    final String? userId,
    required final Map<String, dynamic> metadata,
    required final DateTime timestamp,
    required final bool resolved,
  }) = _$SecurityEventImpl;

  factory _SecurityEvent.fromJson(Map<String, dynamic> json) =
      _$SecurityEventImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  SecurityEventSeverity get severity;
  @override
  String get description;
  @override
  String get ipAddress;
  @override
  String? get userId;
  @override
  Map<String, dynamic> get metadata;
  @override
  DateTime get timestamp;
  @override
  bool get resolved;

  /// Create a copy of SecurityEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityEventImplCopyWith<_$SecurityEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
