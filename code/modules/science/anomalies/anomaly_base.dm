/datum/anomaly_base
	/// The atom that represents the physical manifestation of this anomaly
	/// This is what we perform our effects based on
	var/atom/parent_atom
	/// Anomaly effect structure

/// Sets the anomaly datum to be registered
/datum/anomaly_base/proc/register_to_atom(atom/anomaly_parent)
	// Attach ourself to the target atom
	parent_atom = anomaly_parent
