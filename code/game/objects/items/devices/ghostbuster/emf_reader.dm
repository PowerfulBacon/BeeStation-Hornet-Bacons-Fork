/obj/item/emf_reader
	name = "\improperEMF reader"
	desc = "A device that measures the relative levels of electromotive force in the surrounding area."
	icon = 'icons/obj/ghost_hunter.dmi'
	icon_state = "emf-off"
	var/enabled = FALSE
	var/default_state = "emf"
	var/detected_emf = 0

/obj/item/emf_reader/Initialize()
	. = ..()
	AddComponent(/datum/component/emf_tracker)

/obj/item/emf_reader/Destroy()
	STOP_PROCESSING(SSobj, src)
	unregister_emf_reader()
	. = ..()

/obj/item/emf_reader/attack_self(mob/user)
	. = ..()
	if(.)
		return
	enabled = !enabled
	if(enabled)
		START_PROCESSING(SSobj, src)
		register_emf_reader()
	else
		STOP_PROCESSING(SSobj, src)
		unregister_emf_reader()
	to_chat(user, "<span class='notice'>You toggle [src] [enabled?"on":"off"]!</span>")
	update_icon()

/obj/item/emf_reader/process()
	var/datum/component/emf_tracker = GetComponent(/datum/component/emf_tracker)
	var/new_emf = emf_tracker.get_emf_reading()
	//Change our icon
	if(new_emf != detected_emf)
		detected_emf = new_emf
		update_icon()
	//spooky sound
	if(detected_emf)
		playsound(get_turf(src), 'sound/items/buzz.ogg', 20)

/obj/item/emf_reader/update_icon()
	icon_state = "[default_state]-[enabled?"on":"off"]"
	cut_overlays()
	if(enabled && detected_emf)
		add_overlay(image(icon='icons/obj/ghost_hunter.dmi', icon_state="emf-[CLAMP(detected_emf,1,3)]"))
	..()
