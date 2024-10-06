
/// If true, this object will be considered atmos dense and will divide regions
/// Should be avoided on movable things if possible.
/// When atmos density is true, flow behaves in the following way:
/// - set_density(FALSE): Temporarilly creates a bridge between adjacent atmos regions, causing repressurisation to occur.
/// - set_atmos_density(FALSE): Permanently removed the atom's ability to block atmos, restoring the connectivity of zones
/// If a turf is set to atmos dense, then it must always have the flow directions set
/atom/var/atmos_density = ATMOS_PASS

/// Directions that atmos is allowed to flow on this turf.
/// Modified by atoms moving in and out of it.
/// Set on init for tuefs that have atmos densities
/turf/var/atmos_flow_directions = ALL
