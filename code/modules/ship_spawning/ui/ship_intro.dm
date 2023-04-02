/atom/movable/screen/ship_intro
	alpha = 0
	maptext_width = 512
	maptext_height = 512
	maptext_x = -256
	var/did_move = 5
	var/static/list/displayed_clients = list()
	var/steps = 0
	var/full_text = "ERROR"
	var/mob/parent

/atom/movable/screen/ship_intro/Initialize(mapload, mob/parent)
	. = ..()
	if (parent.client in displayed_clients)
		return
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(client_moved))
	displayed_clients += parent.client

	full_text = "Welcome to BeeSHIP<s>ion</s>.\n\
\n\
You are %NAME%.\n\
The date is is [time2text(world.realtime, "DDD, Month DD")], [GLOB.year_integer+YEAR_OFFSET].\n\
You can gather resources by mining asteroids or lavaland.\n\
You can create weapons using a protolathe.\n\
Your base contains a variety of different services which you can use.\n\
Ship to ship combat may occur, you can use the weapons console to fire long ranged ship to ship\n\
weapons, or you can use the interdiction function of the flight computer in order to board the\n\
enemy ship.\n\
Good luck, have fun."
	START_PROCESSING(SSfastprocess, src)
	animate(src, alpha=255, time=30)
	src.parent = parent
	full_text = replacetext(full_text, "%NAME%", parent.name)

/atom/movable/screen/ship_intro/proc/client_moved()
	did_move --

/atom/movable/screen/ship_intro/Destroy()
	. = ..()
	parent = null

/atom/movable/screen/ship_intro/process(delta_time)
	steps += did_move <= 0 ? 30 : 5
	var/display_text = copytext(full_text, 1, steps)
	maptext = "<span class='maptext center big'>[display_text]</span>"
	maptext_y = 0
	for (var/i in 1 to length(display_text))
		if (display_text[i] == "\n")
			maptext_y -= 13
	if (steps > length(full_text))
		STOP_PROCESSING(SSfastprocess, src)
		animate(src, time=5 SECONDS)
		animate(alpha=0, time=5 SECONDS)
		return
