/obj/item/melee/ghost_sword
	name = "\improper spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "spectral"
	item_state = "spectral"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	block_upgrade_walk = 1
	block_level = 1
	block_power = 20
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/Initialize(mapload)
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	AddComponent(/datum/component/butchering, 150, 90)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = GLOB.observer_default_invisibility
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "You just recently called out for aid. You don't want to annoy the spirits.")
		return
	to_chat(user, "You call out for aid, attempting to summon spirits to your side.")

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!",
		enter_link="<a href=?src=[REF(src)];orbit=1>(Click to help)</a>",
		source = user, action=NOTIFY_ORBIT, ignore_key = POLL_IGNORE_SPECTRAL_BLADE, header = "Spectral blade")

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.check_orbitable(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()
	for(var/thing in contents)
		var/atom/A = thing
		A.transfer_observers_to(src)

	for(var/i in orbit_datum?.current_orbiters)
		if(!isobserver(i))
			continue
		var/mob/dead/observer/G = i
		ghost_counter++
		G.invisibility = 0
		current_spirits |= G

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = GLOB.observer_default_invisibility

	spirits = current_spirits

	return ghost_counter

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()

	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message(span_danger("[user] strikes with the force of [ghost_counter] vengeful spirits!"))
	..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message(span_danger("[owner] is protected by a ring of [ghost_counter] ghosts!"))
	return ..()
