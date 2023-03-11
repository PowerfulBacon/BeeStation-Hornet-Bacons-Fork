
/obj/item/flux_container
	name = "flux storage container"
	desc = "A magnetic-driven storage container for holding solid flux energy. Can be used to power flux-driven machinery"
	icon = 'icons/obj/anomaly_science/flux_canister.dmi'
	icon_state = "empty"
	var/energy_stored = 0

/obj/item/flux_container/examine(mob/user)
	. = ..()
	. += "The canisters flux storage dial reads [energy_stored]fl."

/obj/item/flux_container/update_icon(updates)
	. = ..()
	icon_state = energy_stored ? "full" : "empty"
