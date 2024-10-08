
/turf/open/floor/engine
	name = "reinforced floor"
	desc = "Extremely sturdy."
	icon_state = "engine"
	holodeck_compatible = TRUE
	thermal_conductivity = 0.025
	heat_capacity = INFINITY
	floor_tile = /obj/item/stack/sheet/iron
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	FASTDMM_PROP(\
		pipe_astar_cost = 15\
	)
	max_integrity = 500

/turf/open/floor/engine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The reinforcement plates are <b>wrenched</b> firmly in place.</span>"

/turf/open/floor/engine/light
	icon_state = "engine_light"

APPLY_AIRLESS_ATMOS(/turf/open/floor/engine/airless)

/turf/open/floor/engine/airless/light
	icon_state = "engine_light"

/turf/open/floor/engine/break_tile()
	return //unbreakable

/turf/open/floor/engine/burn_tile()
	return //unburnable

/turf/open/floor/engine/make_plating(force = FALSE)
	if(force)
		return ..()
	return //unplateable

/turf/open/floor/engine/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/engine/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/engine/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin removing plates...</span>")
	if(I.use_tool(src, user, 30, volume=80))
		if(!istype(src, /turf/open/floor/engine))
			return TRUE
		if(floor_tile)
			new floor_tile(src, 1)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	return TRUE

/turf/open/floor/engine/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(30))
				new floor_tile(src)
				make_plating()
		else if(prob(30))
			ReplaceWithLattice()

/turf/open/floor/engine/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/engine/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

//air filled floors; used in atmos pressure chambers

/turf/open/floor/engine/n2o
	article = "an"
	name = "\improper N2O floor"

/turf/open/floor/engine/n2o/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
	var/final_thermal_energy = target_mixture.thermal_energy() + GLOB.gas_data.specific_heats[GAS_NITROUS] * 60 * MOLES_CELLSTANDARD * T20C
	target_mixture.gas_contents[GAS_NITROUS] += 60 * MOLES_CELLSTANDARD
	target_mixture.total_moles += 60 * MOLES_CELLSTANDARD
	target_mixture.temperature = 0
	target_mixture.adjust_thermal_energy(final_thermal_energy)
	if (!initial)
		target_mixture.gas_content_change()

/turf/open/floor/engine/n2o/light
	icon_state = "engine_light"

/turf/open/floor/engine/co2
	name = "\improper CO2 floor"

/turf/open/floor/engine/co2/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
	var/final_thermal_energy = target_mixture.thermal_energy() + GLOB.gas_data.specific_heats[GAS_CO2] * 500 * MOLES_CELLSTANDARD * T20C
	target_mixture.gas_contents[GAS_CO2] += 500 * MOLES_CELLSTANDARD
	target_mixture.total_moles += 500 * MOLES_CELLSTANDARD
	target_mixture.temperature = 0
	target_mixture.adjust_thermal_energy(final_thermal_energy)
	if (!initial)
		target_mixture.gas_content_change()

/turf/open/floor/engine/co2/light
	icon_state = "engine_light"

/turf/open/floor/engine/plasma
	name = "plasma floor"

/turf/open/floor/engine/plasma/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
	var/final_thermal_energy = target_mixture.thermal_energy() + GLOB.gas_data.specific_heats[GAS_PLASMA] * 700 * MOLES_CELLSTANDARD * T20C
	target_mixture.gas_contents[GAS_PLASMA] += 700 * MOLES_CELLSTANDARD
	target_mixture.total_moles += 700 * MOLES_CELLSTANDARD
	target_mixture.temperature = 0
	target_mixture.adjust_thermal_energy(final_thermal_energy)
	if (!initial)
		target_mixture.gas_content_change()

/turf/open/floor/engine/plasma/light
	icon_state = "engine_light"

/turf/open/floor/engine/o2
	name = "\improper O2 floor"

/turf/open/floor/engine/o2/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
	var/final_thermal_energy = target_mixture.thermal_energy() + GLOB.gas_data.specific_heats[GAS_O2] * 1000 * MOLES_CELLSTANDARD * T20C
	target_mixture.gas_contents[GAS_O2] += 1000 * MOLES_CELLSTANDARD
	target_mixture.total_moles += 1000 * MOLES_CELLSTANDARD
	target_mixture.temperature = 0
	target_mixture.adjust_thermal_energy(final_thermal_energy)
	if (!initial)
		target_mixture.gas_content_change()

/turf/open/floor/engine/o2/light
	icon_state = "engine_light"

/turf/open/floor/engine/n2
	article = "an"
	name = "\improper N2 floor"

/turf/open/floor/engine/n2/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
	var/final_thermal_energy = target_mixture.thermal_energy() + GLOB.gas_data.specific_heats[GAS_N2] * 1000 * MOLES_CELLSTANDARD * T20C
	target_mixture.gas_contents[GAS_N2] += 1000 * MOLES_CELLSTANDARD
	target_mixture.total_moles += 1000 * MOLES_CELLSTANDARD
	target_mixture.temperature = 0
	target_mixture.adjust_thermal_energy(final_thermal_energy)
	if (!initial)
		target_mixture.gas_content_change()

/turf/open/floor/engine/n2/light
	icon_state = "engine_light"

/turf/open/floor/engine/air
	name = "air floor"

/turf/open/floor/engine/air/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
	var/final_thermal_energy = target_mixture.thermal_energy() + GLOB.gas_data.specific_heats[GAS_N2] * 105.8 * MOLES_CELLSTANDARD * T20C + GLOB.gas_data.specific_heats[GAS_O2] * 264.4 * MOLES_CELLSTANDARD * T20C
	target_mixture.gas_contents[GAS_N2] += 105.8 * MOLES_CELLSTANDARD
	target_mixture.gas_contents[GAS_O2] += 264.4 * MOLES_CELLSTANDARD
	target_mixture.total_moles += (264.4 + 105.8) * MOLES_CELLSTANDARD
	target_mixture.temperature = 0
	target_mixture.adjust_thermal_energy(final_thermal_energy)
	if (!initial)
		target_mixture.gas_content_change()

/turf/open/floor/engine/air/light
	icon_state = "engine_light"

/turf/open/floor/engine/cult
	name = "engraved floor"
	desc = "The air smells strangely over this sinister flooring."
	icon_state = "plating"
	floor_tile = null
	var/obj/effect/clockwork/overlay/floor/bloodcult/realappearance
	SET_TURF_ATMOS_DENSE

/turf/open/floor/engine/cult/Initialize(mapload)
	. = ..()
	if(!mapload)
		new /obj/effect/temp_visual/cult/turf/floor(src)
	realappearance = new /obj/effect/clockwork/overlay/floor/bloodcult(src)
	realappearance.linked = src

/turf/open/floor/engine/cult/Destroy()
	be_removed()
	return ..()

/turf/open/floor/engine/cult/ChangeTurf(path, new_baseturf, flags)
	if(path != type)
		be_removed()
	return ..()

/turf/open/floor/engine/cult/proc/be_removed()
	qdel(realappearance)
	realappearance = null

APPLY_AIRLESS_ATMOS(/turf/open/floor/engine/cult/airless)

/turf/open/floor/engine/vacuum
	name = "vacuum floor"

APPLY_AIRLESS_ATMOS(/turf/open/floor/engine/vacuum)

/turf/open/floor/engine/vacuum/light
	icon_state = "engine_light"
