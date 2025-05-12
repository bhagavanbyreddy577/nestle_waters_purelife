import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state_data.freezed.dart';
part 'app_state_data.g.dart';

@freezed
abstract class AppStateData with _$AppStateData {

  const factory AppStateData({
    @Default('United Arab Emirates') String country, // TODO: Need to replace with user's selected country
    @Default('Abu Dhabi') String region, // TODO: Need to replace with user's selected region
    double? latitude,
    double? longitude,
  }) = _AppStateData;

  factory AppStateData.fromJson(Map<String, dynamic> json) => _$AppStateDataFromJson(json);

}