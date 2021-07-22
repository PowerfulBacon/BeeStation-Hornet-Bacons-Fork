/mob/living/simple_animal/kalo //basically an IC garbage collector for blood tracks and snacks
	name = "Kalo"
	desc = "The Janitor's tiny pet lizard." //does the job better than the janitor itself
	body_type = /datum/body/kalo
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "lizard"
	do_footstep = TRUE
	can_be_held = TRUE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST, MOB_REPTILE)
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	see_in_dark     = 5
	speak_chance    = 1
	turns_per_move  = 3
	response_help   = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps"
	faction = list("Lizard")
	health = 15
	maxHealth = 15
	minbodytemp = 50
	maxbodytemp = 800
	mobchatspan = "centcom"

/mob/living/simple_animal/kalo/attack_hand(mob/living/carbon/human/M)
	..()
	if (M.a_intent == "help")
		if(prob(20))
			//yes lizards chirp I googled it it must be true
			INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, pick("chirps","squeaks"))
		turns_since_move = 0
	else
		if(prob(30))
			//no likey that
			INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, "hisses!")
