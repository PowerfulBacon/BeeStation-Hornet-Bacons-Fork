
/obj/machinery/rnd/material_sampler
	name = "material sampler"
	desc = "A high-tech device that performs a spectrum analysis to reveal the compounds that make up an unidentified material."
	//Track these datums since they never get deleted
	var/list/datum/material_sample/samples = list()

/obj/machinery/rnd/material_sampler/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	//Check if we can place this item into the analyser
	if(istype(I, /obj/item/alienartifact))
		if(length(samples))
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		var/obj/item/alienartifact/artifact = I
		samples += artifact.samples

/obj/machinery/rnd/material_sampler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpectrumAnalysis")
		ui.open()
	ui.set_autoupdate(FALSE)

/obj/machinery/rnd/material_sampler/ui_data(mob/user)
	var/list/data = list()

	data["sample_list"] = list()

	for(var/datum/material_sample/sample in samples)
		data["sample_list"] += list(sample.spectrum_data)

	return data

/obj/machinery/rnd/material_sampler/ui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		// Debug: Generate a random sample
		if("random")
			samples = list()
			samples += new /datum/material_sample

