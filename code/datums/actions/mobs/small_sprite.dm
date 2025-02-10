//Small sprites
/datum/action/small_sprite
	name = "Toggle Giant Sprite"
	desc = "Others will always see you as giant."
	icon_icon = 'icons/hud/actions/actions_xeno.dmi'
	button_icon_state = "smallqueen"
	background_icon_state = "bg_alien"
	var/small = FALSE
	var/small_icon
	var/small_icon_state

/datum/action/small_sprite/queen
	small_icon = 'icons/mob/alien.dmi'
	small_icon_state = "alienq"

/datum/action/small_sprite/mega_arachnid
	small_icon = 'icons/mob/jungle/arachnid.dmi'
	small_icon_state = "arachnid_mini"
	background_icon_state = "bg_demon"

/datum/action/small_sprite/space_dragon
	small_icon = 'icons/mob/carp.dmi'
	small_icon_state = "carp"
	icon_icon = 'icons/mob/carp.dmi'
	button_icon_state = "carp"

/datum/action/small_sprite/on_activate(mob/user, atom/target)
	if(!small)
		var/image/I = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		I.override = TRUE
		I.pixel_x -= owner.pixel_x
		I.pixel_y -= owner.pixel_y
		owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smallsprite", I, AA_TARGET_SEE_APPEARANCE)
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE
