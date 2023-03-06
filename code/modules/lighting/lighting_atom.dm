
/atom
	var/light_power = 1 // Intensity of the light.
	var/light_range = 0 // Range in tiles of the light.
	var/light_color     // Hexadecimal RGB string representing the colour of the light.

// Should always be used to change the opacity of an atom.
// It notifies (potentially) affected light sources so they can update (if needed).
/atom/proc/set_opacity(var/new_opacity)
	if (new_opacity == opacity)
		return

	opacity = new_opacity

#define NONSENSICAL_VALUE 999999

/atom/proc/set_light(var/l_range, var/l_power, var/l_color = NONSENSICAL_VALUE)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE	//Brings the range up to 1.4, which is just barely brighter than the soft lighting that surrounds players.
	if (l_power != null)
		set_light_power(l_power)

	if (l_range != null)
		set_light_range(l_range)

	if (l_color != NONSENSICAL_VALUE)
		set_light_color(l_color)

#undef NONSENSICAL_VALUE

/atom/vv_edit_var(var_name, var_value)
	switch (var_name)
		if (NAMEOF(src, light_range))
			set_light_range(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if (NAMEOF(src, light_power))
			set_light_power(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if (NAMEOF(src, light_color))
			set_light_color(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

	return ..()


/atom/proc/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	return


/turf/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	if(!_duration)
		stack_trace("Lighting FX obj created on a turf without a duration")
	new /obj/effect/dummy/lighting_obj (src, _range, _power, _color, _duration)


/obj/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	if(!_duration)
		stack_trace("Lighting FX obj created on a obj without a duration")
	new /obj/effect/dummy/lighting_obj (get_turf(src), _range, _power, _color, _duration)


/mob/living/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = COLOR_WHITE, _duration = FLASH_LIGHT_DURATION)
	mob_light(_range, _power, _color, _duration)


/mob/living/proc/mob_light(_range, _power, _color, _duration)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = new (src, _range, _power, _color, _duration)
	return mob_light_obj


/atom/proc/set_light_range(new_range)
	if(new_range == light_range)
		return
	if (light_system == NO_LIGHT_SUPPORT)
		light_system = MOVABLE_LIGHT
		AddComponent(/datum/component/overlay_lighting)
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_RANGE, new_range)
	. = light_range
	light_range = new_range


/atom/proc/set_light_power(new_power)
	if(new_power == light_power)
		return
	if (light_system == NO_LIGHT_SUPPORT)
		light_system = MOVABLE_LIGHT
		AddComponent(/datum/component/overlay_lighting)
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_POWER, new_power)
	. = light_power
	light_power = new_power


/atom/proc/set_light_color(new_color)
	if(new_color == light_color)
		return
	if (light_system == NO_LIGHT_SUPPORT)
		light_system = MOVABLE_LIGHT
		AddComponent(/datum/component/overlay_lighting)
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_COLOR, new_color)
	. = light_color
	light_color = new_color


/atom/proc/set_light_on(new_value)
	if(new_value == light_on)
		return
	if (light_system == NO_LIGHT_SUPPORT)
		light_system = MOVABLE_LIGHT
		AddComponent(/datum/component/overlay_lighting)
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_ON, new_value)
	. = light_on
	light_on = new_value


/atom/proc/set_light_flags(new_value)
	if(new_value == light_flags)
		return
	if (light_system == NO_LIGHT_SUPPORT)
		light_system = MOVABLE_LIGHT
		AddComponent(/datum/component/overlay_lighting)
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_FLAGS, new_value)
	. = light_flags
	light_flags = new_value
