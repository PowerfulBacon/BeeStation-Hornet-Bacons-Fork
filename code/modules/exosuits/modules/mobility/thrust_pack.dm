/obj/item/exosuit_module/thrust_pack
	name = "thrust pack"
	desc = "A set of high-output thrusters powered by an internal capacitor. Allows the exosuit to dash forward and over table."
	power_cost = 1000
	height = 2
	width = 2
	weight = 6
	action_name = "Engage thruster"

/obj/item/exosuit_module/thrust_pack/ui_action_click(mob/user, datum/actiontype)
	var/amount_forward = CEILING(80 / weight, 1)
	// Activate the thruster
	if (try_use_power(power_cost))
		var/direction = user.dir
		var/turf/current_location = get_turf(user)
		// Thrust the user forward
		for (var/i in 1 to amount_forward)
			var/turf/previous = current_location
			current_location = get_step(current_location, direction)
			// If it contains objects, try to break it
			for (var/obj/object in current_location.contents)
				if (object.density)
					object.take_damage(150)
			if (current_location.is_blocked_turf(TRUE))
				current_location = previous
				break
			if (!knockdown(current_location, user))
				current_location = previous
				break
		user.forceMove(current_location)

/obj/item/exosuit_module/thrust_pack/proc/knockdown(turf/target_location, mob/user)
	for (var/mob/living/target in target_location)
		// Skip any mobs that aren't standing, or aren't dense
		if (!(target.mobility_flags & MOBILITY_STAND) || !target.density || user == target)
			continue
		// Run armour checks and apply damage
		var/armor_block = target.run_armor_check(BODY_ZONE_CHEST, MELEE)
		target.Knockdown(30 * (100 - armor_block) / 100)
		// Check if we successfully knocked them down
		if (!(target.mobility_flags & MOBILITY_STAND))
			to_chat(target, "<span class='userdanger'>[user] slams into you!</span>")
		else
			to_chat(user, "<span class='userdanger'>[target] resists the force of [user]!</span>")
			to_chat(target, "<span class='userdanger'>[user] slams into you!</span>")
			return FALSE
	return TRUE
