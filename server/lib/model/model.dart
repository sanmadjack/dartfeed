import 'package:di/di.dart';
import 'src/feed_model.dart';
import 'src/settings_model.dart';
import 'package:dartfeed/data_sources/data_sources.dart';

ModuleInjector createModelModuleInjector(String connectionString,
    {ModuleInjector parent}) {
  final Module module = new Module()
    ..bind(FeedModel)
    ..bind(SettingsModel);

  final ModuleInjector parent =
  createDataSourceModuleInjector(connectionString);
  final ModuleInjector injector = new ModuleInjector([module], parent);

  return injector;
}