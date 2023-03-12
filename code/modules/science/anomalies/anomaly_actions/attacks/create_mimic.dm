/**
 * Create Mimic
 * Converts the target into a mimic
 */

/datum/anomaly_action/create_mimic/trigger_action(list/atom/trigger_atoms, list/extra_data)
	if (!length(trigger_atoms))
		return fail()
	var/atom/target = trigger_atoms[1]
	target.animate_atom_living()
	return success()
