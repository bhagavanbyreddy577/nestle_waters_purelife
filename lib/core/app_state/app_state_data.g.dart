// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppStateData _$AppStateDataFromJson(Map<String, dynamic> json) =>
    _AppStateData(
      country: json['country'] as String? ?? 'United Arab Emirates',
      region: json['region'] as String? ?? 'Abu Dhabi',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AppStateDataToJson(_AppStateData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'region': instance.region,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
