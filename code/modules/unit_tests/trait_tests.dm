#define TEST_TRAIT "test_trait"
#define SOURCE_A "a"
#define SOURCE_B "b"

/datum/unit_test/traits/test_trait_add/Run()
	var/atom/target = new()
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT))

/datum/unit_test/traits/test_has_trait_from/Run()
	var/atom/target = new()
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT_FROM(target, TEST_TRAIT, SOURCE_A))

/datum/unit_test/traits/test_has_trait_from_only/Run()
	var/atom/target = new()
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT_FROM_ONLY(target, TEST_TRAIT, SOURCE_A))
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_FALSE(HAS_TRAIT_FROM_ONLY(target, TEST_TRAIT, SOURCE_A))

/datum/unit_test/traits/test_trait_remove/Run()
	var/atom/target = new()
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT))
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT))

/datum/unit_test/traits/test_trait_stacking/Run()
	var/atom/target = new()
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT))
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT))
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT))

/datum/unit_test/traits/test_trait_remove_multi/Run()
	var/atom/target = new()
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT))
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT))
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT))

/datum/unit_test/traits/test_trait_value/Run()
	var/atom/target = new()
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A, 5, 5)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT))
	TEST_ASSERT_TRUE(GET_TRAIT_VALUE(target, TEST_TRAIT), 5)
