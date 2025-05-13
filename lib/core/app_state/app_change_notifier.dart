import 'package:flutter/foundation.dart';

/// A generic change notifier class that can be used across the app
/// to manage and notify about state changes for different types of data
class AppChangeNotifier<T> extends ChangeNotifier {

  T? _value;

  /// Getter for the current value
  T? get value => _value;

  /// Constructor that optionally takes an initial value
  AppChangeNotifier([T? initialValue]) : _value = initialValue;

  /// Update the value and notify listeners
  void update(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  /// Reset the value to null and notify listeners
  void reset() {
    _value = null;
    notifyListeners();
  }

  /// Check if the current value is null
  bool get isNull => _value == null;

  /// Allows conditional update with a predicate
  void updateIf(T newValue, bool Function(T? oldValue) predicate) {
    if (predicate(_value)) {
      update(newValue);
    }
  }
}

/// Utility extension to simplify Provider setup
extension ChangeNotifierExtension<T> on AppChangeNotifier<T> {
  /// Convenient method to listen to changes
  void addSimpleListener(void Function(T?) listener) {
    addListener(() {
      listener(value);
    });
  }
}

/// TODO: Usage example (Need to remove in production)
/*
*
* /// Example of how to create and use specific change notifiers
class AppNotifiers {
  // Example of creating specific change notifiers
  static final userTheme = AppChangeNotifier<String>();
  static final isLoggedIn = AppChangeNotifier<bool>();
  static final currentLanguage = AppChangeNotifier<String>();

  // Private constructor to prevent instantiation
  AppNotifiers._();
}

/// Usage example in a widget or service
class ExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppNotifiers.userTheme,
      builder: (context, child) {
        final theme = AppNotifiers.userTheme.value;
        return Text('Current Theme: ${theme ?? "Default"}');
      },
    );
  }
}

/// Demonstration of change notifier capabilities
void demonstrateChangeNotifier() {
  // Create a change notifier
  final counterNotifier = AppChangeNotifier<int>(0);

  // Add a listener
  counterNotifier.addListener(() {
    print('Counter changed to: ${counterNotifier.value}');
  });

  // Update the value
  counterNotifier.update(5);

  // Conditional update
  counterNotifier.updateIf(10, (oldValue) => oldValue! < 8);

  // Reset the value
  counterNotifier.reset();
}
*
*
* */