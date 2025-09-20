// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WebSocketProviderState {
  ws.WebSocketState get connectionState => throw _privateConstructorUsedError;
  List<WebSocketEvent> get recentEvents => throw _privateConstructorUsedError;
  List<WebSocketEvent> get notifications => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  int get unreadNotificationCount => throw _privateConstructorUsedError;
  bool get isAutoReconnectEnabled => throw _privateConstructorUsedError;

  /// Create a copy of WebSocketProviderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebSocketProviderStateCopyWith<WebSocketProviderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebSocketProviderStateCopyWith<$Res> {
  factory $WebSocketProviderStateCopyWith(
    WebSocketProviderState value,
    $Res Function(WebSocketProviderState) then,
  ) = _$WebSocketProviderStateCopyWithImpl<$Res, WebSocketProviderState>;
  @useResult
  $Res call({
    ws.WebSocketState connectionState,
    List<WebSocketEvent> recentEvents,
    List<WebSocketEvent> notifications,
    List<String> errors,
    int unreadNotificationCount,
    bool isAutoReconnectEnabled,
  });
}

/// @nodoc
class _$WebSocketProviderStateCopyWithImpl<
  $Res,
  $Val extends WebSocketProviderState
>
    implements $WebSocketProviderStateCopyWith<$Res> {
  _$WebSocketProviderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebSocketProviderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionState = null,
    Object? recentEvents = null,
    Object? notifications = null,
    Object? errors = null,
    Object? unreadNotificationCount = null,
    Object? isAutoReconnectEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            connectionState: null == connectionState
                ? _value.connectionState
                : connectionState // ignore: cast_nullable_to_non_nullable
                      as ws.WebSocketState,
            recentEvents: null == recentEvents
                ? _value.recentEvents
                : recentEvents // ignore: cast_nullable_to_non_nullable
                      as List<WebSocketEvent>,
            notifications: null == notifications
                ? _value.notifications
                : notifications // ignore: cast_nullable_to_non_nullable
                      as List<WebSocketEvent>,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            unreadNotificationCount: null == unreadNotificationCount
                ? _value.unreadNotificationCount
                : unreadNotificationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isAutoReconnectEnabled: null == isAutoReconnectEnabled
                ? _value.isAutoReconnectEnabled
                : isAutoReconnectEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebSocketProviderStateImplCopyWith<$Res>
    implements $WebSocketProviderStateCopyWith<$Res> {
  factory _$$WebSocketProviderStateImplCopyWith(
    _$WebSocketProviderStateImpl value,
    $Res Function(_$WebSocketProviderStateImpl) then,
  ) = __$$WebSocketProviderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ws.WebSocketState connectionState,
    List<WebSocketEvent> recentEvents,
    List<WebSocketEvent> notifications,
    List<String> errors,
    int unreadNotificationCount,
    bool isAutoReconnectEnabled,
  });
}

/// @nodoc
class __$$WebSocketProviderStateImplCopyWithImpl<$Res>
    extends
        _$WebSocketProviderStateCopyWithImpl<$Res, _$WebSocketProviderStateImpl>
    implements _$$WebSocketProviderStateImplCopyWith<$Res> {
  __$$WebSocketProviderStateImplCopyWithImpl(
    _$WebSocketProviderStateImpl _value,
    $Res Function(_$WebSocketProviderStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebSocketProviderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectionState = null,
    Object? recentEvents = null,
    Object? notifications = null,
    Object? errors = null,
    Object? unreadNotificationCount = null,
    Object? isAutoReconnectEnabled = null,
  }) {
    return _then(
      _$WebSocketProviderStateImpl(
        connectionState: null == connectionState
            ? _value.connectionState
            : connectionState // ignore: cast_nullable_to_non_nullable
                  as ws.WebSocketState,
        recentEvents: null == recentEvents
            ? _value._recentEvents
            : recentEvents // ignore: cast_nullable_to_non_nullable
                  as List<WebSocketEvent>,
        notifications: null == notifications
            ? _value._notifications
            : notifications // ignore: cast_nullable_to_non_nullable
                  as List<WebSocketEvent>,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        unreadNotificationCount: null == unreadNotificationCount
            ? _value.unreadNotificationCount
            : unreadNotificationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isAutoReconnectEnabled: null == isAutoReconnectEnabled
            ? _value.isAutoReconnectEnabled
            : isAutoReconnectEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$WebSocketProviderStateImpl implements _WebSocketProviderState {
  const _$WebSocketProviderStateImpl({
    this.connectionState = ws.WebSocketState.disconnected,
    final List<WebSocketEvent> recentEvents = const [],
    final List<WebSocketEvent> notifications = const [],
    final List<String> errors = const [],
    this.unreadNotificationCount = 0,
    this.isAutoReconnectEnabled = false,
  }) : _recentEvents = recentEvents,
       _notifications = notifications,
       _errors = errors;

  @override
  @JsonKey()
  final ws.WebSocketState connectionState;
  final List<WebSocketEvent> _recentEvents;
  @override
  @JsonKey()
  List<WebSocketEvent> get recentEvents {
    if (_recentEvents is EqualUnmodifiableListView) return _recentEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentEvents);
  }

  final List<WebSocketEvent> _notifications;
  @override
  @JsonKey()
  List<WebSocketEvent> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  @JsonKey()
  final int unreadNotificationCount;
  @override
  @JsonKey()
  final bool isAutoReconnectEnabled;

  @override
  String toString() {
    return 'WebSocketProviderState(connectionState: $connectionState, recentEvents: $recentEvents, notifications: $notifications, errors: $errors, unreadNotificationCount: $unreadNotificationCount, isAutoReconnectEnabled: $isAutoReconnectEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebSocketProviderStateImpl &&
            (identical(other.connectionState, connectionState) ||
                other.connectionState == connectionState) &&
            const DeepCollectionEquality().equals(
              other._recentEvents,
              _recentEvents,
            ) &&
            const DeepCollectionEquality().equals(
              other._notifications,
              _notifications,
            ) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(
                  other.unreadNotificationCount,
                  unreadNotificationCount,
                ) ||
                other.unreadNotificationCount == unreadNotificationCount) &&
            (identical(other.isAutoReconnectEnabled, isAutoReconnectEnabled) ||
                other.isAutoReconnectEnabled == isAutoReconnectEnabled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    connectionState,
    const DeepCollectionEquality().hash(_recentEvents),
    const DeepCollectionEquality().hash(_notifications),
    const DeepCollectionEquality().hash(_errors),
    unreadNotificationCount,
    isAutoReconnectEnabled,
  );

  /// Create a copy of WebSocketProviderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebSocketProviderStateImplCopyWith<_$WebSocketProviderStateImpl>
  get copyWith =>
      __$$WebSocketProviderStateImplCopyWithImpl<_$WebSocketProviderStateImpl>(
        this,
        _$identity,
      );
}

abstract class _WebSocketProviderState implements WebSocketProviderState {
  const factory _WebSocketProviderState({
    final ws.WebSocketState connectionState,
    final List<WebSocketEvent> recentEvents,
    final List<WebSocketEvent> notifications,
    final List<String> errors,
    final int unreadNotificationCount,
    final bool isAutoReconnectEnabled,
  }) = _$WebSocketProviderStateImpl;

  @override
  ws.WebSocketState get connectionState;
  @override
  List<WebSocketEvent> get recentEvents;
  @override
  List<WebSocketEvent> get notifications;
  @override
  List<String> get errors;
  @override
  int get unreadNotificationCount;
  @override
  bool get isAutoReconnectEnabled;

  /// Create a copy of WebSocketProviderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebSocketProviderStateImplCopyWith<_$WebSocketProviderStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
