/datum/skilltree_skill
	var/name = "Null"
	var/desc = "It does nothing"
	var/applied_trait = null
	var/prequirements = list()
	var/x = 0
	var/y = 0
	var/med_cost = 0
	var/eng_cost = 0
	var/wep_cost = 0
	var/sci_cost = 0
	var/srv_cost = 0
	var/ant_cost = 0

/datum/skilltree_skill/proc/apply_trait(datum/mind/M)
	ADD_TRAIT(M, applied_trait, SKILL_TRAIT)

/datum/skilltree_skill/proc/remove_trait(datum/mind/M)
	REMOVE_TRAIT(M, applied_trait, SKILL_TRAIT)

/datum/skilltree_skill/medical
	med_cost = 1

/datum/skilltree_skill/engineernig
	eng_cost = 1

/datum/skilltree_skill/weapons
	wep_cost = 1

/datum/skilltree_skill/science
	sci_cost = 1

/datum/skilltree_skill/service
	srv_cost = 1

/datum/skilltree_skill/antagonist
	ant_cost = 1
