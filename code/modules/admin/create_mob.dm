
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = rustg_file_read('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/proc/randomize_human(mob/living/carbon/human/H)
	H.gender = pick(MALE, FEMALE)
	H.real_name = random_unique_name(H.gender)
	H.name = H.real_name
	H.underwear = random_underwear(H.gender)
	H.underwear_color = random_short_color()
	H.skin_tone = random_skin_tone()
	H.hair_style = random_hair_style(H.gender)
	H.facial_hair_style = random_facial_hair_style(H.gender)
	H.hair_color = random_short_color()
	H.facial_hair_color = H.hair_color
	H.eye_color = random_eye_color()
	H.dna.blood_type = random_blood_type()

	// Mutant randomizing, doesn't affect the mob appearance unless it's the specific mutant.
	H.dna.set_mcolor(random_short_color())
	H.dna.features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	H.dna.features["tail_lizard"] = pick(GLOB.tails_list_lizard)
	H.dna.features["snout"] = pick(GLOB.snouts_list)
	H.dna.features["horns"] = pick(GLOB.horns_list)
	H.dna.features["frills"] = pick(GLOB.frills_list)
	H.dna.features["spines"] = pick(GLOB.spines_list)
	H.dna.features["body_markings"] = pick(GLOB.body_markings_list)
	H.dna.features["moth_wings"] = pick(GLOB.moth_wings_roundstart_list)
	H.dna.features["moth_antennae"] = pick(GLOB.moth_antennae_roundstart_list)
	H.dna.features["moth_markings"] = pick(GLOB.moth_markings_roundstart_list)
	H.dna.features["apid_antenna"] = pick(GLOB.apid_antenna_list)
	H.dna.features["apid_stripes"] = pick(GLOB.apid_stripes_list)
	H.dna.features["apid_headstripes"] = pick(GLOB.apid_headstripes_list)
	H.dna.features["body_model"] = H.gender

	H.update_body()
	H.update_hair()

