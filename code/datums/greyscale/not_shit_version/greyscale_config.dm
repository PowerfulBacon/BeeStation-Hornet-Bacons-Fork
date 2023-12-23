/datum/greyscale_sprite
	VAR_PRIVATE/icon/used_icon
	VAR_PRIVATE/list/layers = list()
	// Array where indexing represents the colour and value is a list of overlay IDs
	VAR_PRIVATE/list/colour_layers = list()
	/// This is a reused image that is used when applied to overlays only.
	/// This abuses the property of overlays that they will not update once applied to an object,
	/// meaning that we can change the appearance of this image and then apply it to an atom as an
	/// overlay.
	VAR_PRIVATE/image/reused_image

/// Call procs that generate the configuration for this
/// greyscale icon.
/// Procs:
/// add_layer: Add a layer with a set colour ID
/// add_fixed_layer: Add a layer that cannot change colour
/datum/greyscale_sprite/proc/generate()
	return

/// Setup metadata attached with this greyscale configuration
/datum/greyscale_sprite/proc/set_icon(icon_file)
	used_icon = icon_file

/// Add a layer with a specified colour layer ID. Layer is incrementally determined
/datum/greyscale_sprite/proc/add_layer(colour_id, icon_state, blend_mode = BLEND_DEFAULT)

/// Add a fixed layer that cannot change colour. Layer is incrementally determined
/datum/greyscale_sprite/proc/add_fixed_layer(icon_state, blend_mode = BLEND_DEFAULT)

/// Add a fixed layer that cannot change colour. Layer is incrementally determined
/datum/greyscale_sprite/proc/add_fixed_emissive(icon_state)

/datum/greyscale_sprite/proc/apply(atom/target, list/colours)
	var/image/i = reused_image
	// Build the image if necessary
	if (!i)
		// Create a base blank image for relaying the colours and alpha
		i = image(layer = FLOAT_LAYER)
		// Create the layers
		var/index = 1
		for (var/layer in layers)
			var/image/add_overlay = image(used_icon, null, layer, FLOAT_LAYER - index * 0.0001)
			// Check if we are on colour channel 1, if not then reset colour
			if (length(colour_layers) == 0 || !(index in colour_layers[1]))
				add_overlay.appearance_flags = RESET_COLOR
			// Add the overlay
			i.overlays += add_overlay
			index ++
	// Set the constant colour
	if (length(colours) == 0)
		return
	i.color = colours[1]
	// Set the dynamic colours
	for (var/colour_id in 2 to length(colour_layers))
		for (var/overlay_id in colour_layers[colour_id])
			var/image/overlay = i.overlays[overlay_id]
			overlay.color = colours[colour_id]
			// Reapply the overlay in order to update the colour.
			i.overlays[overlay_id] = overlay
	target.appearance = i.appearance
