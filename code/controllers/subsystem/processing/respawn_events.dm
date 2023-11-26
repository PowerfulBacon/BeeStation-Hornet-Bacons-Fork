PROCESSING_SUBSYSTEM_DEF(respawn_events)
	name = "Respawn Events"
	wait = 1 SECONDS
	stat_tag = "RSPWN"
	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_BACKGROUND
	/// Time in which respawn event will occur
	var/respawn_event_time = 20 MINUTES
