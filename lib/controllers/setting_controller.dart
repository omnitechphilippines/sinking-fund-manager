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

  void addSetting(SettingModel newSetting) {
    // final bool isSuccess = await _api.addSetting(newSetting);
    // if(isSuccess) state = await _api.getSetting();
    state = newSetting;
  }

  void editSetting(SettingModel updatedSetting) {
    // final SettingModel edited = await _api.editSetting(updatedSetting);
    state = updatedSetting;
  }

  void deleteSetting() {
    // final bool success = await _api.deleteSettingById(settingToDelete.id);
    // if (success) {
    //   state = null;
    // }
    state = null;
  }
}

final NotifierProvider<SettingController, SettingModel?> settingControllerProvider = NotifierProvider<SettingController, SettingModel?>(() => SettingController());
