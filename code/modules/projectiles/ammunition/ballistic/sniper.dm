// .50 (Sniper)

/obj/item/ammo_casing/p50
	name = ".50 bullet casing"
	desc = "A .50 bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/p50
	icon_state = ".50"
	//Bullet flash
	flash_power = MINIMUM_LIGHT_SHADOW_RADIUS
	flash_colour = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/p50/soporific
	name = ".50 soporific bullet casing"
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	projectile_type = /obj/item/projectile/bullet/p50/soporific
	icon_state = "sleeper"
	harmful = FALSE

/obj/item/ammo_casing/p50/penetrator
	name = ".50 penetrator round bullet casing"
	desc = "A .50 caliber penetrator round casing."
	projectile_type = /obj/item/projectile/bullet/p50/penetrator
