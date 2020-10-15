GLOBAL_LIST_INIT(emf_readers)

/atom/proc/register_emf_reader()
	GLOB.emf_readers |= src

/atom/proc/unregister_emf_reader()
	GLOB.emf_readers -= src

/proc/create_emf(source_power = 1, range = 3, time = 100)
	set waitfor = FALSE
	var/datum/emf_source/source = new(source_power, range, time)
	for(var/emf_reader in GLOB.emf_readers)
		SEND_SIGNAL(emf_reader, COMSIG_ATOM_EMF_READ, source)

/datum/emf_source
	power = 0
	range = 0

/datum/emf_source/New(_power, _range, time)
	. = ..()
	power = _power
	range = _range
	addtimer(CALLBACK(src, ./proc/end_source), time)
	GLOB.emf_sources += src

/datum/emf_source/proc/end_source()
	GLOB.emf_sources -= src
