// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationData {
  String get country; // TODO: Need to replace with user's selected country
  String get region; // TODO: Need to replace with user's selected region
  double? get latitude;
  double? get longitude;

  /// Create a copy of LocationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationDataCopyWith<LocationData> get copyWith =>
      _$LocationDataCopyWithImpl<LocationData>(
          this as LocationData, _$identity);

  /// Serializes this LocationData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationData &&
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
    return 'LocationData(country: $country, region: $region, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class $LocationDataCopyWith<$Res> {
  factory $LocationDataCopyWith(
          LocationData value, $Res Function(LocationData) _then) =
      _$LocationDataCopyWithImpl;
  @useResult
  $Res call(
      {String country, String region, double? latitude, double? longitude});
}

/// @nodoc
class _$LocationDataCopyWithImpl<$Res> implements $LocationDataCopyWith<$Res> {
  _$LocationDataCopyWithImpl(this._self, this._then);

  final LocationData _self;
  final $Res Function(LocationData) _then;

  /// Create a copy of LocationData
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
class _LocationData implements LocationData {
  const _LocationData(
      {this.country = 'United Arab Emirates',
      this.region = 'Abu Dhabi',
      this.latitude,
      this.longitude});
  factory _LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

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

  /// Create a copy of LocationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationDataCopyWith<_LocationData> get copyWith =>
      __$LocationDataCopyWithImpl<_LocationData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LocationDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationData &&
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
    return 'LocationData(country: $country, region: $region, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class _$LocationDataCopyWith<$Res>
    implements $LocationDataCopyWith<$Res> {
  factory _$LocationDataCopyWith(
          _LocationData value, $Res Function(_LocationData) _then) =
      __$LocationDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String country, String region, double? latitude, double? longitude});
}

/// @nodoc
class __$LocationDataCopyWithImpl<$Res>
    implements _$LocationDataCopyWith<$Res> {
  __$LocationDataCopyWithImpl(this._self, this._then);

  final _LocationData _self;
  final $Res Function(_LocationData) _then;

  /// Create a copy of LocationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? country = null,
    Object? region = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_LocationData(
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
