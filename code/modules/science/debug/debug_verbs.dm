
/client/proc/reload_anomalies()
	set name = "Reload Anomalies"
	set category = "Debug - Anomaly"

	if (!check_rights(R_DEBUG))
		return

	SSanomaly_science.load_anomalies()
	debug_variables(SSanomaly_science.loaded_anomalies)

/client/proc/create_anomaly()
	set name = "Create Anomaly"
	set desc = "Spawns a particular anomaly type at the current location"
	set category = "Debug - Anomaly"

	if (!check_rights(R_DEBUG))
		return

	var/selected = input(src, "Select the anomaly type you wish to spawn", "Select anomaly type", null) as null|anything in SSanomaly_science.loaded_anomalies
	if (!selected)
		return
	var/datum/parsed_anomaly_data/located_anomaly = SSanomaly_science.loaded_anomalies[selected]
	var/spawned_type = /obj/item/coin/antagtoken
	if (located_anomaly.data["atom_type"])
		spawned_type = text2path(located_anomaly.data["atom_type"])
	var/atom/created = new spawned_type(get_turf(mob))
	created.AddComponent(/datum/component/anomaly_base, selected)
