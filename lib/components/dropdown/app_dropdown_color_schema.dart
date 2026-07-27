import 'package:getx_setup/components/dropdown/dropdown_color_scheme.dart';
import 'package:getx_setup/config/themes/app_colors.dart';

extension AppDropdownColorScheme on DropdownColorScheme {
  /// Primary
  /// Blue
  static DropdownColorScheme primary() {
    return DropdownColorScheme.defaults().copyWith(
      fillColor: SupportAppColors.white,
      popupFillColor: SupportAppColors.white,
      borderColor: SupportAppColors.greyMidColor,
      popupBorderColor: SupportAppColors.greyMidColor,
      activeBorderColor: AppColors.primary,
      disabledBorderColor: SupportAppColors.greyMidColor,
      hintTextColor: SupportAppColors.greyColor,
      suffixIconColor: SupportAppColors.greyColor,
      selectedItemTextColor: AppColors.primary,
      selectedItemBackground: AppColors.primary.withValues(alpha: 0.08),
      selectedItemSplashColor: AppColors.primary.withValues(alpha: 0.15),
      selectedItemHighlightColor: AppColors.primary.withValues(alpha: 0.08),
      checkIconColor: AppColors.primary,
      searchIconColor: SupportAppColors.greyColor,
      helperTextColor: SupportAppColors.greyColor,
    );
  }
}
