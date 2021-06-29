/obj/item/ammo_casing/proc/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, spread_mult = 1, atom/fired_from)
	if(flash_power)
		//Iteratively loop to find the parent
		//Prevent bag of holding loop shenanigans
		var/max_depth = 5
		var/atom/movable/parent_item = fired_from
		while(max_depth > 0 && parent_item.loc && !isturf(parent_item.loc))
			max_depth --
			parent_item = fired_from.loc
		flash_lighting_fx(MINIMUM_LIGHT_SHADOW_RADIUS, flash_power, flash_colour, 3, TRUE, 1, /atom/movable/lighting_mask/conical, parent_item.dir)
	distro += variance
	var/targloc = get_turf(target)
	ready_proj(target, user, quiet, zone_override, fired_from)
	if(pellets == 1)
		if(distro) //We have to spread a pixel-precision bullet. throw_proj was called before so angles should exist by now...
			if(randomspread)
				spread = round((rand() - 0.5) * distro) * spread_mult
			else //Smart spread
				spread = round(1 - 0.5) * distro * spread_mult
		if(!throw_proj(target, targloc, user, params, spread))
			return FALSE
	else
		if(isnull(BB))
			return FALSE
		AddComponent(/datum/component/pellet_cloud, projectile_type, pellets)
		SEND_SIGNAL(src, COMSIG_PELLET_CLOUD_INIT, target, user, fired_from, randomspread, spread, zone_override, params, distro)
	if(click_cooldown_override)
		user.changeNext_move(click_cooldown_override)
	else
		user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target, user))
	update_icon()
	return TRUE

/obj/item/ammo_casing/proc/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	if (!BB)
		return
	BB.original = target
	BB.firer = user
	BB.fired_from = fired_from
	if (zone_override)
		BB.def_zone = zone_override
	else
		BB.def_zone = user.zone_selected
	BB.suppressed = quiet

	if(reagents && BB.reagents)
		reagents.trans_to(BB, reagents.total_volume, transfered_by = user) //For chemical darts/bullets
		qdel(reagents)

/obj/item/ammo_casing/proc/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	if (!istype(targloc) || !istype(curloc) || !BB)
		return FALSE

	var/firing_dir
	if(BB.firer)
		firing_dir = BB.firer.dir
	if(!BB.suppressed && firing_effect_type)
		new firing_effect_type(get_turf(src), firing_dir)

	var/direct_target
	if(targloc == curloc)
		if(target) //if the target is right on our location we'll skip the travelling code in the proj's fire()
			direct_target = target
	if(!direct_target)
		BB.preparePixelProjectile(target, user, params, spread)
	BB.fire(null, direct_target)
	BB = null
	return TRUE

/obj/item/ammo_casing/proc/spread(turf/target, turf/current, distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)

/obj/item/ammo_casing/screwdriver_act(mob/living/user, obj/item/I)
	user.visible_message("<span class='danger'>[user] hits the [src]'s primer with [user.p_their()] [I]!</span>")
	if(!user.is_holding(src))
		to_chat(user, "<span class='warning'>You need to pickup \the [src] first!</span>")
		return
	if(prob(75))
		fire_casing(get_step(src, user.dir), user, spread = rand(-40, 40))
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			var/obj/item/bodypart/affecting = C.get_holding_bodypart_of_item(src)
			C.apply_damage(rand(5, 10), BRUTE, affecting)
	else
		user.visible_message("<span class='danger'>[user]'s [I] slips!</span>")
		fire_casing(user, user)

/obj/item/ammo_casing/caseless/screwdriver_act(mob/living/user, /obj/item/I)
	return // No launching arrows with screwdrivers!
