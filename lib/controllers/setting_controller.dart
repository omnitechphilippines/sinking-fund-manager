import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_services/settings_api_service.dart';
import '../models/setting_model.dart';



class SettingController extends Notifier<SettingModel?> {
  @override
  SettingModel? build() => null;

  Future<void> init() async {
    final SettingModel? setting = await SettingsApiService().getSetting();
    state = setting;
  }

  void editSetting(SettingModel editSetting) {
    state = editSetting;
  }

  void deleteSetting() {
    state = null;
  }
}

final NotifierProvider<SettingController, SettingModel?> settingControllerProvider = NotifierProvider<SettingController, SettingModel?>(() => SettingController());
