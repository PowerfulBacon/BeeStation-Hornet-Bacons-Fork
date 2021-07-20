
/obj/item/nbodypart/organ/brain/simple_animal
	var/list/speak = list()
	var/list/speak_emote = list()//	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

/obj/item/nbodypart/organ/brain/simple_animal/handle_automated_speech(mob/living/L, var/override)
	if(speak_chance)
		if(prob(speak_chance) || override)
			if(speak?.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						L.say(pick(speak), forced = "poly")
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							L.emote("me [pick(emote_see)]", 1)
						else
							L.emote("me [pick(emote_hear)]", 2)
				else
					L.say(pick(speak), forced = "poly")
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					L.emote("me", 1, pick(emote_see))
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					L.emote("me", 2, pick(emote_hear))
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						L.emote("me", 1, pick(emote_see))
					else
						L.emote("me", 2, pick(emote_hear))
