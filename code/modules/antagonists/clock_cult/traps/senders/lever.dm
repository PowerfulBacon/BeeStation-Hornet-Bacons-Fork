/obj/item/wallframe/clocktrap/lever
	name = "switch"
	desc = "A small switch attatched to the wall."
	icon_state = "lever"
	result_path = /obj/structure/destructible/clockwork/trap/lever

/obj/structure/destructible/clockwork/trap/lever
	name = "switch"
	desc = "A small switch attatched to the wall."
	icon_state = "lever"
	unwrench_path = /obj/item/wallframe/clocktrap/lever
	component_datum = /datum/component/clockwork_trap/lever

/datum/component/clockwork_trap/lever
	sends_input = TRUE

/datum/component/clockwork_trap/lever/clicked(mob/user)
	trigger_connected()
	to_chat(user, "<span class='notice'>You activate the switch.</span>")
	playsound(user, 'sound/machines/click.ogg', 50)
	message_admins("Button clicked")
