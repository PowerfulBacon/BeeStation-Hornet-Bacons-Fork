/datum/component/point_of_interest
	var/datum/orbital_object/point_of_interest/orbital_object

/datum/component/point_of_interest/Initialize(name, size = 1)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom = parent
	orbital_object = new(name, atom.x, atom.y, size)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))
	if (!isturf(atom.loc))
		orbital_object.stealth = TRUE

/datum/component/point_of_interest/Destroy(force, silent)
	qdel(orbital_object)
	return ..()

/datum/component/point_of_interest/proc/parent_moved(atom/source, atom/oldLoc)
	SIGNAL_HANDLER
	if (!isturf(source.loc))
		orbital_object.stealth = TRUE
	else
		var/turf/location = source.loc
		orbital_object.stealth = FALSE
		orbital_object.set_position(location.x, location.y)
