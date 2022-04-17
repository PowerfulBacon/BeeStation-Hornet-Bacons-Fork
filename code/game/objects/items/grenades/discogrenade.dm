/obj/item/grenade/discogrenade
	//Set the name of the item
	name = "Ethereal disco grenade"
	//Set the examine description of the item
	desc = "An unethical grenade that will cause anyone nearby to be forced into a dancing frenzy! \
		Ethereals may not like this, and may even be slightly offended by this act."
	//Set the icon of the item (What it looks like on the ground)
	icon_state = "disco"
	//Set the item state of the item (What it looks like in a hand)
	item_state = "flashbang"
	//The range at which we force people to dance
	var/dance_range = 4
	//The time at which we stun for
	var/stun_time = 5 SECONDS

/obj/item/grenade/discogrenade/prime(mob/living/lanced_by)
	. = ..()

	//If our parent call returned false, we are a dud!
	if(!.)
		return

	//Store a colour in a local variable
	//Note that color is a built in byond variable, so using the british spelling for
	//the local variable colour is a good idea.
	var/colour = "#[random_color()]"

	//Execute the lighting flash, with a range of 3, power of 6, color of the variable colour and a time of 0.5 SECONDS.
	flash_lighting_fx(3, 3, colour, 0.5 SECONDS)

	//Find all people nearby that can see src (src is ourselves)
	for(var/mob/living/dancer in viewers(dance_range, src))
		make_dance(dancer)

	//Delete the object
	qdel(src)

/obj/item/grenade/discogrenade/proc/make_dance(mob/living/dancer)
	//Early return is the dancer has a mindshield
	if(HAS_TRAIT(dancer, TRAIT_MINDSHIELD))
		//Send a message to the user to tell them they are protected
		to_chat(dancer, "<span class='warning>You are protected from the urge to dance!</span>")
		//Return: This will immediately stop execution of the current proc.
		//Early returns are prefered to using blocks of if and else as it leads to cleaner code.
		return
	//Check if the user has the social anxiety quirk
	if(dancer.has_quirk(/datum/quirk/social_anxiety))
		//Send a message to the person with social anxiety
		to_chat(dancer, "<span class='userdanger'>You really don't like this...</span>")
		//Paralyze them for 10 seconds (Forces them to fall over)
		dancer.Paralyze(10 SECONDS)
		//Drop all their items
		dancer.drop_all_held_items()
		//Return from the proc and don't continue execution
		return
	//Trigger a random emote
	switch(rand(1, 3))
		if(1)
			//Trigger the dance emote. (Note: Emotes are predefined)
			dancer.emote("dance")
		if(2)
			//Trigger the spin emote. (Note: Emotes are predefined)
			dancer.emote("spin")
		if(3)
			//Trigger the flip emote. (Note: Emotes are predefined)
			dancer.emote("flip")
	//Stun the dancer for the stun_time, so that they cannot move
	dancer.Stun(stun_time)
