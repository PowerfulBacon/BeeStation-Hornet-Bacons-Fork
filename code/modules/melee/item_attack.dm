/datum/item_attack

/// Return TRUE if an attack was performed, which intercepts normal weapon attacks
/// Note that click target does not have to be adjacent to the wielder of the weapon
/datum/item_attack/proc/perform_attack(mob/living/wielder, obj/item/weapon, atom/click_target)
	return FALSE
