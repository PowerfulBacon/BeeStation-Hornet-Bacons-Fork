/// Book Style Anomaly
/// Basic interaction occurs when the book is read (interaction), however this may be altered depending on the effects given to it.
/obj/item/anomaly/book
	name = "book"
	desc = "Crack it open, inhale the musk of its pages, and learn something new."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "whacked", "educated")
	var/title = ""

/obj/item/anomaly/book/ComponentInitialize()
	. = ..()
	//Add the anomaly part
	//AddComponent(/datum/component/anomaly_base, "book")

/obj/item/anomaly/book/attack_self(mob/user)
	if(!user.can_read(src))
		return
	user.visible_message("<span class='notice'>[user] opens a book titled \"[title]\" and begins reading intently.</span>")
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "book_nerd", /datum/mood_event/book_nerd)
	SEND_SIGNAL(src, COMSIG_ANOMALY_DIRECT_INTERACTION, user)
