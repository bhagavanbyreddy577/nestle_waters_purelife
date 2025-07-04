import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/features/countryselection/blocs/country_event.dart';
import 'package:nestle_waters_purelife/features/countryselection/blocs/country_state.dart';
import '../model/countrymodel.dart';

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  CountryBloc()
      : super(
          CountryState(
            Country(
                name: 'United Arab Emirates', flagAsset: 'assets/flag/uae.png'),
            //Country(name: 'Select Country', flagAsset: 'assets/flag/uae.png'),
          ),
        ) {
    on<SelectCountryEvent>((event, emit) {
      emit(CountryState(event.country));
    });
  }
}
