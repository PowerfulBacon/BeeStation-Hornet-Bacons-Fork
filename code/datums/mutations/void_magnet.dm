/datum/mutation/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>You feel a heavy, dull force just beyond the walls watching you.</span>"
	instability = 30
	power_path = /datum/action/spell/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/void/on_life(delta_time, times_fired)
	// Move this onto the spell itself at some point?
	var/datum/action/spell/void/curse = locate(power_path) in owner
	if(!curse)
		remove()
		return

	if(!curse.is_valid_spell(owner, null))
		return

	//very rare, but enough to annoy you hopefully. + 0.5 probability for every 10 points lost in stability
	if(DT_PROB((0.25 + ((100 - dna.stability) / 40)) * GET_MUTATION_SYNCHRONIZER(src), delta_time))
		curse.on_cast(owner, null)

/datum/action/spell/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	button_icon_state = "void_magnet"
	mindbound = FALSE
	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES

	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = NONE

/datum/action/spell/void/is_valid_spell(mob/user, atom/target)
	return isturf(user.loc)

/datum/action/spell/void/on_cast(mob/user, atom/target)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(user), user)

//Immortality Talisman
/obj/item/immortality_talisman
	name = "\improper Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/obj/item/immortality_talisman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, INNATE_TRAIT, (MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/immortality_talisman/attack_self(mob/user)
	if(cooldown < world.time)
		SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1)
		cooldown = world.time + 600
		new /obj/effect/immortality_talisman(get_turf(user), user)
	else
		to_chat(user, span_warning("[src] is not ready yet!"))

/obj/effect/immortality_talisman
	name = "hole in reality"
	desc = "It's shaped an awful lot like a person."
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/vanish_description = "vanishes from reality"
	var/can_destroy = TRUE

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/immortality_talisman)

/obj/effect/immortality_talisman/Initialize(mapload, mob/new_user)
	. = ..()
	if(new_user)
		vanish(new_user)

/obj/effect/immortality_talisman/proc/vanish(mob/user)
	user.visible_message(span_danger("[user] [vanish_description], leaving a hole in [user.p_their()] place!"))

	desc = "It's shaped an awful lot like [user.name]."
	setDir(user.dir)

	user.forceMove(src)
	user.notransform = TRUE
	user.status_flags |= GODMODE

	can_destroy = FALSE

	addtimer(CALLBACK(src, PROC_REF(unvanish), user), 10 SECONDS)

/obj/effect/immortality_talisman/proc/unvanish(mob/user)
	user.status_flags &= ~GODMODE
	user.notransform = FALSE
	user.forceMove(get_turf(src))

	user.visible_message(span_danger("[user] pops back into reality!"))
	can_destroy = TRUE
	qdel(src)

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()

/obj/effect/immortality_talisman/void
	vanish_description = "is dragged into the void"
