/**
  * # Chat Message Overlay
  *
  * Datum for generating a message overlay on the map
  */
/datum/chatmessage
	/// The message image holder
	/// All messages exist inside of this message's vis contents
	var/image/parent_image
	/// A list of the visual chat message elements
	/// Assoc list:
	/// Key: The key of the message (A flag integer converted to a string)
	/// Value: The associated chat message image
	/// All messages in this group contain the same text, but different ways of formatting it
	var/list/messages
	/// The location in which the message is appearing
	var/atom/message_loc
	/// A list of clients who hear this message
	var/list/hearers
	/// Contains the scheduled destruction time, used for scheduling EOL
	var/scheduled_destruction
	/// Contains the time that the EOL for the message will be complete, used for qdel scheduling
	var/eol_complete
	/// Contains the approximate amount of lines for height decay
	var/approx_lines
	/// Contains the reference to the next chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/next
	/// Contains the reference to the previous chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/prev
	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// Maximum height of all possible messages
	var/mheight
	/// Color of the message
	var/tgt_color
	/// The queue of people to show the messages to once they have been generated
	var/list/client_queue

/**
  * Constructs a chat message overlay
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * language - The language the message is spoken in
  * * extra_classes - Extra classes to apply to the span that holds the text
  * * lifespan - The lifespan of the message in deciseconds
  */
/datum/chatmessage/New(
		text, atom/target,
		language, list/extra_classes = list(),
		lifespan = CHAT_MESSAGE_LIFESPAN
		)
	. = ..()
	if (!istype(target))
		CRASH("Invalid target given for chatmessage")
	//Trigger image generation
	INVOKE_ASYNC(src, .proc/generate_images, text, target, language, extra_classes, lifespan)

/datum/chatmessage/Destroy()
	if (hearers)
		for(var/client/C in hearers)
			if(!C)
				continue
			C.images.Remove(hearers[C])
			C.images.Remove(parent_image)
			UnregisterSignal(C, COMSIG_PARENT_QDELETING)
	if(!QDELETED(message_loc))
		LAZYREMOVE(message_loc.chat_messages, src)
	hearers = null
	message_loc = null
	parent_image = null
	messages = null
	message_admins("messages deleted")
	leave_subsystem()
	return ..()

/**
  * Calls qdel on the chatmessage when its parent is deleted, used to register qdel signal
  */
/datum/chatmessage/proc/on_parent_qdel()
	SIGNAL_HANDLER
	qdel(src)

/**
  * Generates a chat message image representation
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * language - The language this message was spoken in
  * * extra_classes - Extra classes to apply to the span that holds the text
  * * lifespan - The lifespan of the message in deciseconds
  */
/datum/chatmessage/proc/generate_images(text, atom/target, datum/language/language, list/extra_classes, lifespan)
	/// Cached icons to show what language the user is speaking
	var/static/list/language_icons

	// Reject whitespace
	var/static/regex/whitespace = new(@"^\s*$")
	if (whitespace.Find(text))
		qdel(src)
		return

	// Get a client to do our measuring
	var/client/first_hearer = GLOB.clients[1]

	// Remove spans in the message from things like the recorder
	var/static/regex/span_check = new(@"<\/?span[^>]*>", "gi")
	text = replacetext(text, span_check, "")

	// Clip message
	if (length_char(text) > CHAT_MESSAGE_MAX_LENGTH)
		text = copytext_char(text, 1, CHAT_MESSAGE_MAX_LENGTH + 1) + "..." // BYOND index moment

	// Get the chat color
	if(!tgt_color)		//in case we have color predefined
		tgt_color = get_message_colour(target)

	// Get rid of any URL schemes that might cause BYOND to automatically wrap something in an anchor tag
	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	text = replacetext(text, url_scheme, "")

	//=======================
	// Work out maximum possible message length
	//=======================

	//Track the maximum possible prefix length
	var/list/max_prefixes

	//Track if this is an emote or not
	var/is_emote = FALSE

	//Static radio icon prefix
	var/static/image/r_icon = image('icons/UI_Icons/chat/chat_icons.dmi', icon_state = "radio")

	//Get the language icon
	//Append the language as a possible prefix
	var/datum/language/language_instance = GLOB.language_datum_instances[language]
	var/icon/language_icon = LAZYACCESS(language_icons, language)
	if (isnull(language_icon))
		language_icon = icon(language_instance.icon, icon_state = language_instance.icon_state)
		language_icon.Scale(CHAT_MESSAGE_ICON_SIZE, CHAT_MESSAGE_ICON_SIZE)
		LAZYSET(language_icons, language, language_icon)

	//Work out the max amount of prefixes we can have
	if (extra_classes.Find("emote"))
		var/static/image/e_icon = image('icons/UI_Icons/chat/chat_icons.dmi', icon_state = "emote")
		LAZYADD(max_prefixes, "\icon[e_icon]")
		tgt_color = COLOR_CHAT_EMOTE
		is_emote = TRUE
	else
		//Append the radio speaker as a possible prefix
		LAZYADD(max_prefixes, "\icon[r_icon]")
		//Append the language icon as a possible prefix
		LAZYADD(max_prefixes, "\icon[language_icon]")

	//=======================
	// Measure the maximum length of the provided text
	//=======================

	// Approximate text height
	var/complete_text = "<span class='center [extra_classes.Join(" ")]' style='color: [tgt_color]'>[max_prefixes?.Join("&nbsp;")][text]</span>"
	mheight = WXH_TO_HEIGHT(first_hearer.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH))
	approx_lines = max(1, mheight / CHAT_MESSAGE_APPROX_LHEIGHT)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	message_loc = get_atom_on_turf(target)
	if (LAZYLEN(message_loc.chat_messages))
		var/idx = 1
		var/combined_height = approx_lines
		for(var/datum/chatmessage/m as() in message_loc.chat_messages)
			if(!m?.parent_image)
				continue
			animate(m.parent_image, pixel_y = m.parent_image.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME)
			combined_height += m.approx_lines

			// When choosing to update the remaining time we have to be careful not to update the
			// scheduled time once the EOL completion time has been set.
			var/sched_remaining = m.scheduled_destruction - world.time
			if (!m.eol_complete)
				var/remaining_time = (sched_remaining) * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** CEILING(combined_height, 1))
				m.enter_subsystem(world.time + remaining_time) // push updated time to runechat SS

	//=======================
	// Generate messages
	//=======================
	//Create the parent image holder
	parent_image = image(loc = message_loc)

	var/bound_height = world.icon_size
	if(ismovableatom(message_loc))
		var/atom/movable/AM = message_loc
		bound_height = AM.bound_height

	parent_image.pixel_y = bound_height - MESSAGE_FADE_PIXEL_Y
	animate(parent_image, alpha = 255, pixel_y = bound_height, time = CHAT_MESSAGE_SPAWN_TIME)

	if(is_emote)
		//Emote message only has 1 possible message image
		messages = list("0" = generate_image(text, max_prefixes, list("italics"), parent_image))
	else
		messages = list()
		//Generate all possible message images
		for(var/i in 0 to CHAT_MESSAGE_FLAG_MAXIMUM)
			var/output_text = text
			var/prefixes = list()
			//Check if the text should be scrambled
			if(i & CHAT_MESSAGE_SCRAMBLED)
				output_text = language_instance?.scramble(text) || scramble_message_replace_chars(text, 100)
			//Check if the message should show the language icon
			if(i & CHAT_MESSAGE_LANGUAGE_ICON)
				prefixes += "\icon[language_icon]"
			//Check if the message should show the radio icon
			if(i & CHAT_MESSAGE_VIRTUAL_SPEAKER)
				prefixes += "\icon[r_icon]"
			//Generate the image and store it
			messages["[i]"] = generate_image(output_text, prefixes, extra_classes, parent_image)

	message_admins("created chat message [json_encode(messages)]")

	LAZYADD(message_loc.chat_messages, src)

	for(var/client/C in client_queue)
		var/client_flags = client_queue[C]
		show_chat_message(C, client_flags)
	client_queue = null

	// Register with the runechat SS to handle EOL and destruction
	scheduled_destruction = world.time + (lifespan - CHAT_MESSAGE_EOL_FADE)
	enter_subsystem()

/datum/chatmessage/proc/show_chat_message(client/hearer, message_flags)
	//Due to async image creation, the clients are put in a queue
	if(!messages)
		if(!client_queue)
			client_queue = list()
		client_queue[hearer] = message_flags
		return
	//Get the message image to display
	var/image/message_image = messages["[message_flags]"]
	//Throw an error if the message image isn't known
	if(!message_image)
		CRASH("Error: Invalid message flags provided for message ([message_flags]). Either message flags are out of bounds, or message is an emote and flags are provided.")
	//Show the message image to the client
	if(!hearers)
		hearers = list()
	hearers[hearer] = message_image
	hearer.images |= parent_image
	hearer.images |= message_image
	RegisterSignal(hearer, COMSIG_PARENT_QDELETING, .proc/on_parent_qdel)

/**
  * Generates an image containing the maptext of the message.
  *
  * Arguments:
  * * display_text - The text to display
  * * prefixes (/list) - A list of prefixes to prepend to the message
  * * extra_classes (/list) - The extra classes to add
  */
/datum/chatmessage/proc/generate_image(display_text, list/prefixes, list/extra_classes, image/parent)
	var/complete_text = "<span class='center [extra_classes.Join(" ")]' style='color: [tgt_color]'>[prefixes?.Join("&nbsp;")][display_text]</span>"

	// Reset z index if relevant
	if (current_z_idx >= CHAT_LAYER_MAX_Z)
		current_z_idx = 0

	var/bound_width = world.icon_size
	if(ismovableatom(message_loc))
		var/atom/movable/AM = message_loc
		bound_width = AM.bound_width

	// Build message image
	var/image/message = image(loc = message_loc, layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx++)
	message.plane = RUNECHAT_PLANE
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	message.alpha = 0
	message.maptext_width = CHAT_MESSAGE_WIDTH
	message.maptext_height = mheight
	message.maptext_x = (CHAT_MESSAGE_WIDTH - bound_width) * -0.5
	if(extra_classes.Find("italics"))
		message.color = "#CCCCCC"
	message.maptext = MAPTEXT(complete_text)

	return message

/**
  * Calculates a message colour based on the speaker's name.
  *
  * Arguments:
  * * target (/atom) - The target location of the message, determines the speaker for this message
  */
/datum/chatmessage/proc/get_message_colour(atom/target)
	if(isliving(target))		//target is living, thus we have preset color for him
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.wear_id?.GetID())
				var/obj/item/card/id/idcard = H.wear_id
				var/datum/job/wearer_job = SSjob.GetJob(idcard.GetJobName())
				if(wearer_job)
					//If the job datum was located, use that job's associated chat colour
					return wearer_job.chat_color
				//If the job datum wasn't located, use one from the job colours pastel list. (At this point it should be unknown, centcom or prisoner)
				return GLOB.job_colors_pastel[idcard.GetJobName()]
			//The speaker has no ID, return unknown
			return COLOR_PERSON_UNKNOWN
		else if(!target.chat_color)
			//Target is not a human, generate a chat colour
			//extreme case - mob doesn't have set color
			stack_trace("Error: Mob did not have a chat_color. The only way this can happen is if you set it to null purposely in the thing. Don't do that please.")
	//The speaker still has no colour, generate one for them
	if(!target.chat_color || target.chat_color_name != target.name)
		target.chat_color = colorize_string(target.name)
		target.chat_color_name = target.name
	return target.chat_color

/**
  * Signal handler for client deletion
  * Derefences the client that got deleted
  *
  * Arguments:
  * * source (/client) - The client that has been deleted
  */
/datum/chatmessage/proc/client_deleted(client/source)
	SIGNAL_HANDLER
	hearers -= source

/**
  * Applies final animations to overlay CHAT_MESSAGE_EOL_FADE deciseconds prior to message deletion,
  * sets time for scheduling deletion and re-enters the runechat SS for qdeling
  *
  * Arguments:
  * * fadetime - The amount of time to animate the message's fadeout for
  */
/datum/chatmessage/proc/end_of_life(fadetime = CHAT_MESSAGE_EOL_FADE)
	eol_complete = scheduled_destruction + fadetime
	animate(parent_image, alpha = 0, pixel_y = parent_image.pixel_y + MESSAGE_FADE_PIXEL_Y, time = fadetime, flags = ANIMATION_PARALLEL)
	enter_subsystem(eol_complete) // re-enter the runechat SS with the EOL completion time to QDEL self

/mob/proc/should_show_chat_message(atom/movable/speaker, datum/language/message_language, is_emote = FALSE, is_heard = FALSE)
	if(!client)
		return CHATMESSAGE_CANNOT_HEAR
	if(!client.prefs.chat_on_map || (!client.prefs.see_chat_non_mob && !ismob(speaker)))
		return CHATMESSAGE_CANNOT_HEAR
	if(!client.prefs.see_rc_emotes && is_emote)
		return CHATMESSAGE_CANNOT_HEAR
	if(is_heard && !can_hear())
		return CHATMESSAGE_CANNOT_HEAR
	//If the speaker is a virtual speaker, check to make sure we couldnt hear the original message.
	if(istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/v = speaker
		//Dont create the overhead chat if we said the message.
		if(v.source == src)
			return CHATMESSAGE_CANNOT_HEAR
		//Dont create the overhead radio chat if we are a ghost and can hear global messages.
		if(isobserver(src))
			return CHATMESSAGE_CANNOT_HEAR
		//Dont create the overhead radio chat if we heard the speaker speak
		if(get_dist(get_turf(v.source), get_turf(src)) <= 1)
			return CHATMESSAGE_CANNOT_HEAR
		//The AI shouldn't be able to see the overhead chat trough the static
		if(isAI(src) && !GLOB.cameranet.checkCameraVis(v.source))
			return CHATMESSAGE_CANNOT_HEAR
	var/datum/language/language_instance = GLOB.language_datum_instances[message_language]
	if(language_instance?.display_icon(src))
		return CHATMESSAGE_SHOW_LANGUAGE_ICON
	return CHATMESSAGE_HEAR

/mob/living/should_show_chat_message(atom/movable/speaker, datum/language/message_language, is_emote = FALSE, is_heard = FALSE)
	if(stat != CONSCIOUS && stat != DEAD)
		return CHATMESSAGE_CANNOT_HEAR
	return ..()

/**
  * Takes in a mob and data about a message and returns the chat message visibility flags
  * Returns -1 if the message should not be displayed
  */
/mob/proc/get_chatmessage_flags(atom/movable/speaker, datum/language/message_language, message_mods)
	var/should_show_result = should_show_chat_message(speaker, message_language)
	. = 0
	//Check for the language icon flag
	switch(should_show_result)
		if(CHATMESSAGE_SHOW_LANGUAGE_ICON)
			. |= CHAT_MESSAGE_LANGUAGE_ICON
		if(CHATMESSAGE_CANNOT_HEAR)
			return -1
	//Check for virtual speakers
	if(istype(speaker, /atom/movable/virtualspeaker) || message_mods[MODE_RADIO_MESSAGE])
		. |= CHAT_MESSAGE_VIRTUAL_SPEAKER
	//Check for scrambling
	if(message_language && !has_language(message_language))
		. |= CHAT_MESSAGE_SCRAMBLED

/**
  * Creates and returns a chat message, shown to the provided speakers.
  * The created chat message can be passed down the chain through hear() and displayed to anyone that hears it
  */
/proc/create_chat_message(atom/movable/speaker, datum/language/message_language, raw_message, list/spans, list/message_mods)
	if(!islist(message_mods))
		message_mods = list()

	if(message_mods.Find(CHATMESSAGE_EMOTE))
		return new /datum/chatmessage(raw_message, speaker, message_language, list("emote"))
	else
		return new /datum/chatmessage(raw_message, speaker, message_language, spans)

/**
  * Creates a message overlay at a defined location for a given speaker
  *
  * Arguments:
  * * speaker - The atom who is saying this message
  * * message_language - The language that the message is said in
  * * raw_message - The text content of the message
  * * spans - Additional classes to be added to the message
  */



// Tweak these defines to change the available color ranges
#define CM_COLOR_SAT_MIN	0.6
#define CM_COLOR_SAT_MAX	0.7
#define CM_COLOR_LUM_MIN	0.65
#define CM_COLOR_LUM_MAX	0.75

/**
  * Gets a color for a name, will return the same color for a given string consistently within a round.atom
  *
  * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
  *
  * Arguments:
  * * name - The name to generate a color for
  * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
  * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
  */
/datum/chatmessage/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + GLOB.round_id), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s *= clamp(sat_shift, 0, 1)
	l *= clamp(lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"

/atom/proc/balloon_alert(mob/viewer, text)
	if(!viewer?.client)
		return
	switch(viewer.client.prefs.see_balloon_alerts)
		if(BALLOON_ALERT_ALWAYS)
			new /datum/chatmessage/balloon_alert(text, src, viewer)
		if(BALLOON_ALERT_WITH_CHAT)
			new /datum/chatmessage/balloon_alert(text, src, viewer)
			to_chat(viewer, "<span class='notice'>[text].</span>")
		if(BALLOON_ALERT_NEVER)
			to_chat(viewer, "<span class='notice'>[text].</span>")

/atom/proc/balloon_alert_to_viewers(message, self_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs)
	var/list/hearers = get_hearers_in_view(vision_distance, src)
	hearers -= ignored_mobs

	for (var/mob/hearer in hearers)
		if (is_blind(hearer))
			continue

		balloon_alert(hearer, (hearer == src && self_message) || message)

/datum/chatmessage/balloon_alert
	tgt_color = "#ffffff"

/datum/chatmessage/balloon_alert/New(text, atom/target, mob/owner)
	if (!istype(target))
		CRASH("Invalid target given for chatmessage")
	if(QDELETED(owner) || !istype(owner) || !owner.client)
		stack_trace("/datum/chatmessage created with [isnull(owner) ? "null" : "invalid"] mob owner")
		qdel(src)
		return
	INVOKE_ASYNC(src, .proc/generate_image, text, target, owner)

/datum/chatmessage/balloon_alert/generate_image(text, atom/target, mob/owner)
	// Register client who owns this message
	var/client/owned_by = owner.client
	RegisterSignal(owned_by, COMSIG_PARENT_QDELETING, .proc/on_parent_qdel)

	var/bound_width = world.icon_size
	if (ismovable(target))
		var/atom/movable/movable_source = target
		bound_width = movable_source.bound_width

	if(isturf(target))
		message_loc = target
	else
		message_loc = get_atom_on_turf(target)

	// Build message image
	parent_image = image(loc = message_loc, layer = CHAT_LAYER)
	parent_image.plane = BALLOON_CHAT_PLANE
	parent_image.alpha = 0
	parent_image.maptext_width = BALLOON_TEXT_WIDTH
	parent_image.maptext_height = WXH_TO_HEIGHT(owned_by?.MeasureText(text, null, BALLOON_TEXT_WIDTH))
	parent_image.maptext_x = (BALLOON_TEXT_WIDTH - bound_width) * -0.5
	parent_image.maptext = MAPTEXT("<span style='text-align: center; -dm-text-outline: 1px #0005; color: [tgt_color]'>[text]</span>")

	// View the message
	owned_by.images += parent_image

	var/duration_mult = 1
	var/duration_length = length(text) - BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MIN

	if(duration_length > 0)
		duration_mult += duration_length * BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MULT

	// Animate the message
	animate(
		parent_image,
		pixel_y = world.icon_size * 1.2,
		time = BALLOON_TEXT_TOTAL_LIFETIME(1),
		easing = SINE_EASING | EASE_OUT,
	)

	animate(
		alpha = 255,
		time = BALLOON_TEXT_SPAWN_TIME,
		easing = CUBIC_EASING | EASE_OUT,
		flags = ANIMATION_PARALLEL,
	)

	animate(
		alpha = 0,
		time = BALLOON_TEXT_FULLY_VISIBLE_TIME * duration_mult,
		easing = CUBIC_EASING | EASE_IN,
	)

	// Register with the runechat SS to handle EOL and destruction
	scheduled_destruction = world.time + BALLOON_TEXT_TOTAL_LIFETIME(duration_mult)
	enter_subsystem()
