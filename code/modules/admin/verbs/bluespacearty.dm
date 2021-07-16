/client/proc/bluespace_artillery(mob/M in GLOB.mob_list)
	if(!holder || !check_rights(R_FUN))
		return

	var/mob/living/target = M

	if(!isliving(target))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return

	explosion(target.loc, 0, 0, 0, 0)

	var/turf/open/floor/T = get_turf(target)
	if(istype(T))
		if(prob(80))
			T.break_tile_to_plating()
		else
			T.break_tile()

	if(!target.body.is_concious())
		target.gib(1, 1)
	else
		for(var/i in 1 to 5)
			target.apply_damage_randomly(15, BURN, "Explosion")
		target.Paralyze(400)
		target.stuttering = 20

