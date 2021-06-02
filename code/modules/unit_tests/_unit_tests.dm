//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#ifdef UNIT_TESTS
#include "anchored_mobs.dm"
#include "component_tests.dm"
#include "dynamic_ruleset_sanity.dm"
#include "reagent_id_typos.dm"
#include "reagent_recipe_collisions.dm"
#include "spawn_humans.dm"
#include "species_whitelists.dm"
#include "subsystem_init.dm"
#include "timer_sanity.dm"
#include "unit_test.dm"
#include "random_ruin_mapsize.dm"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
#undef TEST_FOCUS
#endif
