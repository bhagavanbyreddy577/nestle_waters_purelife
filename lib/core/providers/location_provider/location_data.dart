import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_data.freezed.dart';
part 'location_data.g.dart';

@freezed
abstract class LocationData with _$LocationData {

  const factory LocationData({
    @Default('United Arab Emirates') String country, // TODO: Need to replace with user's selected country
    @Default('Abu Dhabi') String region, // TODO: Need to replace with user's selected region
    double? latitude,
    double? longitude,
  }) = _LocationData;

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);

}