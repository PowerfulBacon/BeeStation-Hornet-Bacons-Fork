
#define STATUS_MESSAGE_WIDTH 7 * 32

/mob/var/list/status_messages

/atom/proc/show_danger_status_message(message, time, colour = "#eea4a4", important = TRUE)
	to_chat(src, "<span class='danger'>[message]</span>")

/mob/show_danger_status_message(message, time, colour = "#eea4a4", important = TRUE)
	to_chat(src, "<span class='danger'>[message]</span>")
	if (!client)
		return
	var/atom/movable/screen/status_message/status_message = new()
	status_message.status_text = message
	status_message.message_colour = colour
	status_message.generate_image(client)
	LAZYADD(status_messages, status_message)

/atom/proc/show_action_status_message(message, time, colour = "#f4f4f4", important = TRUE)

/atom/movable/screen/status_message
	screen_loc = "CENTER,SOUTH+5"
	var/message_colour
	var/status_text

/atom/movable/screen/status_message/proc/generate_image(client/owner)
	set waitfor = FALSE
	alpha = 0
	maptext_width = STATUS_MESSAGE_WIDTH
	maptext_height = WXH_TO_HEIGHT(owner?.MeasureText(status_text, null, STATUS_MESSAGE_WIDTH))
	maptext_x = (STATUS_MESSAGE_WIDTH - bound_width) * -0.5
	maptext = MAPTEXT("<span style='text-align: center; -dm-text-outline: 1px #0005; color: [message_colour]'>[status_text]</span>")
	animate(src, time=0.3 SECONDS, alpha=255)
	status_message.show_to(src)

/atom/movable/screen/status_message/proc/show_to(mob/user)
	user.client?.screen += src
