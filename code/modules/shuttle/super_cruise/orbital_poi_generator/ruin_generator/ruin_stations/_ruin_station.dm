
/**
 * Generate perlin noise in order to determine biome size
 */
/datum/map_generator/ruin_station
	/// List of biomes that we can spawn
	var/list/station_biomes

	// Variables nabbed from the ruin generator
	//-----------------
	// We need these in order to determine where the rooms on the station area,
	// so that we can decide:
	// A) What rooms we want to place
	// B) How to place the furnature in those rooms

	/// The z-level that the station was generated on
	var/z_level
	//Blocked turfs = Walls and floors
	var/list/blocked_turfs = list()				//Assoc list of blocked coords [x]_[y] = TRUE
	//Floor turfs = Open turfs only. Walls should be allowed to overlap.
	var/list/floor_turfs = list()				//Assoc list as above, except doesn't include walls.

/datum/map_generator/ruin_station/execute_run()
	message_admins("Executing ruin_station generation...")
	return ..()

/// Determine where the rooms and hallways are, as well as how many of them there are
/// We need to know how many there are to determine different things like:
/// - Power source (Larger stations might have a proper engineering department, smaller ones might just have a generator/battery room)
/// - Room stuff
/// As stations get bigger they get:
/// - More unnecessary rooms
/// - More refined roles (specific jobs and departments)
/// - More security access points
/// Smaller stations might have global access for all crews, while larger ones may have proper command
/// structures, well-defined access requirements and different departments.
/datum/map_generator/ruin_station/proc/determine_rooms()
	for (var/location in floor_turfs)

