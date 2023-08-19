/obj/item/exosuit_module/plasma_cannon
	name = "Plasma cannon"
	desc = "An arm-mounted plasma cannon which replaces one of the free hands of the exosuit."
	power_cost = 500
	height = 2
	width = 3
	weight = 8
	var/obj/item/gun/energy/exosuit_plasma_cannon/created_cannon

/obj/item/exosuit_module/plasma_cannon/suit_equipped(mob/living/wearer)
	. = ..()
	created_cannon = new(wearer, src)
	if (!wearer.put_in_active_hand(created_cannon))
		QDEL_NULL(created_cannon)

/obj/item/exosuit_module/plasma_cannon/suit_unequipped(mob/wearer)
	. = ..()
	if (created_cannon)
		QDEL_NULL(created_cannon)

//==================================
// Plasma Cannon Gun
// Hold down left click to charge it, release to fire the projectile.
//=================================

/obj/item/gun/energy/exosuit_plasma_cannon
	name = "arm-mounted plasma cannon"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma_ball)
	requires_wielding = FALSE
	weapon_weight = WEAPON_LIGHT
	canMouseDown = TRUE
	pin = /obj/item/firing_pin
	var/obj/item/exosuit_module/attached_module
	var/charging_started = 0
	var/datum/looping_sound/generator/charging_sound

/obj/item/gun/energy/exosuit_plasma_cannon/Initialize(mapload, obj/item/exosuit_module/attached_module)
	. = ..()
	src.attached_module = attached_module
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)
	charging_sound = new(src)

/obj/item/gun/energy/exosuit_plasma_cannon/onMouseDown(object, location, params, mob/mob)
	if(istype(object, /atom/movable/screen) && !istype(object, /atom/movable/screen/click_catcher))
		return
	if((object in mob.contents) || (object == mob))
		return
	start_charging(mob)
	return ..()

/obj/item/gun/energy/exosuit_plasma_cannon/onMouseUp(object, location, params, mob/mob)
	if(istype(object, /atom/movable/screen) && !istype(object, /atom/movable/screen/click_catcher))
		return
	release_projectile(object, location, params, mob)
	return ..()

/obj/item/gun/energy/exosuit_plasma_cannon/proc/start_charging(mob/user)
	charging_started = world.time
	charging_sound.start()

/obj/item/gun/energy/exosuit_plasma_cannon/proc/release_projectile(object, location, params, mob/mob)
	charging_sound.stop()
	if (world.time - charging_started < 1 SECONDS)
		return
	if (chambered)
		var/obj/item/ammo_casing/energy/plasma_ball/plasma_ball = chambered
		plasma_ball.set_energy(world.time - charging_started)
	afterattack(object, mob, FALSE, params)

//==================================
// Plasma Cannon Ammo Type
//=================================

/obj/item/ammo_casing/energy/plasma_ball
	select_name = "plasma ball"
	projectile_type = /obj/projectile/beam/plasma_ball
	var/energy = 0

/obj/item/ammo_casing/energy/plasma_ball/proc/set_energy(amount)
	energy = amount

/obj/item/ammo_casing/energy/plasma_ball/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	. = ..()
	if (!BB)
		return
	// Power the projectile
	var/obj/projectile/beam/plasma_ball/plasma_ball = BB
	plasma_ball.set_energy(energy)

//==================================
// Plasma Cannon Projecitle
//=================================

/obj/projectile/beam/plasma_ball
	name = "plasma ball"
	speed = 4
	pass_flags = PASSTABLE
	light_color = LIGHT_COLOR_PURPLE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/stored_energy

/obj/projectile/beam/plasma_ball/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.IgniteMob()
	if (stored_energy > 30)
		explosion(target, 0, 0, CEILING(stored_energy / 40, 1), CEILING(stored_energy / 20, 1))

/obj/projectile/beam/plasma_ball/proc/set_energy(amount)
	stored_energy = min(amount, 50)
	damage = stored_energy
