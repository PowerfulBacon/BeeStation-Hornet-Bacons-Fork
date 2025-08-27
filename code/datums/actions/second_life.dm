#define FROM_SUMMONING_CANDLE "summoning_candle"

/datum/action/second_life
	name = "Second Life"
	desc = "Return to a summoning vessel, and appear in the body of your alternate."
	// TODO: Change me!
	icon_icon = 'icons/hud/actions/actions_xeno.dmi'
	button_icon_state = "smallqueen"
	background_icon_state = "bg_alien"
	// List of candles that we own
	var/list/obj/item/candle/summoning/candles = list()

/datum/action/second_life/Grant(mob/grant_to)
	. = ..()
	// TODO: Move this to somewhere more sensible, where we the client is passed into new or something
	if (!grant_to.client)
		CRASH("Second life granted to mob with no client")
	// Temp: Create some new characters
	for (var/i in 1 to 2)
		var/mob/created = add_new_character(grant_to.client, grant_to.mind)
		enter_candle(created)

/datum/action/second_life/on_activate(mob/user, atom/target, trigger_flags)
	// Give a wheel showing the options
	// When we click an option, absorb our current mob into a candle
	// ... and summon at the new candle
	// DEBUG: Summon at the first candle we find
	summon_at_candle(user, pick(candles))

/// Call this to add a new character that can be spawned
/datum/action/second_life/proc/add_new_character(client/owner_client, datum/mind/owner)
	// Pick a random job to inhabit, from a list of spawnable ones
	// Could be expanded to check for job capacity
	var/datum/job/selected_job_type = pick(\
		/datum/job/security_officer,\
		/datum/job/cargo_technician,\
		/datum/job/medical_doctor,\
		/datum/job/scientist,\
		/datum/job/assistant,\
		/datum/job/station_engineer\
	)
	var/datum/job/job = SSjob.GetJob(selected_job_type::title)
	// Create the player
	var/mob/living/carbon/human/created_human = new()
	// Set the rank, and equip the loadout
	created_human.job = job.title
	job.equip(created_human, FALSE, FALSE, TRUE, null, owner_client)
	if(created_human.mind?.account_id)
		created_human.add_memory("Your account ID is [created_human.mind.account_id].")
	job.after_spawn(created_human, owner_client.mob, TRUE, owner_client) // note: this happens before the mob has a key! M will always have a client, living_mob might not.
	// Enter into the manifest
	GLOB.manifest.inject(created_human)
	return created_human

/datum/action/second_life/proc/enter_candle(mob/living/carbon/human/target)
	// Be absorbed into the candle
	var/obj/item/candle/summoning/candle = new(target.loc)
	candle.assume(target)
	candles += candle
	RegisterSignal(candle, COMSIG_QDELETING, PROC_REF(on_candle_deleted))

/datum/action/second_life/proc/on_candle_deleted(obj/item/candle/summoning/source)
	SIGNAL_HANDLER
	candles -= source

/datum/action/second_life/proc/summon_at_candle(mob/living/carbon/human/current, obj/item/candle/summoning/target)
	var/mob/living/carbon/human/retrieved = target.retrieve()
	current.mind.transfer_to(retrieved, TRUE)
	enter_candle(current)

/// Summoning candle that holds the mob
/obj/item/candle/summoning
	var/mob/living/carbon/human/stored_mob

/obj/item/candle/summoning/Destroy()
	. = ..()
	// Delete the mob inside of us and clean up the reference
	if (stored_mob != null)
		qdel(stored_mob)
		stored_mob = null

/obj/item/candle/summoning/proc/assume(mob/living/carbon/human/target)
	// Completely disables the mob from doing anything
	target.notransform = TRUE
	ADD_TRAIT(target, TRAIT_GODMODE, FROM_SUMMONING_CANDLE)
	target.forceMove(src)
	stored_mob = target
	RegisterSignal(stored_mob, COMSIG_QDELETING, PROC_REF(stored_mob_destroyed))

/obj/item/candle/summoning/proc/retrieve()
	// Exit the candle
	stored_mob.notransform = FALSE
	REMOVE_TRAIT(stored_mob, TRAIT_GODMODE, FROM_SUMMONING_CANDLE)
	stored_mob.forceMove(loc)
	// Delete the candle
	UnregisterSignal(stored_mob, COMSIG_QDELETING)
	stored_mob = null
	qdel(src)
	// Return the retrieved mob
	return stored_mob

/obj/item/candle/summoning/proc/stored_mob_destroyed()
	SIGNAL_HANDLER
	// Cleanup references
	stored_mob = null
	qdel(src)

/obj/item/candle/summoning/light(show_message)
	. = ..()
	// TODO: Make it so that this forces the owner to be summoned
