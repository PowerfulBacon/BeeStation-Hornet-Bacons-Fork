
/datum/skilltree_skill/medical/base
	name = "CPR Training"
	desc = "Gain basic CPR training, allowing you to perform CPR 20% quicker."
	applied_trait = TRAIT_SKILL_BETTERCPR
	prequirements = list()
	x = 0
	y = 0

//=====================
// Chemistry
//=====================

/datum/skilltree_skill/medical/chemmachine
	name = "Chemistry Optimisations"
	desc = "Reduces the cost of chem machine operation by 15%."
	applied_trait = TRAIT_CHEMMACHINE
	prequirements = list(/datum/skilltree_skill/medical/base)
	x = 0
	y = 1

//=====================
// Genetics
//=====================

//=====================
// Medical and healing
//=====================

/datum/skilltree_skill/medical/fastheal
	name = "Basic Medical Care"
	desc = "Apply brute kits and other medical items 20% quicker to patients."
	applied_trait = TRAIT_SKILL_FAST_HEAL
	prequirements = list(/datum/skilltree_skill/medical/base)
	x = -1
	y = 0

/datum/skilltree_skill/medical/fasterheal
	name = "Advanced Medical Care"
	desc = "Apply brute kits and other medical items 50% quicker to patients."
	applied_trait = TRAIT_SKILL_FASTER_HEAL
	prequirements = list(/datum/skilltree_skill/medical/fastheal)
	x = -2
	y = 0

/datum/skilltree_skill/medical/fasterselfheal
	name = "Self Application"
	desc = "Improves the speed at which you can heal yourself."
	applied_trait = TRAIT_SKILL_FASTSELFHEAL
	prequirements = list(/datum/skilltree_skill/medical/fasterheal)
	x = -2
	y = -1

/datum/skilltree_skill/medical/fastgrab
	name = "Quicker Carrying"
	desc = "Allows you to fireman carry patients 40% quicker."
	applied_trait = TRAIT_SKILL_QUICKCARRY
	prequirements = list(/datum/skilltree_skill/medical/fastheal)
	x = -1
	y = -1

/datum/skilltree_skill/medical/surgeon
	name = "Basic Surgery"
	desc = "Surgery is 20% more likely to succeed."
	applied_trait = TRAIT_SURGERYBASIC
	prequirements = list(/datum/skilltree_skill/medical/fastheal)
	x = -1
	y = 1

/datum/skilltree_skill/medical/surgeon
	name = "Advanced Surgery"
	desc = "Surgery is 40% more likely to succeed and 20% quicker."
	applied_trait = TRAIT_SURGERYADV
	prequirements = list(/datum/skilltree_skill/medical/surgeon)
	x = -2
	y = 1
