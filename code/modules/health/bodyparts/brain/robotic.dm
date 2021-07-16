//===================
// Robotic Brain
//===================

/obj/item/nbodypart/brain/robotic
	name = "artifical processing unit"
	conciousness_name = "Processing"
	feels_pain = FALSE
	//Deciseconds of stun when hit by a heavy EMP.
	var/emp_vulnerability = 200

/obj/item/nbodypart/brain/robotic/emp_act(severity)
	. = ..()
	if(owner)
		to_chat(owner, "<span class='warning'>Electronic Pulse D[scramble_message_replace_chars("etected.", 70)]</span>")
		owner.Stun(emp_vulnerability / EMP_HEAVY)
