// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppStateData {
  String get country; // TODO: Need to replace with user's selected country
  String get region; // TODO: Need to replace with user's selected region
  double? get latitude;
  double? get longitude;

  /// Create a copy of AppStateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppStateDataCopyWith<AppStateData> get copyWith =>
      _$AppStateDataCopyWithImpl<AppStateData>(
          this as AppStateData, _$identity);

  /// Serializes this AppStateData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppStateData &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, country, region, latitude, longitude);

  @override
  String toString() {
    return 'AppStateData(country: $country, region: $region, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class $AppStateDataCopyWith<$Res> {
  factory $AppStateDataCopyWith(
          AppStateData value, $Res Function(AppStateData) _then) =
      _$AppStateDataCopyWithImpl;
  @useResult
  $Res call(
      {String country, String region, double? latitude, double? longitude});
}

/// @nodoc
class _$AppStateDataCopyWithImpl<$Res> implements $AppStateDataCopyWith<$Res> {
  _$AppStateDataCopyWithImpl(this._self, this._then);

  final AppStateData _self;
  final $Res Function(AppStateData) _then;

  /// Create a copy of AppStateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = null,
    Object? region = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_self.copyWith(
      country: null == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AppStateData implements AppStateData {
  const _AppStateData(
      {this.country = 'United Arab Emirates',
      this.region = 'Abu Dhabi',
      this.latitude,
      this.longitude});
  factory _AppStateData.fromJson(Map<String, dynamic> json) =>
      _$AppStateDataFromJson(json);

  @override
  @JsonKey()
  final String country;
// TODO: Need to replace with user's selected country
  @override
  @JsonKey()
  final String region;
// TODO: Need to replace with user's selected region
  @override
  final double? latitude;
  @override
  final double? longitude;

  /// Create a copy of AppStateData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppStateDataCopyWith<_AppStateData> get copyWith =>
      __$AppStateDataCopyWithImpl<_AppStateData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AppStateDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppStateData &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, country, region, latitude, longitude);

  @override
  String toString() {
    return 'AppStateData(country: $country, region: $region, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class _$AppStateDataCopyWith<$Res>
    implements $AppStateDataCopyWith<$Res> {
  factory _$AppStateDataCopyWith(
          _AppStateData value, $Res Function(_AppStateData) _then) =
      __$AppStateDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String country, String region, double? latitude, double? longitude});
}

/// @nodoc
class __$AppStateDataCopyWithImpl<$Res>
    implements _$AppStateDataCopyWith<$Res> {
  __$AppStateDataCopyWithImpl(this._self, this._then);

  final _AppStateData _self;
  final $Res Function(_AppStateData) _then;

  /// Create a copy of AppStateData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? country = null,
    Object? region = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_AppStateData(
      country: null == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
