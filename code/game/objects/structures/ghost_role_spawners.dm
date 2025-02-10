//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders.

//Space Hotel Staff
/obj/effect/mob_spawn/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	mob_name = "hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	objectives = "Cater to visiting guests with your fellow staff. Do not leave your assigned hotel and always remember: The customer is always right!"
	death = FALSE
	roundstart = FALSE
	random = TRUE
	outfit = /datum/outfit/hotelstaff
	short_desc = "You are a staff member of a top-of-the-line space hotel!"
	flavour_text = "You are a staff member of a top-of-the-line space hotel! Cater to guests and make sure the manager doesn't fire you."
	important_info = "DON'T leave the hotel"
	assignedrole = "Hotel Staff"
	use_cooldown = TRUE
	banType = ROLE_HOTEL_STAFF

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/exile/hotel)

/obj/effect/mob_spawn/human/hotel_staff/security
	name = "hotel security sleeper"
	mob_name = "hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	short_desc = "You are a peacekeeper."
	flavour_text = "You have been assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff."
	important_info = "Do NOT leave the hotel, as that is grounds for contract termination."
	objectives = "Do not leave your assigned hotel. Try and keep the peace between staff and guests, non-lethal force heavily advised if possible."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full

/obj/effect/mob_spawn/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	..()

//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/human/oldsec
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are a security officer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. \
	As you open your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod. \
	Work as a team with your fellow survivors and do not abandon them."
	uniform = /obj/item/clothing/under/rank/security/officer
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/assembly/flash/handheld
	assignedrole = "Ancient Crew"
	use_cooldown = TRUE
	banType = ROLE_ANCIENT_CREW

/obj/effect/mob_spawn/human/oldsec/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldeng
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are an engineer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. \
	As you open your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod. \
	Work as a team with your fellow survivors and do not abandon them."
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	assignedrole = "Ancient Crew"
	use_cooldown = TRUE
	banType = ROLE_ANCIENT_CREW

/obj/effect/mob_spawn/human/oldeng/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldsci
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are a scientist working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = span_bigbold("You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. \
	As you open your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod. \
	Work as a team with your fellow survivors and do not abandon them.")
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack
	assignedrole = "Ancient Crew"
	use_cooldown = TRUE
	banType = ROLE_ANCIENT_CREW

/obj/effect/mob_spawn/human/oldsci/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate/space
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE
	show_flavour = FALSE //Flavour only exists for spawners menu
	short_desc = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot."
	assignedrole = ROLE_SPACE_PIRATE
	banType = ROLE_SPACE_PIRATE
	is_antagonist = TRUE
	var/rank = "Mate"

/obj/effect/mob_spawn/human/pirate/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name,generate_pirate_name())
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/human/pirate/proc/generate_pirate_name()
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/human/pirate/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/space/captain
	assignedrole = "Space Pirate Captain"

/obj/effect/mob_spawn/human/pirate/captain/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name,generate_pirate_name())
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate/captain)

/obj/effect/mob_spawn/human/pirate/gunner
	rank = "Gunner"

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."
	var/shell_type = /obj/effect/mob_spawn/human/golem
	var/has_owner = FALSE //if the resulting golem obeys someone
	w_class = WEIGHT_CLASS_BULKY

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/sheet/iron	                = /datum/species/golem,
		/obj/item/stack/sheet/mineral/copper        = /datum/species/golem/copper,
		/obj/item/stack/sheet/glass 	            = /datum/species/golem/glass,
		/obj/item/stack/sheet/plasteel 	            = /datum/species/golem/plasteel,
		/obj/item/stack/sheet/mineral/sandstone	    = /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/plasma	    = /datum/species/golem/plasma,
		/obj/item/stack/sheet/mineral/diamond	    = /datum/species/golem/diamond,
		/obj/item/stack/sheet/mineral/gold	        = /datum/species/golem/gold,
		/obj/item/stack/sheet/mineral/silver	    = /datum/species/golem/silver,
		/obj/item/stack/sheet/mineral/uranium	    = /datum/species/golem/uranium,
		/obj/item/stack/sheet/mineral/bananium	    = /datum/species/golem/bananium,
		/obj/item/stack/sheet/mineral/titanium	    = /datum/species/golem/titanium,
		/obj/item/stack/sheet/mineral/plastitanium	= /datum/species/golem/plastitanium,
		/obj/item/stack/sheet/mineral/abductor	    = /datum/species/golem/alloy,
		/obj/item/stack/sheet/wood	        		= /datum/species/golem/wood,
		/obj/item/stack/ore/bluespace_crystal	    = /datum/species/golem/bluespace,
		/obj/item/stack/sheet/runed_metal	        = /datum/species/golem/runic,
		/obj/item/stack/medical/gauze	            = /datum/species/golem/cloth,
		/obj/item/stack/sheet/cotton/cloth			= /datum/species/golem/cloth,
		/obj/item/stack/sheet/mineral/adamantine	= /datum/species/golem/adamantine,
		/obj/item/stack/sheet/plastic	            = /datum/species/golem/plastic,
		/obj/item/stack/sheet/brass					= /datum/species/golem/clockwork,
		/obj/item/stack/sheet/bronze				= /datum/species/golem/bronze,
		/obj/item/stack/sheet/cardboard				= /datum/species/golem/cardboard,
		/obj/item/stack/sheet/leather				= /datum/species/golem/leather,
		/obj/item/stack/sheet/bone					= /datum/species/golem/bone,
		/obj/item/stack/sheet/cotton/cloth/durathread			= /datum/species/golem/durathread,
		/obj/item/stack/sheet/cotton/durathread		= /datum/species/golem/durathread,
		/obj/item/stack/sheet/snow					= /datum/species/golem/snow,
		/obj/item/stack/sheet/capitalisium			= /datum/species/golem/capitalist,
		/obj/item/stack/sheet/stalinium				= /datum/species/golem/soviet,
		)

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/O = I
		var/species = golem_shell_species_types[O.merge_type]
		if(species)
			if(O.use(10))
				to_chat(user, "You finish up the golem shell with ten sheets of [O].")
				new shell_type(get_turf(src), species, user)
				qdel(src)
			else
				to_chat(user, "You need at least ten sheets to finish a golem.")
		else
			to_chat(user, "You can't build a golem out of this kind of material.")

//made with xenobiology, the golem obeys its creator
/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/human/golem/servant

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	mob_name = "a servant golem"
	use_cooldown = FALSE
