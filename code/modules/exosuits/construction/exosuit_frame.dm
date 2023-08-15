
/datum/exosuit_construction
	var/exosuit_name
	var/list/required_parts

/obj/item/exosuit_frame
	name = "exosuit frame"
	desc = "The framework for an exosuit, in order to function properly it needs to have components added on top of it."
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "backbone"
	interaction_flags_item = NONE
	w_class = WEIGHT_CLASS_GIGANTIC
	flags_1 = CONDUCT_1
	/// The type of the frame, determined once a part is installed
	/// Note that this is always only a type
	var/datum/exosuit_construction/frame_type

/obj/item/exosuit_frame/proc/try_add_part(mob/user, obj/item/exosuit_frame_part/exosuit_part)
	if (frame_type && frame_type != exosuit_part.suit_type)
		to_chat(user, "<span class='notice'>You cannot add [exosuit_part] to this frame as it is incompatible with other parts.</span>")
		return
	// Adopt the frame type
	frame_type = exosuit_part.suit_type
	// Check if we need this part 

/obj/item/exosuit_frame_part
	name = "exosuit frame part"
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "blank"
	w_class = WEIGHT_CLASS_HUGE
	flags_1 = CONDUCT_1
	/// The suit type of this part. This is only ever a type
	var/datum/exosuit_construction/suit_type = null
