/datum/antagonist/special/activist
	name = "Activist"
	roundend_category = "Special Roles"
	probability = 35			//The probability of any spawning at all
	proportion = 0.04			//The prbability per person of rolling it
	max_amount = 3				//The maximum amount
	role_name = "Activist"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician", "Clown")

/datum/antagonist/special/activist/on_gain()
	forge_objectives(owner.mind)
	. = ..()

/datum/antagonist/special/activist/greet()
	to_chat(owner, "<span class='userdanger'>You are an activist!</span>")
	to_chat(owner, "<b>Nanotrasen's recent experiments involving [pick("are ridiculous!", "are unethical!", "are outrageous!", "are kind of bad for the space environment.")].</b>")
	to_chat(owner, "<b>You have a strong feeling that you should non-violently defect, it is the right thing to do.</b>")
	to_chat(owner, "<span class='boldannounce'>Killing people would be against your cause, avoid it at all costs!</span>")

/datum/antagonist/special/undercover/admin_add(datum/mind/new_owner, mob/admin)
	. = ..()
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "You can only turn carbons into an ex-security agent.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into an ex-security agent.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")

/datum/antagonist/special/undercover/forge_objectives()
	objectives += chosen_objective
	owner.announce_objectives()

/datum/antagonist/special/undercover/equip()
	if(!owner)
		return

	var/mob/living/carbon/H = owner.current
	if(!ishuman(H) && !ismonkey(H))
		return

////////////////////////////////
//////     Objectives    ///////
////////////////////////////////
