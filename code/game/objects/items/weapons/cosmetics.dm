/obj/item/weapon/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	flags = FPRINT | TABLEPASS
	w_class = 1.0
	var/colour = "red"
	var/open = 0


/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"


/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/New()
	colour = pick("red","purple","jade","black")
	name = "[colour] lipstick"


/obj/item/weapon/lipstick/attack_self(mob/user as mob)
	user << "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>"
	open = !open
	if(open)
		icon_state = "[initial(icon_state)]_[colour]"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/lipstick/attack(mob/M as mob, mob/user as mob)
	if(!open)	return

	if(!istype(M, /mob))	return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			user << "<span class='notice'>You need to wipe off the old lipstick first!</span>"
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user, 20) && do_after(H, 20, 5, 0))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = colour
				H.update_body()
	else
		user << "<span class='notice'>Where are the lips on that?</span>"

//you can wipe off lipstick with paper!
/obj/item/weapon/paper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_sel.selecting == "mouth")
		if(!istype(M, /mob))	return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				user << "<span class='notice'>You wipe off the lipstick with [src].</span>"
				H.lip_style = null
				H.update_body()
			else
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s lipstick.</span>")
				if(do_after(user, 10) && do_after(H, 10, 5, 0))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
					H.lip_style = null
					H.update_body()
	else
		..()

/obj/item/weapon/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 1.0


/obj/item/weapon/razor/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(user.zone_sel.selecting == "mouth")
			if(H.f_style == "Shaved")
				user << "<span class='notice'>Already clean-shaven.</span>"
				return

			if(H.wear_mask)
				user << "<span class='warning'>The mask blocks you from shaving it.</span>"
				return

			if(H == user) //shaving yourself
				user.visible_message("<span class='notice'>[user] starts to shave their facial hair with \the [src].</span>", \
									 "<span class='notice'>You take a moment shave your facial hair with \the [src].</span>")
				if(do_after(user, 30))
					user.visible_message("<span class='notice'>[user] shaves his facial hair clean with the [src].</span>", \
										 "<span class='notice'>You finish shaving with the [src]. Fast and clean!</span>")
					H.f_style = "Shaved"
					H.update_hair()
					playsound(src.loc, 'sound/items/Welder2.ogg', 20, 1)
			else
				var/turf/user_loc = user.loc
				var/turf/H_loc = H.loc
				user.visible_message("<span class='danger'>[user] tries to shave [H]'s facial hair with \the [src].</span>", \
									 "<span class='warning'>You start shaving [H]'s facial hair.</span>")
				if(do_after(user, 50))
					if(user_loc == user.loc && H_loc == H.loc)
						user.visible_message("<span class='danger'>[user] shaves off [H]'s facial hair with \the [src].</span>", \
											 "<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						H.f_style = "Shaved"
						H.update_hair()
						playsound(src.loc, 'sound/items/Welder2.ogg', 20, 1)

		if(user.zone_sel.selecting == "head")
			if(H.h_style == "Bald" || H.h_style == "Balding Hair" || H.h_style == "Skinhead")
				user << "<span class='notice'>There is not enough hair left to shave...</span>"
				return

			if(H.head)
				user << "<span class='warning'>The headgear blocks you from shaving the hair.</span>"
				return

			if(H == user) //shaving yourself
				user.visible_message("<span class='warning'>[user] starts to shave their head with \the [src].</span>", \
									 "<span class='warning'>You start to shave your head with \the [src].</span>")
				if(do_after(user, 30))
					user.visible_message("<span class='notice'>[user] shaves his head with the [src].</span>", \
										 "<span class='notice'>You finish shaving with the [src].</span>")
					H.h_style = "Skinhead"
					H.update_hair()
					playsound(src.loc, 'sound/items/Welder2.ogg', 40, 1)
			else
				var/turf/user_loc = user.loc
				var/turf/H_loc = H.loc
				user.visible_message("<span class='danger'>[user] tries to shave [H]'s head with \the [src]!</span>", \
									 "<span class='warning'>You start shaving [H]'s head.</span>")
				if(do_after(user, 50))
					if(user_loc == user.loc && H_loc == H.loc)
						user.visible_message("<span class='danger'>[user] shaves [H]'s head bald with \the [src]!</span>", \
											 "<span class='warning'>You shave [H]'s head bald.</span>")
						H.h_style = "Skinhead"
						H.update_hair()
						playsound(src.loc, 'sound/items/Welder2.ogg', 40, 1)
		else
			..()
	else
		..()