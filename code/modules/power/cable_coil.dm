///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

#define OMNI_CABLE "Omni Cable"

////////////////////////////////
// Definitions
////////////////////////////////

GLOBAL_LIST_INIT(cable_coil_recipes, list (new/datum/stack_recipe("cable restraints", /obj/item/restraints/handcuffs/cable, 15), new/datum/stack_recipe("noose", /obj/structure/chair/noose, 30, time = 80, one_per_turf = 1, on_floor = 1)))

/obj/item/stack/cable_coil
	name = "cable coil"
	custom_price = 15
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	item_state = "coil"
	novariants = FALSE
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	desc = "A coil of insulated power cable."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	mats_per_unit = list(/datum/material/iron=10, /datum/material/glass=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines", "flogs")
	attack_verb_simple = list("whip", "lash", "discipline", "flog")
	singular_name = "cable piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/copper = 2) //2 copper per cable in the coil
	usesound = 'sound/items/deconstruct.ogg'
	cost = 1
	source = /datum/robot_energy_storage/wire
	var/cable_color = "white"
	var/omni = TRUE

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null, param_color = null)

	pixel_x = base_pixel_x + rand(-2,2)
	pixel_y = base_pixel_y + rand(-2,2)
	update_appearance(UPDATE_ICON)
	return ..()

/obj/item/stack/cable_coil/attack_self(mob/user)
	var/list/options = list()
	options[OMNI_CABLE] = mutable_appearance('icons/obj/power.dmi', "omni-coil")
	options["Red"] = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["red"])
	options["Yellow"] = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["yellow"])
	options["Green"] = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["green"])
	options["Pink"] = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["pink"])
	options["Orange"] = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["orange"])
	var/result = show_radial_menu(user, user, options, radius = 40, tooltips = TRUE)
	if (result)
		if (result == OMNI_CABLE)
			cable_color = "white"
			omni = TRUE
		else
			cable_color = LOWER_TEXT(result)
			omni = FALSE
		update_icon()

/obj/item/stack/cable_coil/suicide_act(mob/living/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/stack/cable_coil/get_recipes()
	return GLOB.cable_coil_recipes

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/cable_coil)

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/item/stack/cable_coil/update_icon()
	if (omni)
		icon_state = "omni-coil[amount < 3 ? amount : ""]"
		name = "omni-cable [amount < 3 ? "piece" : "coil"]"
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	else
		icon_state = "[initial(item_state)][amount < 3 ? amount : ""]"
		name = "cable [amount < 3 ? "piece" : "coil"]"
		add_atom_colour(GLOB.cable_colors[cable_color], FIXED_COLOUR_PRIORITY)

/obj/item/stack/cable_coil/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/item/stack/cable_coil/new_cable = ..()
	if(istype(new_cable))
		new_cable.cable_color = cable_color
		new_cable.update_icon()

//add cables to the stack
/obj/item/stack/cable_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_icon()



///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/attack_turf(turf/T, mob/living/user)
	place_turf(T, user)
	return TRUE

// called when cable_coil is clicked on a turf
// Clicking on a turf will place the wire, which will join to surrounding tiles
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on top of exterior catwalks and plating!</span>")
		return

	for (var/obj/structure/cable/wire in T)
		if (wire.cable_color != cable_color && !omni && !wire.omni)
			continue
		if (wire.forced_power_node)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return
		if (!use(1))
			to_chat(user, "<span class='warning'>There is no cable left!</span>")
			return
		to_chat(user, "<span class='warning'>You add a node to the [wire]!</span>")
		wire.add_power_node()
		return

	if (isopenspace(T))
		var/turf/below_turf = GET_TURF_BELOW(T)
		if (!below_turf)
			CRASH("Openspace exists without a turf below it.")
		if (!use(2))
			to_chat(user, "<span class='warning'>You need at least 2 pieces of cable to wire between decks!</span>")
			return
		new /obj/structure/cable(T, cable_color)
		new /obj/structure/cable(below_turf, cable_color)
		return

	if (!use(1))
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if (omni)
		new /obj/structure/cable/omni(T, cable_color)
	else
		new /obj/structure/cable(T, cable_color)

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/cut
	amount = null
	icon_state = "coil2"
	worn_icon_state = "coil"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	if(!amount)
		amount = rand(1,2)
	. = ..()
	pixel_x = base_pixel_x + rand(-2, 2)
	pixel_y = base_pixel_y + rand(-2, 2)
	update_icon()

/obj/item/stack/cable_coil/one
	amount = 1

#undef OMNI_CABLE
