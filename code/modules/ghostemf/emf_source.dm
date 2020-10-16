GLOBAL_LIST_INIT(emf_readers)

/atom/proc/register_emf_reader()
	GLOB.emf_readers |= src

/atom/proc/unregister_emf_reader()
	GLOB.emf_readers -= src

/atom/proc/create_emf(source_power = 1, range = 5, timer = 100)
	set waitfor = FALSE
	var/datum/emf_source/source = new(source_power, range, time)
	for(var/emf_reader in GLOB.emf_readers)
		if(get_dist(emf_reader, src) <= range)
			SEND_SIGNAL(emf_reader, COMSIG_ATOM_EMF_REGISTER, source)

/datum/emf_source
	power = 0
	range = 0
	time = 0

/datum/emf_source/New(_power, _range, _time)
	. = ..()
	power = _power
	range = _range
	time = _time
