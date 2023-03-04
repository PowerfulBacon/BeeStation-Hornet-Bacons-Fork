
/obj/item/flux_analyser
	name = "Flux analyser"
	desc = "A handheld device which analyses the flux of the world."
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

/obj/item/flux_analyser/attack_hand(mob/user)
	. = ..()
	var/turf/T = get_turf(src)
	var/flux_level = SSanomaly_science.get_flux_level(T.z)
	to_chat(user, "<span class='notice'>Flux level in this area: [flux_level]fl</span>")
