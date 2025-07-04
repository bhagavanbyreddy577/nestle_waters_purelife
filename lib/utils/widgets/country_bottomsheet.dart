import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/features/countryselection/blocs/country_bloc.dart';
import 'package:nestle_waters_purelife/features/countryselection/blocs/country_event.dart';
import '../../features/countryselection/model/countrymodel.dart';

class CountryBottomSheet extends StatelessWidget {
  final List<Country> countries;

  const CountryBottomSheet({super.key, required this.countries});

  @override
  Widget build(BuildContext context) {
    final selected =
        context.select((CountryBloc bloc) => bloc.state.selectedCountry);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Country",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.separated(
                itemCount: countries.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final isSelected = selected.name == country.name;

                  return InkWell(
                    onTap: () {
                      context
                          .read<CountryBloc>()
                          .add(SelectCountryEvent(country));
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Image.asset(country.flagAsset, width: 32),
                          SizedBox(width: 16),
                          Expanded(child: Text(country.name)),
                          if (isSelected)
                            Icon(Icons.check_circle, color: Colors.blue)
                          else
                            Icon(Icons.check_circle, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
