/*
 * BYOND moment
 * Byond has verbs stored on /client and /atom, but they are a different variable,
 * So we have to make an override for /atom and /client that do exactly the same thing but affect a different variable.
 * Seriously, why wouldn't they all just be on client?
 *
 * Update:
 * Apparently client.verbs is always empty, but adding and removing from it still works?
 * Just going to use winset instead, since that seems to work.
 */

/datum
	///List of tabs to display on the stat
	var/list/stat_tabs
	///Verbs sorted alphabetically
	var/list/sorted_verbs
	///List of verbs by ID
	var/list/verbs_by_id

/datum/proc/add_verb(new_verbs)
	//Nooooo!!!!!
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!islist(new_verbs))
		new_verbs = list(new_verbs)
	//To use less memory
	if(!islist(sorted_verbs))
		sorted_verbs = list()
	if(!islist(stat_tabs))
		stat_tabs = list()
	for(var/verb_in_list in new_verbs)
		var/datum/stat_verb/V = verb_in_list
		if (!istype(V))
			V = new(verb_in_list)
		LAZYSET(verbs_by_id, "[V.id]", V)
		if(V.category)
			if(V.category in sorted_verbs)
				if(V in sorted_verbs[V.category])
					continue
				//Binary insert at the correct position
				var/list/verbs = sorted_verbs["[V.category]"]
				BINARY_INSERT_TEXT(V, verbs, datum/stat_verb, name)
			else
				//Add category with verb
				stat_tabs += V.category
				sorted_verbs["[V.category]"] = list(V)
				sortList(sorted_verbs)

/datum/proc/remove_verb(old_verbs)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!sorted_verbs)
		return
	if(!islist(old_verbs))
		old_verbs = list(old_verbs)
	for(var/verb_in_list in old_verbs)
		var/datum/stat_verb/V = verb_in_list
		if (!istype(V))
			V = new(verb_in_list)
		LAZYREMOVE(verbs_by_id, "[V.id]")
		//Find our category
		if("[V.category]" in sorted_verbs)
			//Remove the verb
			sorted_verbs["[V.category]"] -= V
			//Remove the category if necessary
			if(!LAZYLEN(sorted_verbs["[V.category]"]))
				sorted_verbs.Remove("[V.category]")
				stat_tabs -= V.category

/atom/add_verb(new_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!ignore_byond_verbs)
		verbs += new_verbs
	return ..(new_verbs)

/atom/remove_verb(old_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!ignore_byond_verbs)
		verbs -= old_verbs
	return ..(old_verbs)

/obj/item/remove_verb(new_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	//If we lose an old verb while in someone's inventory, remove it frmo their panel.
	if(item_flags & PICKED_UP)
		var/mob/living/L = loc
		if(istype(L) && L.client)
			L.client.remove_verbs(new_verbs)
	return ..(new_verbs)

/obj/item/add_verb(new_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	//If we get a new verb while in someone's inventory, add it to their panel.
	if(item_flags & PICKED_UP)
		var/mob/living/L = loc
		if(istype(L) && L.client)
			L.client.add_verbs(new_verbs)
	return ..(new_verbs)

/client/add_verb(new_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!ignore_byond_verbs)
		verbs += new_verbs
	add_verbs(new_verbs)
	return ..(new_verbs)

/client/remove_verb(old_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!ignore_byond_verbs)
		verbs -= old_verbs
	remove_verbs(old_verbs)
	return ..(old_verbs)

/mob/remove_verb(old_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(client)
		client.remove_verbs(old_verbs)
	return ..()

/mob/add_verb(new_verbs, ignore_byond_verbs = FALSE)
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(client)
		client.add_verbs(new_verbs)
	return ..()

/client/proc/remove_verbs(old_verbs)
	if(!islist(old_verbs))
		old_verbs = list(old_verbs)
	var/list/removed_verbs = list()
	for(var/pp in old_verbs)
		var/datum/stat_verb/stat_verb = pp
		if(!stat_verb)
			continue
		if(!istype(stat_verb))
			stat_verb = new(pp)
		//Remove from client executable
		remove_verb_from_cache(stat_verb)
		if(!islist(removed_verbs[stat_verb.category]))
			removed_verbs[stat_verb.category] = list()
		removed_verbs[stat_verb.category] += "[stat_verb.name]"
	tgui_panel.remove_verbs(removed_verbs)

/client/proc/add_verbs(new_verbs)
	if(!islist(new_verbs))
		new_verbs = list(new_verbs)
	var/list/added_verbs = list()
	for(var/pp in new_verbs)
		var/datum/stat_verb/stat_verb = pp
		if(!stat_verb)
			continue
		if(!istype(stat_verb))
			stat_verb = new(pp)
		if((!mob && stat_verb.invisibility) || (mob && stat_verb.invisibility > mob.see_invisible))
			continue
		//Add the verb to the clients accessible verb list
		add_verb_to_cache(stat_verb)
		if(!islist(added_verbs[stat_verb.category]))
			added_verbs[stat_verb.category] = list()
		//Add the verb to the TGUI panel
		added_verbs[stat_verb.category]["[stat_verb.name]"] = list(
			action = "verb",
			params = list("verb" = stat_verb.id),
			type = STAT_VERB,
		)
	tgui_panel.add_verbs(added_verbs)

/proc/cmp_verb_des(procpath/a,procpath/b)
	return sorttext(b.name, a.name)
