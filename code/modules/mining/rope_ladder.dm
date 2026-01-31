
/obj/item/rope_ladder
	name = "rope ladder"
	desc = "A ladder made of rope"

/obj/item/rope_ladder/attack_turf(turf/T, mob/living/user)
	if (!isopenspace(T))
		return ..()
	var/turf/open/openspace/openspace = T
	var/turf/linked_turf = GET_TURF_BELOW(openspace)
	if (!linked_turf)
		return ..()
	if (isclosedturf(linked_turf))
		to_chat(user, span_warning("\The [src] was blocked by something solid!"))
		return TRUE
	to_chat(user, span_notice("You deploy \the [src]."))
	// Create a pair of linked ladders
	new /obj/structure/ladder(linked_turf, new /obj/structure/ladder(openspace))
	qdel(src)
