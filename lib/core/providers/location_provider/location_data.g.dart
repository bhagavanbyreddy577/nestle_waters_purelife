// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationData _$LocationDataFromJson(Map<String, dynamic> json) =>
    _LocationData(
      country: json['country'] as String? ?? 'United Arab Emirates',
      region: json['region'] as String? ?? 'Abu Dhabi',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LocationDataToJson(_LocationData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'region': instance.region,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
