import 'package:flutter_test/flutter_test.dart';
import 'package:wanderfund_app/core/theme/app_theme.dart';

void main() {
  test('Earthy Wanderer theme uses the exact palette roles', () {
    final theme = AppTheme.light;
    final colors = theme.colorScheme;

    expect(theme.scaffoldBackgroundColor, AppColors.pageBackground);
    expect(theme.cardTheme.color, AppColors.surface);
    expect(colors.primary, AppColors.primary);
    expect(colors.onPrimary, AppColors.surface);
    expect(colors.surface, AppColors.surface);
    expect(colors.onSurface, AppColors.primaryText);
    expect(colors.onSurfaceVariant, AppColors.secondaryText);
    expect(colors.outline, AppColors.border);
    expect(theme.dividerColor, AppColors.border);
    expect(theme.textTheme.headlineMedium?.color, AppColors.primaryText);
    expect(theme.textTheme.headlineSmall?.color, AppColors.secondaryText);
    expect(theme.textTheme.bodySmall?.color, AppColors.secondaryText);
  });
}