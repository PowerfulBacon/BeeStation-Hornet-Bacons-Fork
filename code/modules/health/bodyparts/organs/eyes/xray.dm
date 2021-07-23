/obj/item/nbodypart/organ/eye/robotic/xray
	name = "full-spectrum mechanical eye"
	desc = "An advanced optical sensory unit that looks like a regular human eye until inspected closely. \
		It can pick up on a significantly wider array of wavelengths that the regular human eye cannot percieve, \
		however alone this overwhelms those it is installed in to. As a result, the unit has a lightweight AI \
		personality built inside it which analyses the visual data from the unit and converts it into data a \
		regular human brain can understand. The main drawback is that this AI uses a fraction of the brain to \
		execute its algorithms, reducing overall conciousness in subjects."
	bodyslot = null
	maxhealth = 16

	requires_compatability = TRUE
	parent_typepath = /obj/item/nbodypart/organ/eye/robotic/xray

	eye_color = "#000"

	conciousness_factor = -5	//Lose 5 conciousness when installed.
	sight_factor = 50			//Half the seeing is this eye.

	//Sight stuff
	flash_protect = -1
	see_in_dark = 8
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/nbodypart/organ/eye/robotic/xray/left
	name = "full-spectrum mechanical left eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/robotic/xray/right
	name = "full-spectrum mechanical right eye"
	bodyslot = BP_RIGHT_EYE
