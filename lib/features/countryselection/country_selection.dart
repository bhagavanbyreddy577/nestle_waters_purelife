import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/utils/widgets/country_bottomsheet.dart';
import 'blocs/country_bloc.dart';
import 'blocs/country_state.dart';
import 'model/countrymodel.dart';

class CountryDropdown extends StatelessWidget {
  const CountryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CountryBloc(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false, home: CountrySelectorScreen()),
    );
  }
}

class CountrySelectorScreen extends StatelessWidget {
  
  final List<Country> countries = [
    Country(name: 'Saudi Arabia', flagAsset: 'assets/flag/sa.png'),
    Country(name: 'United Arab Emirates', flagAsset: 'assets/flag/uae.png'),
    Country(name: 'Egypt', flagAsset: 'assets/flag/egypt.png'),
    Country(name: 'Kuwait', flagAsset: 'assets/flag/kuwait.png'),
    Country(name: 'Qatar', flagAsset: 'assets/flag/qatar.png'),
    Country(name: 'Oman', flagAsset: 'assets/flag/oman.png'),
    Country(name: 'Bahrain', flagAsset: 'assets/flag/bahrain.png'),
  ];

  CountrySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.blueGrey,
        actions: [
          BlocBuilder<CountryBloc, CountryState>(builder: (context, state) {
            return TextButton(
                onPressed: () => showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => CountryBottomSheet(countries: countries),
                    ),
                child: Text(
                  state.selectedCountry.name,
                  style: TextStyle(color: Colors.white),
                ));
          })
        ],
      ),
      body: BlocBuilder<CountryBloc, CountryState>(
        builder: (context, state) {
          return Center(child: Text("Selection Country"));
        },
      ),
    );
  }
}
