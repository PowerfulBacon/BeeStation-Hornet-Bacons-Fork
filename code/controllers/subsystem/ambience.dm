/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS
	/// The index we are currently operating on in the client list
	// Despite being a cold path, we will use good optimisation practices for the
	// subsystems that copy other subsystems but actually run hot.
	var/operating_index
	///Assoc list of ckey - /datum/ambience_profile
	var/list/ambience_listening_clients = list()

/datum/controller/subsystem/ambience/proc/register_ambient_listener(client/target)
	var/datum/ambience_profile/located_profile = ambience_listening_clients[target.ckey]
	// Create a new profile if they need one
	if (!located_profile)
		located_profile = new(target)
		// This adds to the end of the list, as to not affect our current run
		// We need to be careful not to insert/remove elements before the current operating_index
		ambience_listening_clients[target.ckey] = located_profile

/datum/controller/subsystem/ambience/fire(resumed)
	if (!operating_index)
		operating_index = ambience_listening_clients.len
	while (operating_index > 0)
		var/operating_ckey = ambience_listening_clients[operating_index]
		var/datum/ambience_profile/profile = ambience_listening_clients[operating_ckey]
		// Decrement the operating index, so we are pointing at the next element
		operating_index--
		// Nobody is listening, remove the reference to prevent building up things we need to process
		// unnecessarilly
		if(isnull(profile.parent))
			ambience_listening_clients -= operating_ckey
			continue
		// New player's never get ambience
		if(isnewplayer(profile.parent.mob))
			continue
		// Play music
		// Play effects


		if(ambience_listening_clients[client_iterator] > world.time)
			continue //Not ready for the next sound

		var/ambi_fx = pick(current_area.ambientsounds)

		play_ambience_music(client_iterator.mob, ambi_music, current_area)

		play_ambience_effects(client_iterator.mob, ambi_fx, current_area)

		ambience_listening_clients[client_iterator] = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/play_ambience_music(mob/M, _ambi_music, area/A) // Background music, the more OOC ambience, like eerie space music
	if(A.ambientmusic && !M.client?.channel_in_use(CHANNEL_AMBIENT_MUSIC))
		SEND_SOUND(M, sound(_ambi_music, repeat = 0, wait = 0, volume = 75, channel = CHANNEL_AMBIENT_MUSIC))

/datum/controller/subsystem/ambience/proc/play_ambience_effects(mob/M, _ambi_fx, area/A) // Effect, random sounds that will play at random times, IC (requires the user to be able to hear)
	if (length(A.ambientsounds) && M.can_hear_ambience() && !M.client?.channel_in_use(CHANNEL_AMBIENT_EFFECTS))
		SEND_SOUND(M, sound(_ambi_fx, repeat = 0, wait = 0, volume = 45, channel = CHANNEL_AMBIENT_EFFECTS))

/datum/controller/subsystem/ambience/proc/play_buzz(datum/ambience_profile/profile, area/A)
	if (A.ambient_buzz && (profile.parent.prefs.toggles & PREFTOGGLE_SOUND_SHIP_AMBIENCE) && profile.parent.mob.can_hear_ambience())
		if (!profile.buzz_playing || (A.ambient_buzz != profile.buzz_playing))
			profile.fade_sound(sound(A.ambient_buzz, repeat = 1, wait = 0, volume = 40))
			profile.buzz_playing = A.ambient_buzz // It's done this way so I can tell when the user switches to an area that has a different buzz effect, so we can seamlessly swap over to that one

	else if (M.client.buzz_playing) // If it's playing, and it shouldn't be, stop it
		M.stop_sound_channel(CHANNEL_BUZZ)
		M.client.buzz_playing = null

/datum/ambience_profile
	var/client/parent
	// Time of next whatevers
	var/next_ambient_sound
	var/next_music
	// The buzz currently playing
	var/buzz_playing
	// Fade handling
	var/current_proportion = 1
	var/target_proportion = 1
	// 0.2 per second
	var/fade_speed = 0.2
	var/processing = FALSE

/datum/ambience_profile/process(delta_time)
	// Change the track volumes
	var/delta = target_proportion - current_proportion
	delta = CLAMP(delta, -fade_speed * delta_time, fade_speed * delta_time)
	current_proportion += delta
	// Send sounds to change channel volumes
	var/sound/update_sound_1 = sound(null, volume = current_proportion * 40, channel = CHANNEL_BUZZ)
	update_sound_1.status = SOUND_UPDATE
	var/sound/update_sound_2 = sound(null, volume = (1 - current_proportion) * 40, channel = CHANNEL_BUZZ_2)
	update_sound_2.status = SOUND_UPDATE
	// Check if the client was deleted close to where we use it
	if (!parent)
		return PROCESS_KILL
	SEND_SOUND(parent, update_sound_1)
	SEND_SOUND(parent, update_sound_2)
	// Kill the process if no longer required
	if (current_proportion == target_proportion)
		processing = FALSE
		return PROCESS_KILL

/datum/ambience_profile/proc/fade_sound(sound/new_sound)
	if (current_proportion < 0.5)
		// Handle weird situations where we fade while fading already
		current_proportion = 0
		target_proportion = 1
		new_sound.channel = CHANNEL_BUZZ
		SEND_SOUND(parent, new_sound)
	else
		current_proportion = 1
		target_proportion = 0
		new_sound.channel = CHANNEL_BUZZ_2
		SEND_SOUND(parent, new_sound)
	if (!processing)
		processing = TRUE
		START_PROCESSING(SSfastprocess, src)
