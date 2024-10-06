// Typically should be per-gas, but for simplicity it is just shared
#define DIFFUSION_COEFFICIENT 0.000018

/**
 * A bridge between multiple regions that allows for gas flow
 */
/datum/atmospheric_bridge
	/// Regions that this bridge connects together
	var/list/connecting_regions
	/// Turfs in this bridge
	var/list/turfs
	/// If true, the connected regions will become permanently linked once the
	/// delta has been resolved
	var/permanently_link_zones = FALSE

/datum/atmospheric_bridge/proc/process_bridge()
	// Calculate flow rate

