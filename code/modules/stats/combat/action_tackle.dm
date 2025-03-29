/datum/action/tackle
	requires_target = TRUE
	cooldown_time = 20 SECONDS

/datum/action/tackle/on_activate(mob/user, atom/target, trigger_flags)
	if (!isturf(target))
		return
	start_cooldown()
	// Dash towards the target location
	var/tackle_dir = get_dir(user, target)
	var/turf/tackle_turf = get_step(user, tackle_dir)
	// Smash into the things on the turfs, damaging objects and 
