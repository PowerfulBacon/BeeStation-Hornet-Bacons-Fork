SUBSYSTEM_DEF(zone_damage)
	name = "Zone Damage"
	flags = SS_NO_INIT
	wait = 2 SECONDS
	var/list/processing = list()

/datum/controller/subsystem/zone_damage/fire(resumed)
	if (!resumed)
		processing = GLOB.mob_living_list.Copy()
	while (!MC_TICK_CHECK && length(processing))
		var/mob/living/first = processing[processing.len]
		processing.len --
		if (!isliving(first))
			continue
		// Get the orbital map position
		var/datum/orbital_object/our_location = SSorbits.get_associated_level(get_turf(first))
		if (!our_location)
			continue
		var/datum/orbital_map/our_map = SSorbits.orbital_maps[our_location.orbital_map_index]
		var/distance = sqrt(our_location.position.GetX() * our_location.position.GetX() + our_location.position.GetY() * our_location.position.GetY())
		if (distance > our_map.map_radius)
			flash_color(first, flash_color="#912121", flash_time = 25)
			first.take_overall_damage(5, 0)
