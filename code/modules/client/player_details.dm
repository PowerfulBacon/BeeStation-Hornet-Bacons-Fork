/datum/player_details
	var/list/player_actions = list()
	var/list/logging = list()
	var/list/post_login_callbacks = list()
	var/list/post_logout_callbacks = list()
	var/list/played_names = list() //List of names this key played under this round
	var/byond_version = "Unknown"
	var/datum/achievement_data/achievements
	/// Whether or not this client has voted to leave
	var/voted_to_leave = FALSE
	/// The current state of the player
	var/player_state = PLAYER_STATE_LIVING
	/// The time of death, or null if the player has not died.
	/// Used for metrics tracking only, use timeofdeath on /mob/living
	/// for standard cases.
	var/time_of_death = null

/datum/player_details/New(key)
	achievements = new(key)

/proc/log_played_names(ckey, ...)
	if(!ckey)
		return
	if(args.len < 2)
		return
	var/list/names = args.Copy(2)
	var/datum/player_details/P = GLOB.player_details[ckey]
	if(P)
		for(var/name in names)
			if(name)
				P.played_names |= name
