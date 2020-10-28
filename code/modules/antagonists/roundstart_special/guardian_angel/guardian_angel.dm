////////////////////////////////
////// Special Role Datum///////
////////////////////////////////

/datum/special_role/guardian_angel
	probability = 30			//The probability of any spawning at all
	proportion = 1				//The prbability per person of rolling it (5% is (5 in 100) (1 in 20))
	max_amount = 1				//The maximum amount
	role_name = "Guardian Angel"
	restricted_jobs = list("Cyborg", "AI")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician")
	attached_antag_datum = /datum/antagonist/special/undercover

////////////////////////////////
//////  Antagonist Datum ///////
////////////////////////////////

/datum/antagonist/special/guardian_angel
	name = "Guardian Angel"
	roundend_category = "Special Roles"
	var/protection_target

/datum/antagonist/special/guardian_angel/proc/greet_target()
	to_chat(owner, "<span class='angelic big'>You are the Guardian Angel of [protection_target].</span>")
	to_chat(owner, "<span class='angelic'>Your employers sent you here, with a classified mission. You have no idea why, but you are tasked with protecting [protection_target].</span>")
	to_chat(owner, "<span class='angelic'>You are free to assist them in any way necessary, as long as you keep them alive.</span>")

/datum/antagonist/special/guardian_angel/admin_add(datum/mind/new_owner, mob/admin)
	. = ..()
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "You can only turn carbons into a guardian angel.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into a guardian angel.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")

/datum/antagonist/special/guardian_angel/forge_objectives()
	var/datum/objective/protect/P = new
	objectives += P
	log_objective(owner, P.explanation_text)
	owner.announce_objectives()

/datum/antagonist/special/guardian_angel/equip()
	if(!owner)
		return

	
