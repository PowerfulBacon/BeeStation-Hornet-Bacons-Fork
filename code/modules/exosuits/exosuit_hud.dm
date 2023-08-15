
/obj/item/clothing/suit/space/hardsuit/exosuit/proc/clear_huds(mob/user)
	user.clear_alert("mech_charge")

/obj/item/clothing/suit/space/hardsuit/exosuit/proc/update_power_hud(mob/user)
	if(user && installed_cell)
		var/cellcharge = installed_cell.maxcharge ? installed_cell.charge / installed_cell.maxcharge : 0 //Division by 0 protection
		switch(cellcharge)
			if(0.75 to INFINITY)
				user.clear_alert("mech_charge")
			if(0.5 to 0.75)
				user.throw_alert("mech_charge", /atom/movable/screen/alert/lowcell, 1)
			if(0.25 to 0.5)
				user.throw_alert("mech_charge", /atom/movable/screen/alert/lowcell, 2)
			if(0.01 to 0.25)
				user.throw_alert("mech_charge", /atom/movable/screen/alert/lowcell, 3)
			else
				user.throw_alert("mech_charge", /atom/movable/screen/alert/emptycell)
