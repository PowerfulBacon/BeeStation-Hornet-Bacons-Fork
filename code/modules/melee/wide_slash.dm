/datum/item_attack/wide_slash/perform_attack(mob/living/wielder, obj/item/weapon, atom/click_target)
	if (click_target == null)
		return FALSE
	var/mob/living/carbon/human/owner_mob = wielder
	// Get the direction to the clicked target
	var/direction = get_cardinal_dir(user, click_target)
	var/obj/effect/temp_visual/slash/slash = new /obj/effect/temp_visual/slash(get_turf(user))
	slash.dir = direction
	playsound(user, 'sound/weapons/fwoosh.ogg', 100, TRUE)
	// Stop them for the duration of the slash effect
	user.Immobilize(4)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(user, direction | turn_cardinal(direction, -90)), wielder, weapon), 1)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(user, direction), wielder, weapon), 2)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(user, direction | turn_cardinal(direction, 90)), wielder, weapon), 3)
	user.client?.give_cooldown_cursor(2 SECONDS)
	user.changeNext_move(2 SECONDS)
	return TRUE

/datum/item_attack/wide_slash/proc/deal_strike(turf/hit_turf, mob/living/user, obj/item/weapon)
	for (var/mob/living/living_target in hit_turf)
		// Somehow pushed onto it
		if (living_target == user)
			continue
		weapon.attack(living_target, user)

/obj/effect/temp_visual/slash
	icon = 'icons/effects/slash_96x96.dmi'
	icon_state = "cross_slash"
	pixel_x = -32
	pixel_y = -32
	randomdir = FALSE
	duration = 4
