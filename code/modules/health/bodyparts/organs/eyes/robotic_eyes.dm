/obj/item/nbodypart/organ/eye/robotic
	name = "Visual Sensor"
	desc = "A singular high-definition camera module."
	bodyslot = null
	//Slightly stronger than regular eyes, but EMPable.
	maxhealth = 15
	bodypart_flags = BP_FLAG_REMOVABLE

	parent_typepath = /obj/item/nbodypart/organ/eye/robotic

	//1 eye does half the seeing
	sight_factor = 50

/obj/item/nbodypart/organ/eye/robotic/left
	name = "Left Visual Sensor"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/robotic/right
	name = "Right Visual Sensor"
	bodyslot = BP_RIGHT_EYE

/obj/item/nbodypart/organ/eye/robotic/cybernetic
	name = "cybernetic eye"
	desc = "An advanced, high-resolution cybernetic eye capable of reading small text at long distances. \
		It is stronger, has higher visual fidelity and is better than a regular eye in every way (apart from its \
		susceptability to electro-magnetic pulses)."
	bodyslot = null
	maxhealth = 20
	bodypart_flags = BP_FLAG_REMOVABLE

	parent_typepath = /obj/item/nbodypart/organ/eye/robotic/cybernetic

	//15% better than normal eyes.
	sight_factor = 65

/obj/item/nbodypart/organ/eye/robotic/cybernetic/left
	name = "Left Cybernetic Eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/robotic/cybernetic/right
	name = "Right Cybernetic Eye"
	bodyslot = BP_RIGHT_EYE

