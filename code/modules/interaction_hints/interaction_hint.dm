
/// Interaction hint holder
/datum/interaction_hint
	var/atom/attached
	var/interaction_group
	var/icon = 'icons/mob/screen_interaction_hints.dmi'
	var/icon_state
	var/tool_icon

/datum/interaction_hint/New(atom/parent, interaction_group, icon/tool_icon)
	. = ..()
	attached = parent
	src.interaction_group = interaction_group
	src.tool_icon = tool_icon

/datum/interaction_hint/construction
	icon_state = "construct"

/datum/interaction_hint/deconstruction
	icon_state = "deconstruct"

/datum/interaction_hint/proc/create_and_display_to(client/target)
	// Create and fade in a hint to show to the client
	var/image/hint_holder = image()

	// Setup the left side (Shows the result of the action
	var/image/result_icon = image(icon, icon_state)
	result_icon.layer = RADIAL_LAYER
	result_icon.plane = HUD_PLANE
	result_icon.pixel_x = -16
	hint_holder.add_overlay(result_icon)

	// Setup the right side (Shows the tool required for the action)
	var/image/tool_icon_background = image('icons/mob/screen_interaction_hints.dmi', "bar")
	tool_icon_background.layer = RADIAL_LAYER
	tool_icon_background.plane = HUD_PLANE
	tool_icon_background.pixel_x = 16
	var/mutable_appearance/tool_icon = mutable_appearance(tool_icon)
	tool_icon.transform = matrix(0.7, 0, -7, 0, 0.7, 0)
	tool_icon_background.add_overlay(tool_icon)
	hint_holder.add_overlay(tool_icon_background)

	// Display
	hint_holder.loc = attached
	hint_holder.alpha = 0
	animate(hint_holder, alpha = 255, time = 10)
	target.images += hint_holder
	return hint_holder
