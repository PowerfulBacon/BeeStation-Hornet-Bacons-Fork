
/obj/item/melee/baton/disruptor
	name = "disruptor baton"
	desc = "An electronicly charged baton developed to counter physical anomalous entities. Not permitted for use against humans."
	force = 12
	stunforce = 45
	hitcost = 2000
	preload_cell_type = /obj/item/stock_parts/cell/high
	var/disrupt_ready = TRUE
	var/cooldown_time = 4 SECONDS
	var/supression_power = 70

/obj/item/melee/baton/disruptor/nocell
	preload_cell_type = null

/obj/item/melee/baton/disruptor/update_icon()
	if(obj_flags & OBJ_EMPED)
		icon_state = "[initial(icon_state)]"
	else if(turned_on && disrupt_ready)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/melee/baton/disruptor/attack_obj(obj/O, mob/living/user)
	. = ..()
	if(obj_flags & OBJ_EMPED)
		return
	if (!disrupt_ready)
		return
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return
	else
		if(!deductcharge(hitcost))
			return
	// Perform supression effect
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	supress_target(O, user)

/obj/item/melee/baton/disruptor/baton_stun(mob/living/target, mob/living/user)
	if (!disrupt_ready)
		return FALSE
	if (..())
		return supress_target(target, user)
	return FALSE

/obj/item/melee/baton/disruptor/proc/supress_target(obj/target, mob/living/user)
	SEND_SIGNAL(target, COMSIG_ANOMALY_SUPRESSED, user, ANOMALY_SUPPRESSION_DISRUPTOR, supression_power)
	new /obj/effect/temp_visual/parry(get_turf(target))
	disrupt_ready = FALSE
	addtimer(CALLBACK(src, .proc/finish_disrupt_cooldown), cooldown_time)
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/item/melee/baton/disruptor/proc/finish_disrupt_cooldown()
	playsound(src, 'sound/effects/sparks1.ogg', 70)
	disrupt_ready = TRUE
	update_appearance(UPDATE_ICON_STATE)
