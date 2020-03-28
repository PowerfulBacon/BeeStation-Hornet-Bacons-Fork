//---------------------------
//Shuttle area
//---------------------------

/area/shuttle/custom/syndicate
	name = "Syndicate Shuttle"

//---------------------------
//Shuttle prefab
//---------------------------

/obj/item/paper/guides/syndicate_prefab_shuttle
	name = "Syndicate Owner's Manual"
	info = "<b>Shuttle Owner's Manual</b><br>Thank you for your purchase. Here at Donk.Co we strive to make all of our products to the highest quality possible with minimal effort from the user, but every shuttle still needs maintaining!<br>On that note, maintaining your shuttle isn't easy and there are a few things to do before flying (Although we have automated most of the process just for you)<br><b>Step 1: Wrench down the plasma canister in the maintenance section in order to provide fuel to the engines.</b><br><b>Step 2:</b> Use the camera console to target your desired destination.<br><b>Step 3:</b> Use the flight controls to fly to that destination.<br><br><b>OPERATIVE NOTE: THIS SHUTTLE WILL NOT BE ABLE TO FLY TO CENTCOM HIGH SECURITY SPACE AND WILL NOT EVACUATE WITH THE OTHER SHUTTLES, BE ADVISED.</b>"

//---------------------------
//Automatic shuttle creator
//Gets the shuttle ID it is spawned on
//---------------------------

/obj/item/shuttle_creator/auto_assign
	name = "Pre-loaded Shuttle Designator"
	desc = "This one has been loaded for you. Use on a console to link it to the shuttle. Do not lose this."

/obj/item/shuttle_creator/auto_assign/Initialize()
	. = ..()
	//Look in the area for the docking port
	for(var/turf/place in get_area(src))
		for(var/obj/docking_port/mobile/M in place)
			linkedShuttleId = M.id
			return
	if(!linkedShuttleId)
		qdel(src)

//---------------------------
//Custom Shuttle Template
//---------------------------

/datum/map_template/shuttle/shuttle_syndicate
	name = "Syndicate Shuttle"
	suffix = "prefab_shuttle"
	shuttle_id = "prefab_shuttle"
	description = "A smaller sized shuttle that comes packed with \
		built-in navigation, entertainment, maintenance tools and a \
		free plushie! Order now, and we'll throw in a TINY FAN, \
		absolutely free!"
	mappath = "_maps/templates/customprefab_syndicate.dmm"

//---------------------------
//Custom survival capsule
//---------------------------

/obj/item/shuttlecapsule
	name = "bluespace shuttle capsule"
	desc = "A shuttle stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/template_id = "prefab_shuttle"
	var/datum/map_template/shuttle/template_shuttle
	var/used = FALSE

/obj/item/shuttlecapsule/proc/get_template()
	if(template_shuttle)
		return
	template_shuttle = SSmapping.shuttle_templates[template_id]
	if(!template_shuttle)
		WARNING("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/shuttlecapsule/Destroy()
	template_shuttle = null // without this, capsules would be one use. per round.
	. = ..()

/obj/item/shuttlecapsule/examine(mob/user)
	. = ..()
	get_template()
	. += "This capsule has the [template_shuttle.name] stored."
	. += template_shuttle.description

/obj/item/shuttlecapsule/attack_self()
	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(!used)
		//loc.visible_message("<span class='warning'>\The [src] begins to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		//var/status = template_shuttle.check_deploy(deploy_location)
		var/status = SHELTER_DEPLOY_ALLOWED
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				src.loc.visible_message("<span class='warning'>\The [src] will not function in this area.</span>")
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = template_shuttle.width
				var/height = template_shuttle.height
				src.loc.visible_message("<span class='warning'>\The [src] doesn't have room to deploy! You need to clear a [width]x[height] area!</span>")

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return

		playsound(src, 'sound/effects/phasein.ogg', 100, 1)

		var/turf/T = deploy_location
		if(!is_mining_level(T.z)) //only report capsules away from the mining/lavaland level
			message_admins("[ADMIN_LOOKUPFLW(usr)] activated a bluespace capsule away from the mining level! [ADMIN_VERBOSEJMP(T)]")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [AREACOORD(T)]")
		template_shuttle.load(deploy_location, centered = TRUE)
		new /obj/effect/particle_effect/smoke(get_turf(src))
		qdel(src)
