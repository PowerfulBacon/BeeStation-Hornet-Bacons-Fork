/datum/material_sample
	var/sample_id
	/// The spectrum analysis
	/// Assoc list:
	///		Key: Wavelength
	///		Value: Intensity
	var/list/spectrum_data
	/// The minimum temperature at which this material can be sampled
	var/min_temperature = -1
	var/min_temperature_dangerous = FALSE
	/// The maximum temperature at which this material can be sampled
	var/max_temperature = -1
	var/max_temperature_dangerous = FALSE
	/// Minimum pressure to sample this material
	var/min_pressure = -1
	var/min_pressure_dangerous = FALSE
	/// Maximum pressure to sample this material
	var/max_pressure = -1
	var/max_pressure_dangerous = FALSE

/datum/material_sample/New()
	. = ..()
	generate_spectrum()

/datum/material_sample/proc/generate_spectrum()
	for(var/i in 1 to rand(3, 6))
		//Choose a wavelength
		var/chosen_wavelength = rand(0, 40)
		if(spectrum_data[chosen_wavelength])
			continue
		//Choose a spectrum intensity
		var/intensity
		if(i == 1)
			intensity = 20
		else
			intensity = rand(1, 20 / i)
		//Set the spectrum results
		spectrum_data[chosen_wavelength] = intensity

/datum/material_sample/proc/generate_sample_report()
	//Insert generic text
	. = "\
		<center>\
		<h1>Material Sample Report</h1>\
		</center><hr />\
		<p><strong>Sample ID:</strong> #[sample_id]</p>\
		<p><strong>Sample Source:</strong> Exoplanet UA-456</p>\
		<p><strong>Sample Rarity:</strong> Rare</p>\
		<hr />\
		<p>The following report is a Nanotrasen safety report regarding the sample classified #[sample_id]. The information in this report may be incomplete and while accurate, may not be fully inclusive (Ranges are overly restrictive to ensure safety of Nanotrasen employees during testing).</p>\
		<p>Extreme caution should be taken when handling unknown and potentially dangerous material samples, protective gear should be worn at all times including, but not limited to:</p>\
		<ul>\
		<li>Protective eye-wear.</li>\
		<li>Protective clothing (No skin should be exposed).</li>\
		<li>Filtered breathing equipment.</li>\
		</ul>\
		<p>You should inform your supervisor and/or another member of staff before performing any experiments, and ensure at least 1 other trained person observes the test to ensure safety protocols are followed at all times. Should there be a potential for danger, the test should be called off immediately and an incident report submitted to an authorised supervisor.</p>\
		<p>Below lists the currently understood properties of the attached sample.</p>"
	//If the sample has no stats
	if(min_temperature == -1 && max_temperature != -1 && min_pressure != -1 && max_pressure != -1)
		. += "<p>Sample #[sample_id] has no known requirements for experimentation and responded to all attempts to sample it no matter the environmental status.</p>"
	//Insert specifics
	if(min_temperature != 1)
		if(min_temperature_dangerous)
			. += "<p>Sample #[sample_id] should not be exposed to temperatures below [min_temperature]K during experimentation.</p>"
		else
			. += "<p>Sample #[sample_id] does not respond to temperatures below [min_temperature]K.</p>"
	if(max_temperature != 1)
		if(max_temperature_dangerous)
			. += "<p>Sample #[sample_id] should not be exposed to temperatures exceeding [max_temperature]K during experimentation.</p>"
		else
			. += "<p>Sample #[sample_id] does not respond to temperatures exceeding [max_temperature]K.</p>"
