
/area/ruin_mapping
	area_flags = HIDDEN_AREA
	icon = 'icons/effects/ruin_generator_mapping.dmi'

/area/ruin_mapping/Initialize(mapload)
	. = ..()
	//Record this so we can work with them
	SSruin_generator.store_z_area(z, src)

/area/ruin_mapping/room
	icon_state = "room"

/area/ruin_mapping/room/one
	icon_state = "room_1"

/area/ruin_mapping/room/two
	icon_state = "room_2"

/area/ruin_mapping/room/three
	icon_state = "room_3"

/area/ruin_mapping/room/four
	icon_state = "room_4"

/area/ruin_mapping/room/secure
	icon_state = "room_high_sec"

/area/ruin_mapping/hallway
	icon_state = "hallway"

/area/ruin_mapping/nullroom
	icon_state = "null_room"
