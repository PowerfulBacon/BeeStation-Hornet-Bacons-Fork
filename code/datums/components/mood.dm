/datum/component/mood
	var/mood //Real happiness
	var/shown_mood //Shown happiness, this is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/mood_level = 5 //To track what stage of moodies they're on
	var/mood_modifier = 1 //Modifier to allow certain mobs to be less affected by moodlets
	var/list/datum/mood_event/mood_events = list()
	var/atom/movable/screen/mood/screen_obj

/datum/component/mood/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSmood, src)

	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, PROC_REF(add_event))
	RegisterSignal(parent, COMSIG_CLEAR_MOOD_EVENT, PROC_REF(clear_event))
	RegisterSignal(parent, COMSIG_MOVABLE_ENTERED_AREA, PROC_REF(check_area_mood))

	RegisterSignal(parent, COMSIG_MOB_HUD_CREATED, PROC_REF(modify_hud))
	var/mob/living/owner = parent
	if(owner.hud_used)
		modify_hud()
		var/datum/hud/hud = owner.hud_used
		hud.show_hud(hud.hud_version)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSmood, src)
	unmodify_hud()
	QDEL_LIST_ASSOC_VAL(mood_events)
	return ..()

/datum/component/mood/proc/print_mood(mob/user)
	var/msg = "<span class='info'><EM>Your current mood</EM>\n"
	msg += "<span class='notice'>My mental status: </span>" //Long term

	msg += "<span class='notice'>My current mood: </span>" //Short term
	switch(mood_level)
		if(1)
			msg += "<span class='boldwarning'>I wish I was dead!</span>\n"
		if(2)
			msg += "<span class='boldwarning'>I feel terrible...</span>\n"
		if(3)
			msg += "<span class='boldwarning'>I feel very upset.</span>\n"
		if(4)
			msg += "<span class='boldwarning'>I'm a bit sad.</span>\n"
		if(5)
			msg += "<span class='nicegreen'>I'm alright.</span>\n"
		if(6)
			msg += "<span class='nicegreen'>I feel pretty okay.</span>\n"
		if(7)
			msg += "<span class='nicegreen'>I feel pretty good.</span>\n"
		if(8)
			msg += "<span class='nicegreen'>I feel amazing!</span>\n"
		if(9)
			msg += "<span class='nicegreen'>I love life!</span>\n"

	msg += "<span class='notice'>Moodlets:\n</span>"//All moodlets
	var/mood_msg = ""
	var/thought_msg = ""
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		if(event.mood_change)
			mood_msg += "[event.description]\n"
		else
			thought_msg += "[event.description]\n"
	if(!mood_msg)
		msg += "<span class='mood_neutral'>I don't have much of a reaction to anything right now.<span>\n"
	msg += mood_msg
	if(thought_msg)
		msg += "<span class='notice'>Thoughts:</span>\n"
		msg += thought_msg
	to_chat(user || parent, EXAMINE_BLOCK(msg))

/datum/component/mood/proc/update_mood() //Called whenever a mood event is added or removed
	mood = 0
	shown_mood = 0
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		var/mob/living/owner = parent
		var/mood_change = event.mood_change
		if(owner.has_quirk(/datum/quirk/hypersensitive) && (mood_change<0))
			mood_change*=1.5
		if(owner.has_quirk(/datum/quirk/apathetic) && (mood_change<0))
			mood_change*=0.5
		mood += mood_change
		if(!event.hidden)
			shown_mood += mood_change
		mood *= mood_modifier
		shown_mood *= mood_modifier

	switch(mood)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9
	update_mood_icon()


/datum/component/mood/proc/update_mood_icon()
	var/mob/living/owner = parent
	if(!(owner.client || owner.hud_used))
		return
	screen_obj.cut_overlays()
	screen_obj.color = initial(screen_obj.color)
	//lets see if we have any special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for(var/i in mood_events) //adds overlays and sees which special icons need to vie for which one gets the icon_state
		var/datum/mood_event/event = mood_events[i]
		if(!event.special_screen_obj)
			continue
		if(!event.special_screen_replace)
			screen_obj.add_overlay(event.special_screen_obj)
		else
			conflicting_moodies += event
			var/absmood = abs(event.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood

	for(var/i in conflicting_moodies)
		var/datum/mood_event/event = i
		if(abs(event.mood_change) == highest_absolute_mood)
			screen_obj.icon_state = "[event.special_screen_obj]"
			switch(mood_level)
				if(1)
					screen_obj.color = "#747690"
				if(2)
					screen_obj.color = "#f15d36"
				if(3)
					screen_obj.color = "#f38a43"
				if(4)
					screen_obj.color = "#dfa65b"
				if(5)
					screen_obj.color = "#4b96c4"
				if(6)
					screen_obj.color = "#a8d259"
				if(7)
					screen_obj.color = "#86d656"
				if(8)
					screen_obj.color = "#30dd26"
				if(9)
					screen_obj.color = "#2eeb9a"
			break

///Called on SSmood process
/datum/component/mood/process(delta_time)
	var/mob/living/owner = parent
	HandleNutrition(owner)

/datum/component/mood/proc/add_event(datum/source, category, type, param) //Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
	SIGNAL_HANDLER

	var/datum/mood_event/the_event
	if(!istext(category))
		category = REF(category)
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(null, category)
		else
			if(the_event.timeout)
				the_event.timer = addtimer(CALLBACK(src, PROC_REF(clear_event), null, category), the_event.timeout, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_OVERRIDE)
			return 0 //Don't have to update the event.
	the_event = new type(src, param)

	mood_events[category] = the_event
	the_event.category = category
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, PROC_REF(clear_event), null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/component/mood/proc/clear_event(datum/source, category)
	SIGNAL_HANDLER

	if(!istext(category))
		category = REF(category)
	var/datum/mood_event/event = mood_events[category]
	if(!event)
		return 0

	mood_events -= category
	qdel(event)
	update_mood()

/datum/component/mood/proc/get_event(category)
	if(!istext(category))
		category = REF(category)
	return mood_events[category]

/datum/component/mood/proc/remove_temp_moods(var/admin) //Removes all temp moods
	for(var/i in mood_events)
		var/datum/mood_event/moodlet = mood_events[i]
		if(!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet.category
		qdel(moodlet)
		update_mood()


/datum/component/mood/proc/modify_hud(datum/source)
	SIGNAL_HANDLER

	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	hud.infodisplay += screen_obj
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, PROC_REF(unmodify_hud))
	RegisterSignal(screen_obj, COMSIG_CLICK, PROC_REF(hud_click))

/datum/component/mood/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER

	if(!screen_obj)
		return
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	if(hud?.infodisplay)
		hud.infodisplay -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	print_mood(user)

/datum/component/mood/proc/HandleNutrition(mob/living/L)
	if(HAS_TRAIT(L, TRAIT_NOHUNGER))
		return FALSE //no mood events for nutrition
	if(HAS_TRAIT(L, TRAIT_POWERHUNGRY))
		HandleCharge(L)
		return
	switch(L.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			if (!HAS_TRAIT(L, TRAIT_VORACIOUS))
				add_event(null, "nutrition", /datum/mood_event/fat)
			else
				add_event(null, "nutrition", /datum/mood_event/wellfed) // round and full
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			add_event(null, "nutrition", /datum/mood_event/wellfed)
		if( NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			add_event(null, "nutrition", /datum/mood_event/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			clear_event(null, "nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			add_event(null, "nutrition", /datum/mood_event/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_event(null, "nutrition", /datum/mood_event/starving)

/datum/component/mood/proc/HandleCharge(mob/living/L)
	switch(L.nutrition)
		if(NUTRITION_LEVEL_WELL_FED to INFINITY)
			add_event(null, "nutrition", /datum/mood_event/charged)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			clear_event(null, "nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_FED)
			add_event(null, "nutrition", /datum/mood_event/lowpower)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_event(null, "nutrition", /datum/mood_event/decharged)

/datum/component/mood/proc/check_area_mood(datum/source, var/area/A)
	SIGNAL_HANDLER

	var/mob/living/owner = parent

	if(A.mood_check(owner))
		if(get_event("area"))	//walking between areas that give mood bonus should first clear the bonus from the previous one
			clear_event(null, "area")
		add_event(null, "area", /datum/mood_event/area, list(A.mood_bonus, A.mood_message))
	else
		clear_event(null, "area")
