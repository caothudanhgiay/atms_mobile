import 'package:get_it/get_it.dart';
import 'package:loadweb/model/device_info.dart';
import 'package:loadweb/model/locale_provider.dart';
import 'package:loadweb/model/network_info_plus.dart';

final locator = GetIt.instance;

/// Registers a type as Singleton by passing a factory function that will be called.
///
/// Return type [void]
void setupLocator() {
  // repository
  locator.registerLazySingleton(() => DeviceInfo());
  locator.registerLazySingleton(() => NetworkInfoPlus());
  locator.registerLazySingleton(() => LocaleProvider());
}
