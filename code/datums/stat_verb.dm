/datum/stat_verb
	/// The ID of the verb
	var/id
	/// A text string of the verb's name.
	var/name
	/// The verb's help text or description.
	var/desc
	/// The category or tab the verb will appear in.
	var/category
	/// Only clients/mobs with `see_invisibility` higher can use the verb.
	var/invisibility
	/// The code callback to execute when pressed
	var/datum/callback/code_callback

/datum/stat_verb/New(procpath/base_proc)
	. = ..()
	if (base_proc != null)
		name = name || base_proc.name
		desc = desc || base_proc.desc
		category = category || base_proc.category
		invisibility = invisibility || base_proc.invisibility
	if (!id)
		id = name
	if (!code_callback)
		code_callback = CALLBACK(src, .proc/default_click_behaviour)

/// Execute the command as the player by default
/datum/stat_verb/proc/default_click_behaviour(client/caller, list/params)
	winset(caller, null, "command=[replacetext(name, " ", "-")]")
