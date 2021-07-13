
/mob/living
	//A list of all bodyparts in this mob. Assoc list (key = area of bodypart (Body, head etc.))
	var/list/bodyparts = list()

	//0 to 100. Conciousness of a mob. When less than 40 a mob goes into crit, when less than 0 the mob dies.
	var/conciousness = 100

	//Full body

	//Flow of blood around the body.
	//Affected by breathing and heart efficiency
	//Has a minor affect on movement (Caps out at 120% bloodflow)
	//Brain will slowly gain oxygen deprivation when below 60
	var/blood_flow = 100

	//How effective a mob is at manipulating the world.
	var/manipulation = 100
	//How effective a mob is at moving. Default 100. Below 40 prevents walking. Below 20 prevents crawling.
	var/movement = 100

/mob/living/proc/update_conciousness(var/old_conciousness)
	manipulation += (old_conciousness - conciousness) * CONCIOUSNESS_MANIPULATION_MULTIPLIER
	movement += (old_conciousness - conciousness) * CONCIOUSNESS_MOVEMENT_MULTIPLIER
