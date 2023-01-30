/datum/cargo_hold
	/// The sellable list
	var/list/sellable_list = list()
	/// The compiled UI data that will be used
	var/list/compiled_ui_data = list()

/// Add a sellable atom and compile its UI data
/datum/cargo_hold/proc/add_atom(atom/movable/sellable)
	sellable_list += sellable
	var/calculated_price = 0
	//Calculate the initial cost, register signals to determine changes
	var/list/full_contents = list()
	for (var/atom/movable/content in sellable.GetAllContents())
		full_contents += content.name
		var/datum/export/attached_export = SSexport.type_to_export[content.type]
		if (!attached_export)
			continue
		calculated_price += attached_export.get_cost(content)
		// Register the signals required to keep track of changes in cargo
		RegisterSignal(content, COMSIG_ATOM_ENTERED, .proc/sellable_contents_entered)
		RegisterSignal(content, COMSIG_MOVABLE_MOVED, .proc/sellable_item_moved)
		RegisterSignal(content, COMSIG_PARENT_QDELETING, .proc/sellable_item_deleted)
	//Create the compiled UI data list
	compiled_ui_data[REF(sellable)] = list(
		"name" = sellable.name,
		"value" = calculated_price,
		"full_contents" = full_contents
	)
	message_admins(json_encode(compiled_ui_data))

/datum/cargo_hold/proc/sellable_item_deleted(atom/movable/source)
	SIGNAL_HANDLER
	remove_sellable_item(source, source.loc)

/datum/cargo_hold/proc/sellable_item_moved(atom/movable/source, atom/oldLoc, dir)
	SIGNAL_HANDLER
	remove_sellable_item(source, oldLoc)

/datum/cargo_hold/proc/remove_sellable_item(atom/movable/source, atom/loc, trace_up = TRUE)
	// Unreigster registered signals
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	// Identify the parent ref
	var/atom/current = loc
	if (trace_up)
		while (current.loc && !isturf(current.loc))
			current = current.loc
	// Remove everything in the contents of this item
	for (var/atom/movable/content in source.contents)
		remove_sellable_item(content, current)
	// Update self
	var/list/sellable = compiled_ui_data[REF(current)]
	if (isnull(sellable))
		return
	// Update the sold contents list
	sellable["full_contents"] -= source.name
	// Update the value
	var/datum/export/attached_export = SSexport.type_to_export[source.type]
	if (!attached_export)
		return
	sellable["value"] -= attached_export.get_cost(source)

/// Something being sold had another item enter its contents, update the value
/datum/cargo_hold/proc/sellable_contents_entered(atom/movable/item, atom/movable/entered)
	SIGNAL_HANDLER
	//Identify the parent ref
	var/atom/current = item
	while (!isturf(current.loc))
		current = current.loc
	var/list/sellable = compiled_ui_data[REF(current)]
	if (isnull(sellable))
		return
	// Update the sold contents list
	compiled_ui_data[REF(sellable)]["full_contents"] += item.name
	// Update the value
	var/datum/export/attached_export = SSexport.type_to_export[item.type]
	if (!attached_export)
		return
	compiled_ui_data[REF(sellable)]["value"] += attached_export.get_cost(item)

/// Remove a sellable atom from the list of sellable atoms
/datum/cargo_hold/proc/remove_atom(atom/movable/sellable)
	sellable_list -= sellable
	remove_sellable_item(sellable, sellable, FALSE)
	compiled_ui_data.Remove(REF(sellable))

/datum/cargo_hold/proc/get_ui_data()
	return compiled_ui_data
