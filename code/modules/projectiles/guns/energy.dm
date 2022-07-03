/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'
	///What type of power cell this uses
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell
	/// how much charge the cell will have, if we want the gun to have some abnormal charge level without making a new battery.
	var/gun_charge
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/list/ammo_casings
	///The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/select = 1
	///Can it be charged in a recharger?
	var/can_charge = TRUE
	///Do we handle overlays with base update_icon()?
	var/automatic_charge_overlays = TRUE
	var/charge_sections = 4
	ammo_x_offset = 2
	///if this gun uses a stateful charge bar for more detail
	var/shaded_charge = FALSE
	/// stores the gun's previous ammo "ratio" to see if it needs an updated icon
	var/old_ratio = 0
	var/selfcharge = 0
	var/charge_timer = 0
	var/charge_delay = 8
	///whether the gun's cell drains the cyborg user's cell to recharge
	var/use_cyborg_cell = FALSE
	///set to true so the gun is given an empty cell
	var/dead_cell = FALSE
	///The focusing lens
	var/obj/item/focusing_crystal/focusing_lens
	///Do we randomise the crystal if we don't have one?
	///Crystal will never be randomised on mapload, map generated crystals will always be the standard
	var/randomise_crystal = TRUE
	///Standard crystal if mapload or inside someone
	var/standard_if_spawned = TRUE
	///If set to true, will not be installed with a crystal
	var/no_crystal = FALSE

/obj/item/gun/energy/Initialize(mapload)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
		if(gun_charge) //But we only use this if it is defined instead of overwriting every cell to 1000 by default like a dumbass
			cell.maxcharge = gun_charge
			cell.charge = gun_charge
	else
		cell = new(src)
	if(dead_cell)	//this makes much more sense.
		cell.use(cell.maxcharge)
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	//setup the focusing lens
	if (!no_crystal)
		if(ispath(focusing_lens))
			focusing_lens = new focusing_lens(src)
		else if(randomise_crystal && (!standard_if_spawned || !(ismob(loc) || mapload)))
			var/selected_type = pick(typesof(/obj/item/focusing_crystal))
			focusing_lens = new selected_type(src)
		else
			focusing_lens = new /obj/item/focusing_crystal(src)
	update_ammo_types()
	recharge_newshot(TRUE)
	update_icon()

/obj/item/gun/energy/examine(mob/user)
	. = ..()
	if(focusing_lens)
		. += "[icon2html(focusing_lens, user)] It has a [focusing_lens.quality_text] [focusing_lens] installed in its core."

/obj/item/gun/energy/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		obj_flags |= OBJ_EMPED
		update_icon()
		addtimer(CALLBACK(src, .proc/emp_reset), rand(1, 200 / severity))
		playsound(src, 'sound/machines/capacitor_discharge.ogg', 60, TRUE)

/obj/item/gun/energy/proc/emp_reset()
	obj_flags &= ~OBJ_EMPED
	//Update the icon
	update_icon()
	//Play a sound to indicate re-activation
	playsound(src, 'sound/machines/capacitor_charge.ogg', 90, TRUE)

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	//Reset back to the initial state
	ammo_casings = new(length(ammo_type))
	for (var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		if(focusing_lens)
			focusing_lens.update_casing(shot)
		if(shot.BB)
			focusing_lens.update_bullet(shot.BB)
		ammo_casings[i] = shot
	shot = ammo_casings[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/gun/energy/Destroy()
	if (cell)
		QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_icon(FALSE, TRUE)
	return ..()

/obj/item/gun/energy/process(delta_time)
	if(selfcharge && cell && cell.percent() < 100)
		charge_timer += delta_time
		if(charge_timer < charge_delay)
			return
		charge_timer = 0
		cell.give(100)
		if(!chambered) //if empty chamber we try to charge a new shot
			recharge_newshot(TRUE)
		update_icon()

/obj/item/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_casings.len > 1)
		select_fire(user)
		update_icon()

/obj/item/gun/energy/can_shoot()
	//Cannot shoot while EMPed
	if(obj_flags & OBJ_EMPED)
		return FALSE
	if(!focusing_lens)
		return FALSE
	var/obj/item/ammo_casing/energy/shot = ammo_casings[select]
	return !QDELETED(cell) ? (cell.charge >= shot.e_cost) : FALSE

/obj/item/gun/energy/recharge_newshot(no_cyborg_drain)
	if (!ammo_casings || !cell || !focusing_lens)
		return
	if(use_cyborg_cell && !no_cyborg_drain)
		if(iscyborg(loc))
			var/mob/living/silicon/robot/R = loc
			if(R.cell)
				var/obj/item/ammo_casing/energy/shot = ammo_casings[select] //Necessary to find cost of shot
				if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
					cell.give(shot.e_cost)	//... to recharge the shot
	if(!chambered)
		var/obj/item/ammo_casing/energy/AC = ammo_casings[select]
		if(cell.charge >= AC.e_cost) //if there's enough power in the cell cell...
			chambered = AC //...prepare a new shot based on the current ammo type selected
			if(!chambered.BB)
				chambered.newshot()
				//Modify the bullet
				focusing_lens?.update_bullet(chambered.BB)

/obj/item/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!chambered && can_shoot())
		process_chamber()	// If the gun was drained and then recharged, load a new shot.
	return ..()

/obj/item/gun/energy/process_burst(mob/living/user, atom/target, message = TRUE, params = null, zone_override="", sprd = 0, randomized_gun_spread = 0, randomized_bonus_spread = 0, rand_spr = 0, iteration = 0)
	if(!chambered && can_shoot())
		process_chamber()	// Ditto.
	return ..()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	if(!focusing_lens)
		balloon_alert(user, "[src] does not have a focusing crystal installed!")
		return
	select++
	if (select > ammo_casings.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_casings[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name)
		balloon_alert(user, "You set [src]'s mode to [shot.select_name].")
	chambered = null
	recharge_newshot(TRUE)
	update_icon(TRUE)
	return

/obj/item/gun/energy/update_icon(force_update)
	if(QDELETED(src))
		return
	..()
	if(!automatic_charge_overlays)
		return
	var/ratio = CEILING(CLAMP(cell.charge / cell.maxcharge, 0, 1) * charge_sections, 1)
	//Display no power if EMPed
	if(obj_flags & OBJ_EMPED)
		ratio = 0
	if(ratio == old_ratio && !force_update)
		return
	old_ratio = ratio
	cut_overlays()
	var/obj/item/ammo_casing/energy/shot = ammo_casings[select]
	var/iconState = "[icon_state]_charge"
	var/itemState = null
	if(!initial(item_state))
		itemState = icon_state
	if (modifystate)
		add_overlay("[icon_state]_[shot.select_name]")
		iconState += "_[shot.select_name]"
		if(itemState)
			itemState += "[shot.select_name]"
	if(cell.charge < shot.e_cost)
		add_overlay("[icon_state]_empty")
	else
		if(!shaded_charge)
			var/mutable_appearance/charge_overlay = mutable_appearance(icon, iconState)
			for(var/i = ratio, i >= 1, i--)
				charge_overlay.pixel_x = ammo_x_offset * (i - 1)
				charge_overlay.pixel_y = ammo_y_offset * (i - 1)
				add_overlay(charge_overlay)
		else
			add_overlay("[icon_state]_charge[ratio]")
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState

/obj/item/gun/energy/suicide_act(mob/living/user)
	if (istype(user) && can_shoot() && can_trigger_gun(user) && user.get_bodypart(BODY_ZONE_HEAD))
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with [src]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_casings[select]
			cell.use(shot.e_cost)
			update_icon()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to melt [user.p_their()] face off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(src, dry_fire_sound, 30, TRUE)
		return (OXYLOSS)


/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, selfcharge))
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/gun/energy/ignition_effect(atom/A, mob/living/user)
	if(!can_shoot() || !ammo_casings[select])
		shoot_with_empty_chamber()
		. = ""
	else
		var/obj/item/ammo_casing/energy/E = ammo_casings[select]
		var/obj/item/projectile/energy/BB = E.BB
		if(!BB)
			. = ""
		else if(BB.nodamage || !BB.damage || BB.damage_type == STAMINA)
			user.visible_message("<span class='danger'>[user] tries to light [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src], but it doesn't do anything. Dumbass.</span>")
			playsound(user, E.fire_sound, 50, 1)
			playsound(user, BB.hitsound, 50, 1)
			cell.use(E.e_cost)
			. = ""
		else if(BB.damage_type != BURN)
			user.visible_message("<span class='danger'>[user] tries to light [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src], but only succeeds in utterly destroying it. Dumbass.</span>")
			playsound(user, E.fire_sound, 50, 1)
			playsound(user, BB.hitsound, 50, 1)
			cell.use(E.e_cost)
			qdel(A)
			. = ""
		else
			playsound(user, E.fire_sound, 50, 1)
			playsound(user, BB.hitsound, 50, 1)
			cell.use(E.e_cost)
			. = "<span class='danger'>[user] casually lights [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src]. Damn.</span>"

/obj/item/gun/energy/proc/insert_crystal(mob/user, obj/item/focusing_crystal/crystal)
	if(focusing_lens)
		if(user)
			to_chat(user, "<span class='notice'>[src] already contains a focusing lens!</span>")
		return
	to_chat(user, "<span class='notice'>You insert [crystal] inside of [src].</span>")
	crystal.forceMove(src)
	focusing_lens = crystal
	update_ammo_types()
	recharge_newshot(TRUE)
	update_icon()
	playsound(src, 'sound/effects/light_flicker.ogg', 40, TRUE)

/obj/item/gun/energy/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/focusing_crystal))
		insert_crystal(user, I)
		return
	. = ..()
