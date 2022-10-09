/datum/emote/slime
	mob_type_allowed_typecache = /mob/living/simple_animal/slime
	mob_type_blacklist_typecache = list()

/datum/emote/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "bounces in place."

/datum/emote/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "jiggles!"

/datum/emote/slime/light
	key = "light"
	key_third_person = "lights"
	message = "lights up for a bit, then stops."

/datum/emote/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "vibrates!"

/datum/emote/slime/mood
	key = "moodnone"
	var/mood = null

/datum/emote/slime/mood/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/mob/living/simple_animal/slime/S = user
	S.mood = mood
	S.regenerate_icons()

/datum/emote/slime/mood/sneaky
	key = "moodsneaky"
	mood = "mischievous"
	verb_name = "Expression: Sneaky"

/datum/emote/slime/mood/smile
	key = "moodsmile"
	mood = ":3"
	verb_name = "Expression: Smile"

/datum/emote/slime/mood/cat
	key = "moodcat"
	mood = ":33"
	verb_name = "Expression: Cat"

/datum/emote/slime/mood/pout
	key = "moodpout"
	mood = "pout"
	verb_name = "Expression: Pout"

/datum/emote/slime/mood/sad
	key = "moodsad"
	mood = "sad"
	verb_name = "Expression: Sad"

/datum/emote/slime/mood/angry
	key = "moodangry"
	mood = "angry"
	verb_name = "Expression: Angry"
