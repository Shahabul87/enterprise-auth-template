# Flutter Test Coverage Analysis Report
==================================================

## Summary Statistics
Total Implementation Files: 181
Files with Tests: 136
Files Missing Tests: 45
Test Coverage: 75.1%

## Coverage by Category
| Category | Total | Tested | Missing | Coverage % |
|----------|-------|---------|---------|------------|
| Core | 40 | 30 | 10 | 75.0% |
| Data | 25 | 23 | 2 | 92.0% |
| Domain | 6 | 3 | 3 | 50.0% |
| Presentation | 92 | 68 | 24 | 73.9% |
| Services | 2 | 2 | 0 | 100.0% |
| App | 4 | 4 | 0 | 100.0% |
| Other | 12 | 6 | 6 | 50.0% |

## Missing Tests by Priority

### HIGH Priority (11 files)

- **core/security/certificate_pinning.dart**
  - Category: core
  - Expected test: `test/core/security/certificate_pinning_test.dart`

- **data/models/auth_request.dart**
  - Category: data
  - Expected test: `test/data/models/auth_request_test.dart`

- **domain/entities/auth_state.dart**
  - Category: domain
  - Expected test: `test/unit/domain/entities/auth_state_test.dart`

- **domain/use_cases/auth/register_use_case.dart**
  - Category: domain
  - Expected test: `test/unit/domain/use_cases/auth/register_use_case_test.dart`

- **infrastructure/services/magic_link_service.dart**
  - Category: other
  - Expected test: `test/infrastructure/services/magic_link_service_test.dart`

- **infrastructure/services/oauth_service_broken.dart**
  - Category: other
  - Expected test: `test/infrastructure/services/oauth_service_broken_test.dart`

- **infrastructure/services/profile_service.dart**
  - Category: other
  - Expected test: `test/infrastructure/services/profile_service_test.dart`

- **infrastructure/services/session_service.dart**
  - Category: other
  - Expected test: `test/infrastructure/services/session_service_test.dart`

- **presentation/providers/modules/auth_module.dart**
  - Category: presentation
  - Expected test: `test/providers/auth_module_test.dart`

- **presentation/widgets/common/auth_error_handler.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/auth_error_handler/auth_error_handler_test.dart`

- **presentation/widgets/common/auth_loading_overlay.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/auth_loading_overlay/auth_loading_overlay_test.dart`

### MEDIUM Priority (14 files)

- **core/config/app_config.dart**
  - Category: core
  - Expected test: `test/core/config/app_config_test.dart`

- **core/constants/api_constants.dart**
  - Category: core
  - Expected test: `test/core/constants/api_constants_test.dart`

- **core/error/app_exception.dart**
  - Category: core
  - Expected test: `test/core/error/app_exception_test.dart`

- **core/error/error_handler.dart**
  - Category: core
  - Expected test: `test/core/error/error_handler_test.dart`

- **core/error/error_logger.dart**
  - Category: core
  - Expected test: `test/core/error/error_logger_test.dart`

- **core/errors/app_exception.dart**
  - Category: core
  - Expected test: `test/core/errors/app_exception_test.dart`

- **core/monitoring/crash_reporting.dart**
  - Category: core
  - Expected test: `test/core/monitoring/crash_reporting_test.dart`

- **core/network/api_response.dart**
  - Category: core
  - Expected test: `test/core/network/api_response_test.dart`

- **core/network/interceptors/logging_interceptor.dart**
  - Category: core
  - Expected test: `test/core/interceptors/logging_interceptor_test.dart`

- **data/models/user_profile.dart**
  - Category: data
  - Expected test: `test/data/models/user_profile_test.dart`

- **domain/entities/user_profile.dart**
  - Category: domain
  - Expected test: `test/unit/domain/entities/user_profile_test.dart`

- **main.dart**
  - Category: other
  - Expected test: `test/./main_test.dart`

- **presentation/widgets/network_status_indicator.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/network_status_indicator/network_status_indicator_test.dart`

- **shared/validators/password_validator.dart**
  - Category: other
  - Expected test: `test/shared/validators/password_validator_test.dart`

### LOW Priority (20 files)

- **presentation/pages/home/modern_home_screen.dart**
  - Category: presentation
  - Expected test: `test/presentation/pages/home/modern_home_screen_test.dart`

- **presentation/pages/profile/profile_screen.dart**
  - Category: presentation
  - Expected test: `test/presentation/pages/profile/profile_screen_test.dart`

- **presentation/pages/splash_screen.dart**
  - Category: presentation
  - Expected test: `test/presentation/pages/pages/splash_screen_test.dart`

- **presentation/widgets/avatar_component.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/avatar_component/avatar_component_test.dart`

- **presentation/widgets/bottom_sheet_templates.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/bottom_sheet_templates/bottom_sheet_templates_test.dart`

- **presentation/widgets/common/error_widget.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/error_widget/error_widget_test.dart`

- **presentation/widgets/common/loading_animations.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/loading_animations/loading_animations_test.dart`

- **presentation/widgets/common/loading_overlay.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/loading_overlay/loading_overlay_test.dart`

- **presentation/widgets/common/loading_widget.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/loading_widget/loading_widget_test.dart`

- **presentation/widgets/common/offline_banner.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/offline_banner/offline_banner_test.dart`

- **presentation/widgets/dialog_components.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/dialog_components/dialog_components_test.dart`

- **presentation/widgets/empty_state.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/empty_state/empty_state_test.dart`

- **presentation/widgets/loading_indicators.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/loading_indicators/loading_indicators_test.dart`

- **presentation/widgets/profile/profile_info_card.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/profile_info_card/profile_info_card_test.dart`

- **presentation/widgets/profile/profile_settings_tile.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/profile_settings_tile/profile_settings_tile_test.dart`

- **presentation/widgets/pull_to_refresh_wrapper.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/pull_to_refresh_wrapper/pull_to_refresh_wrapper_test.dart`

- **presentation/widgets/search_bar.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/search_bar/search_bar_test.dart`

- **presentation/widgets/shimmer_loading.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/shimmer_loading/shimmer_loading_test.dart`

- **presentation/widgets/snackbar_utils.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/snackbar_utils/snackbar_utils_test.dart`

- **presentation/widgets/widgets.dart**
  - Category: presentation
  - Expected test: `test/presentation/widgets/widgets/widgets_test.dart`

## Missing Tests by Category

### Core (10 missing)

- core/config/app_config.dart
- core/constants/api_constants.dart
- core/error/app_exception.dart
- core/error/error_handler.dart
- core/error/error_logger.dart
- core/errors/app_exception.dart
- core/monitoring/crash_reporting.dart
- core/network/api_response.dart
- core/network/interceptors/logging_interceptor.dart
- core/security/certificate_pinning.dart

### Data (2 missing)

- data/models/auth_request.dart
- data/models/user_profile.dart

### Domain (3 missing)

- domain/entities/auth_state.dart
- domain/entities/user_profile.dart
- domain/use_cases/auth/register_use_case.dart

### Presentation (24 missing)

- presentation/pages/home/modern_home_screen.dart
- presentation/pages/profile/profile_screen.dart
- presentation/pages/splash_screen.dart
- presentation/providers/modules/auth_module.dart
- presentation/widgets/avatar_component.dart
- presentation/widgets/bottom_sheet_templates.dart
- presentation/widgets/common/auth_error_handler.dart
- presentation/widgets/common/auth_loading_overlay.dart
- presentation/widgets/common/error_widget.dart
- presentation/widgets/common/loading_animations.dart
- presentation/widgets/common/loading_overlay.dart
- presentation/widgets/common/loading_widget.dart
- presentation/widgets/common/offline_banner.dart
- presentation/widgets/dialog_components.dart
- presentation/widgets/empty_state.dart
- presentation/widgets/loading_indicators.dart
- presentation/widgets/network_status_indicator.dart
- presentation/widgets/profile/profile_info_card.dart
- presentation/widgets/profile/profile_settings_tile.dart
- presentation/widgets/pull_to_refresh_wrapper.dart
- presentation/widgets/search_bar.dart
- presentation/widgets/shimmer_loading.dart
- presentation/widgets/snackbar_utils.dart
- presentation/widgets/widgets.dart

### Other (6 missing)

- infrastructure/services/magic_link_service.dart
- infrastructure/services/oauth_service_broken.dart
- infrastructure/services/profile_service.dart
- infrastructure/services/session_service.dart
- main.dart
- shared/validators/password_validator.dart

## Detailed Missing Test Files

1. **core/config/app_config.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/config/app_config_test.dart`

2. **core/constants/api_constants.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/constants/api_constants_test.dart`

3. **core/error/app_exception.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/error/app_exception_test.dart`

4. **core/error/error_handler.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/error/error_handler_test.dart`

5. **core/error/error_logger.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/error/error_logger_test.dart`

6. **core/errors/app_exception.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/errors/app_exception_test.dart`

7. **core/monitoring/crash_reporting.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/monitoring/crash_reporting_test.dart`

8. **core/network/api_response.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/network/api_response_test.dart`

9. **core/network/interceptors/logging_interceptor.dart**
   - Priority: MEDIUM
   - Category: core
   - Create test at: `test/core/interceptors/logging_interceptor_test.dart`

10. **core/security/certificate_pinning.dart**
   - Priority: HIGH
   - Category: core
   - Create test at: `test/core/security/certificate_pinning_test.dart`

11. **data/models/auth_request.dart**
   - Priority: HIGH
   - Category: data
   - Create test at: `test/data/models/auth_request_test.dart`

12. **data/models/user_profile.dart**
   - Priority: MEDIUM
   - Category: data
   - Create test at: `test/data/models/user_profile_test.dart`

13. **domain/entities/auth_state.dart**
   - Priority: HIGH
   - Category: domain
   - Create test at: `test/unit/domain/entities/auth_state_test.dart`

14. **domain/entities/user_profile.dart**
   - Priority: MEDIUM
   - Category: domain
   - Create test at: `test/unit/domain/entities/user_profile_test.dart`

15. **domain/use_cases/auth/register_use_case.dart**
   - Priority: HIGH
   - Category: domain
   - Create test at: `test/unit/domain/use_cases/auth/register_use_case_test.dart`

16. **infrastructure/services/magic_link_service.dart**
   - Priority: HIGH
   - Category: other
   - Create test at: `test/infrastructure/services/magic_link_service_test.dart`

17. **infrastructure/services/oauth_service_broken.dart**
   - Priority: HIGH
   - Category: other
   - Create test at: `test/infrastructure/services/oauth_service_broken_test.dart`

18. **infrastructure/services/profile_service.dart**
   - Priority: HIGH
   - Category: other
   - Create test at: `test/infrastructure/services/profile_service_test.dart`

19. **infrastructure/services/session_service.dart**
   - Priority: HIGH
   - Category: other
   - Create test at: `test/infrastructure/services/session_service_test.dart`

20. **main.dart**
   - Priority: MEDIUM
   - Category: other
   - Create test at: `test/./main_test.dart`

21. **presentation/pages/home/modern_home_screen.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/pages/home/modern_home_screen_test.dart`

22. **presentation/pages/profile/profile_screen.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/pages/profile/profile_screen_test.dart`

23. **presentation/pages/splash_screen.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/pages/pages/splash_screen_test.dart`

24. **presentation/providers/modules/auth_module.dart**
   - Priority: HIGH
   - Category: presentation
   - Create test at: `test/providers/auth_module_test.dart`

25. **presentation/widgets/avatar_component.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/avatar_component/avatar_component_test.dart`

26. **presentation/widgets/bottom_sheet_templates.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/bottom_sheet_templates/bottom_sheet_templates_test.dart`

27. **presentation/widgets/common/auth_error_handler.dart**
   - Priority: HIGH
   - Category: presentation
   - Create test at: `test/presentation/widgets/auth_error_handler/auth_error_handler_test.dart`

28. **presentation/widgets/common/auth_loading_overlay.dart**
   - Priority: HIGH
   - Category: presentation
   - Create test at: `test/presentation/widgets/auth_loading_overlay/auth_loading_overlay_test.dart`

29. **presentation/widgets/common/error_widget.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/error_widget/error_widget_test.dart`

30. **presentation/widgets/common/loading_animations.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/loading_animations/loading_animations_test.dart`

31. **presentation/widgets/common/loading_overlay.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/loading_overlay/loading_overlay_test.dart`

32. **presentation/widgets/common/loading_widget.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/loading_widget/loading_widget_test.dart`

33. **presentation/widgets/common/offline_banner.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/offline_banner/offline_banner_test.dart`

34. **presentation/widgets/dialog_components.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/dialog_components/dialog_components_test.dart`

35. **presentation/widgets/empty_state.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/empty_state/empty_state_test.dart`

36. **presentation/widgets/loading_indicators.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/loading_indicators/loading_indicators_test.dart`

37. **presentation/widgets/network_status_indicator.dart**
   - Priority: MEDIUM
   - Category: presentation
   - Create test at: `test/presentation/widgets/network_status_indicator/network_status_indicator_test.dart`

38. **presentation/widgets/profile/profile_info_card.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/profile_info_card/profile_info_card_test.dart`

39. **presentation/widgets/profile/profile_settings_tile.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/profile_settings_tile/profile_settings_tile_test.dart`

40. **presentation/widgets/pull_to_refresh_wrapper.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/pull_to_refresh_wrapper/pull_to_refresh_wrapper_test.dart`

41. **presentation/widgets/search_bar.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/search_bar/search_bar_test.dart`

42. **presentation/widgets/shimmer_loading.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/shimmer_loading/shimmer_loading_test.dart`

43. **presentation/widgets/snackbar_utils.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/snackbar_utils/snackbar_utils_test.dart`

44. **presentation/widgets/widgets.dart**
   - Priority: LOW
   - Category: presentation
   - Create test at: `test/presentation/widgets/widgets/widgets_test.dart`

45. **shared/validators/password_validator.dart**
   - Priority: MEDIUM
   - Category: other
   - Create test at: `test/shared/validators/password_validator_test.dart`

## Recommendations

1. **Start with HIGH priority files** - Focus on auth, security, and core services
2. **Create missing unit tests** - Especially for data services and repositories
3. **Add widget tests** - For complex UI components
4. **Integration tests** - For critical user flows

## Test File Creation Commands

```bash
mkdir -p test/core/config
touch test/core/config/app_config_test.dart
mkdir -p test/core/constants
touch test/core/constants/api_constants_test.dart
mkdir -p test/core/error
touch test/core/error/app_exception_test.dart
mkdir -p test/core/error
touch test/core/error/error_handler_test.dart
mkdir -p test/core/error
touch test/core/error/error_logger_test.dart
mkdir -p test/core/errors
touch test/core/errors/app_exception_test.dart
mkdir -p test/core/monitoring
touch test/core/monitoring/crash_reporting_test.dart
mkdir -p test/core/network
touch test/core/network/api_response_test.dart
mkdir -p test/core/interceptors
touch test/core/interceptors/logging_interceptor_test.dart
mkdir -p test/core/security
touch test/core/security/certificate_pinning_test.dart
```
