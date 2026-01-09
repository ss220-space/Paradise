// Include game test files in this module in this ifdef

// Sort in alphabetical order, please!
// Use the website if you can't do it yourself. https://spiskin.ru/scripts/sort_alphabet

#ifdef TEST_RUNNER
#include "_game_test.dm"
#include "_map_per_tile_test.dm"
#include "test_runner.dm"
#endif

#ifdef GAME_TESTS
#include "test_achievements.dm"
#include "test_admin_verb_unique_names.dm"
#include "test_announcements.dm"
#include "test_components.dm"
#include "test_elements.dm"
#include "test_emotes.dm"
#include "test_get_turf_pixel.dm"
#include "test_init_sanity.dm"
#include "test_map_templates.dm"
#include "test_missing_icons.dm"
#include "test_orphaned_genturf.dm"
#include "test_plane_double_transform.dm"
#include "test_plane_dupe_detector.dm"
#include "test_reagent_id_typos.dm"
#include "test_security_levels.dm"
#include "test_spawn_humans.dm"
#include "test_sql.dm"
#include "test_status_effect_ids.dm"
#include "test_subsystem_init.dm"
#include "test_subsystem_metric_sanity.dm"
#include "test_timer_sanity.dm"
#endif

#ifdef MAP_TESTS
#include "test_map_tests.dm"
#endif
