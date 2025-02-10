/obj/item/plunger
	name = "plunger"
	desc = "It's a plunger for plunging."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"

	var/plunge_mod = 1 //time*plunge_mod = total time we take to plunge an object
	var/reinforced = FALSE //whether we do heavy duty stuff like geysers

/obj/item/plunger/attack_atom(obj/O, mob/living/user)
	if(!O.plunger_act(src, user, reinforced))
		return ..()

/obj/item/plunger/reinforced
	name = "reinforced plunger"
	desc = " It's an M. 7 Reinforced Plunger� for heavy duty plunging."
	icon_state = "reinforced_plunger"

	reinforced = TRUE
	plunge_mod = 0.8
