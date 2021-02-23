/client/verb/mentor_assist()
	set category = "Mentor"
	set name = "Request Assistance"

	if(prefs.muted & MUTE_MHELP)
		to_chat(src, "<span class='danger'>Error: MENTORHELP: You cannot send mentorhelps (Muted).</span>")
		return

	//clean the input msg
	if(!msg)	return

	//remove out mentorhelp verb temporarily to prevent spamming of mentors.
	remove_verb(/client/verb/mentor_assist)
	spawn(300)
		add_verb(/client/verb/mentor_assist)	// 30 second cool-down for mentorhelp

	if(!istype(mob, /mob/living))
		return

	var/show_char = CONFIG_GET(flag/mentors_mobname_only)
	var/mentor_msg = "<span class='mentornotice'><b><span class='mentorhelp'>MENTORHELP:</b> <b>[key_name_mentor(src, 1, 0, 1, show_char)]</b>: [msg]</span></span>"
	log_mentor("MENTOR ASSISTANCE REQUESTED: [key_name_mentor(src, 0, 0, 0, 0)]")

	var/any_available = FALSE
	for(var/client/X in GLOB.mentors | GLOB.admins)
		if(istype(X.mob, /mob/dead/observer))
			X << 'sound/items/bikehorn.ogg'
			to_chat(X, mentor_msg)
			any_available = TRUE

	if(any_available)
		to_chat(src, "<span class='mentornotice'>You have requested for a mentor to assist you, if any are available they will spawn as a corgi that can only talk to you.</span>")
		to_chat(src, "<span class='mentornotice'>If nobody is available to spawn in and help you, you may use the mentorhelp verb to send a message to all mentors online, however they will not be able to see where you are or what you are doing, so make sure to describe your problem.</span>")
	else
		to_chat(src, "<span class='mentornotice'>All online mentors are currently in game. Use the mentorhelp verb to send them a private message (They will not be able to see you in the world or what you are doing, so make sure you describe your problem).</span>")
	return

//Helper mob
//Has little interaction on the world and can only be understood by master.

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor
	name = "Guide Dog"
	desc = "Space is a dangerous place. This will help you get by."
	animal_species = /mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	move_resist = 0
	layer = BELOW_MOB_LAYER
	can_be_held = FALSE
	del_on_death = TRUE
	var/mob/living/master
	var/warned = FALSE
	var/killtick = 0

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/proc/remove_mind_antag()
	if(!mind)
		return
	mind.remove_antag_datum(/datum/antagonist/helper_corgi)

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/Destroy()
	remove_mind_antag()
	. = ..()

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>You are a mentor corgi!</span>")
	to_chat(src, "<span class='warning'>You exist to assist [master] with learning the game.</span>")
	to_chat(src, "<span class='warning'>Abusing this role to impact the round is grounds for demotion.</span>")
	mind.add_antag_datum(/datum/antagonist/helper_corgi)

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/Logout()
	remove_mind_antag()
	. = ..()
	INVOKE_ASYNC(src, .proc/fade_away)

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/Life(seconds, times_fired)
	. = ..()
	if(killtick && world.time > killtick)
		to_chat(src, "<span class='warning'>You have lost your connection to this world.</span>")
		INVOKE_ASYNC(src, .proc/fade_away)
		return
	if(get_dist(src, master) > 8)
		if(!warned)
			to_chat(src, "<span class='warning'>You are getting too far away from your master, you will lose your connection to the world soon!</span>")
			warned = TRUE
		if(get_dist(src, master) > 14)
			if(!killtick)
				to_chat(src, "<span class='userdanger'>You will lose your connection to reality in 30 seconds.</span>")
				killtick = world.time + 300
		else
			killtick = 0
	else
		warned = FALSE
		killtick = 0
	if(master.stat)
		to_chat(src, "<span class='warning'>Your master has died, you cannot sustain this form any longer!</span>")
		INVOKE_ASYNC(src, .proc/fade_away)

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/proc/fade_away()
	animate(src, time = 30, alpha = 0)
	ghostize(FALSE)
	sleep(30)
	qdel(src)

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/can_unbuckle()
	return FALSE

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/can_buckle()
	return FALSE

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/start_pulling(atom/movable/AM, state, force, supress_message)
	return

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/restrained(ignore_grab)
	return FALSE

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, message_mode)
	var/static/list/eavesdropping_modes = list(MODE_WHISPER = TRUE, MODE_WHISPER_CRIT = TRUE)
	var/eavesdrop_range = 0
	if(eavesdropping_modes[message_mode])
		eavesdrop_range = EAVESDROP_EXTRA_RANGE
	var/list/listening = get_hearers_in_view(message_range+eavesdrop_range, source)
	var/list/the_dead = list()
	for(var/mob/M as() in GLOB.player_list)
		if(!M)				//yogs
			continue		//yogs | null in player_list for whatever reason :shrug:
		if(M.stat != DEAD) //not dead, not important
			continue
		if(!M.client || !client) //client is so that ghosts don't have to listen to mice
			continue
		if(get_dist(M, src) > 7 || M.z != z) //they're out of range of normal hearing
			if(eavesdropping_modes[message_mode] && !(M.client.prefs.chat_toggles & CHAT_GHOSTWHISPER)) //they're whispering and we have hearing whispers at any range off
				continue
			if(!(M.client.prefs.chat_toggles & CHAT_GHOSTEARS)) //they're talking normally and we have hearing at any range off
				continue
		listening |= M
		the_dead[M] = TRUE

	//For anyone that isnt the master, scramble the words.
	var/changed_message = pick(speak)

	var/eavesdropping
	var/eavesrendered
	if(eavesdrop_range)
		eavesdropping = stars(changed_message)
		eavesrendered = compose_message(src, message_language, eavesdropping, , spans, message_mode)

	//Handle chat for master
	listening -= master
	master.Hear(
		compose_message(src, message_language, message, , spans, message_mode),
		src, message_language, message, , spans, message_mode)
	INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_chat, src, message, message_language, message_mode, list(master), 50) // see chatheader.dm

	//Handle chat for the non master
	var/rendered = compose_message(src, message_language, changed_message, , spans, message_mode)
	for(var/atom/movable/AM as() in listening)
		if(eavesdrop_range && get_dist(source, AM) > message_range && !(the_dead[AM]))
			AM.Hear(eavesrendered, src, message_language, eavesdropping, , spans, message_mode)
		else if(the_dead[AM])
			AM.Hear(rendered, src, message_language, message, , spans, message_mode)
		else
			AM.Hear(rendered, src, message_language, changed_message, , spans, message_mode)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_LIVING_SAY_SPECIAL, src, changed_message)

	//speech bubble
	var/list/fake_speach_hearers = list()
	for(var/mob/M in listening)
		if(M.client && M != master)
			fake_speach_hearers.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type][say_test(message)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_speechbubble, I, speech_bubble_recipients, 30)
	INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_chat, src, changed_message, message_language, message_mode, speech_bubble_recipients, 50) // see chatheader.dm

//Antag datum - Prevents mind from changing mob

/datum/antagonist/helper_corgi
	name = "Assistant Corgi"
	antagpanel_category = "Mentors"	//The worst kind of antags
	show_in_roundend = FALSE
	delay_roundend = FALSE
	give_objectives = FALSE
	replace_banned = FALSE

/datum/antagonist/helper_corgi/on_gain()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/antagonist/helper_corgi/on_removal()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/datum/antagonist/helper_corgi/process()
	if(QDELETED(owner) || !owner.current)
		return PROCESS_KILL
	if(!istype(owner.current, /mob/living/simple_animal/pet/dog/corgi/exoticcorgi/mentor))
		message_admins("[ADMIN_LOOPUPFLW(owner.current)] has changed body as a helper corgi and may be attempting to exploit the system. It is recommended you talk to them about how this happened.")
		qdel(owner)
		return PROCESS_KILL
