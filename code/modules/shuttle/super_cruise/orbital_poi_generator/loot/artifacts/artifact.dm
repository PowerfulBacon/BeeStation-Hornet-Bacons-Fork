/obj/item/alienartifact
	var/list/datum/material_sample/samples

/// TODO
/obj/item/alienartifact/proc/generate_material_samples()
	samples = list()
	//Pick some samples
	for(var/i in rand(1, CEILING(length(SSexploration.possible_objectives) * 0.3, 1)) to rand(CEILING(length(SSexploration.possible_objectives) * 0.3, 1), CEILING(length(SSexploration.possible_objectives) * 0.6, 1)))
		//Pick a sample
		var/datum/material_sample/chosen = pick(SSexploration.possible_objectives)
		//Check for contradictions
		var/valid = TRUE
		for(var/datum/material_sample/sample in samples)
			if(chosen.max_temperature < sample.min_temperature || chosen.min_temperature > sample.max_temperature || chosen.max_pressure < sample.min_pressure ||chosen.min_pressure > sample.max_pressure)
				valid = FALSE
				break
		if(!valid)
			continue
		//Add it if it doesn't exist already
		samples |= chosen
