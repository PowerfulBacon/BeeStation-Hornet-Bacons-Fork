/// Exists for record keeping
SUBSYSTEM_DEF(export)
	name = "Exports"
	flags = SS_NO_FIRE

	/// List of exports
	var/list/exports_list = list()

	/// List of types to their export
	var/list/type_to_export = list()

/datum/controller/subsystem/export/Initialize(start_timeofday)
	. = ..()
	// Setup the exports that we need
	setupExports()

/datum/controller/subsystem/export/proc/setupExports()
	for(var/subtype in subtypesof(/datum/export))
		var/datum/export/E = new subtype
		if(E.export_types?.len) // Exports without a type are invalid/base types
			exports_list += E

/datum/controller/subsystem/export/proc/register_export(datum/export/created_export)
	for (var/type in created_export.export_types)
		// Not covered
		if (is_type_in_typecache(type, created_export.exclude_types))
			continue
		type_to_export[type] = created_export
