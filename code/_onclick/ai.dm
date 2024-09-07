/*
	AI ClickOn()

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(var/atom/A, params)
	if(control_disabled || incapacitated())
		return

	if(ismob(A))
		ai_start_tracking(A)
	else if(!ismachinery(A))	//Getting the camera moved just because you double click on something to interact with it is annoying as hell
		eyeobj.move_camera_by_click(A)

/mob/living/silicon/ai/ClickOn(var/atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(!can_interact_with(A))
		return

	if(multicam_on)
		var/turf/T = get_turf(A)
		if(T)
			for(var/atom/movable/screen/movable/pic_in_pic/ai/P in T.vis_locs)
				if(P.ai == src)
					P.Click(params)
					break

	if(check_click_intercept(params,A))
		return

	if(control_disabled || incapacitated())
		return

	var/turf/pixel_turf = get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!can_see(A))
		if(isturf(A)) //On unmodified clients clicking the static overlay clicks the turf underneath
			return //So there's no point messaging admins
		message_admins("[ADMIN_LOOKUPFLW(src)] might be running a modified client! (failed can_see on AI click of [A] (Turf Loc: [ADMIN_VERBOSEJMP(pixel_turf)]))")
		var/message = "[key_name(src)] might be running a modified client! (failed can_see on AI click of [A] (Turf Loc: [AREACOORD(pixel_turf)]))"
		log_admin(message)
		if(REALTIMEOFDAY >= chnotify + 9000)
			chnotify = REALTIMEOFDAY
			send2tgs_adminless_only("NOCHEAT", message)
		return

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlShiftClickOn(A)
			return
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK)) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, params)
		return

	if(world.time <= next_move)
		return

	if(aicamera.in_camera_mode)
		aicamera.camera_mode_off()
		aicamera.captureimage(pixel_turf, usr, null, aicamera.picture_size_x - 1, aicamera.picture_size_y - 1)
		return
	if(waypoint_mode)
		waypoint_mode = 0
		set_waypoint(A)
		return

	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlShiftClickOn(var/atom/A)
	A.AICtrlShiftClick(src)
/mob/living/silicon/ai/ShiftClickOn(var/atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(var/atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/AltClickOn(var/atom/A)
	A.AIAltClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/
/* Questions: Instead of an Emag check on every function, can we not add to airlocks onclick if emag return? */

/* Atom Procs */
/atom/proc/AICtrlClick(mob/living/silicon/ai/user)
	return
/atom/proc/AIAltClick(mob/living/silicon/ai/user)
	AltClick(user)
	return
/atom/proc/AIShiftClick(mob/living/silicon/ai/user)
	return
/atom/proc/AICtrlShiftClick(mob/living/silicon/ai/user)
	return

/* Airlocks */
/obj/machinery/door/airlock/AICtrlClick(mob/living/silicon/ai/user) // Bolts doors
	if(obj_flags & EMAGGED)
		return

	if(!allowed(user))
		return

	toggle_bolt(usr)
	add_hiddenprint(usr)

/obj/machinery/door/airlock/AIAltClick(mob/living/silicon/ai/user) // Electrifies doors.
	if(obj_flags & EMAGGED)
		return

	if(!allowed(user))
		return

	if(!secondsElectrified)
		shock_perm(usr)
	else
		shock_restore(usr)

/obj/machinery/door/airlock/AIShiftClick(mob/living/silicon/ai/user)  // Opens and closes doors!
	if(obj_flags & EMAGGED)
		return

	if(!allowed(user))
		return

	user_toggle_open(usr)
	add_hiddenprint(usr)

/obj/machinery/door/airlock/AICtrlShiftClick(mob/living/silicon/ai/user)  // Sets/Unsets Emergency Access Override
	if(obj_flags & EMAGGED)
		return

	if(!allowed(user))
		return

	toggle_emergency(usr)
	add_hiddenprint(usr)

/* APC */
/obj/machinery/power/apc/AICtrlClick(mob/living/silicon/ai/user) // turns off/on APCs.
	if(!allowed(user))
		return
	if(can_use(usr, 1))
		toggle_breaker(usr)

/* AI Turrets */
/obj/machinery/turretid/AIAltClick(mob/living/silicon/ai/user) //toggles lethal on turrets
	if(!allowed(user))
		return
	if(ailock)
		return
	toggle_lethal(usr)

/obj/machinery/turretid/AICtrlClick(mob/living/silicon/ai/user) //turns off/on Turrets
	if(!allowed(user))
		return
	if(ailock)
		return
	toggle_on(usr)

/* Holopads */
/obj/machinery/holopad/AIAltClick(mob/living/silicon/ai/user)
	if(!allowed(user))
		return
	hangup_all_calls()
	add_hiddenprint(usr)

/* Atmos machines */
/obj/machinery/atmospherics/components/AICtrlClick(mob/living/silicon/ai/user)
	if(!allowed(user))
		return
	CtrlClick(user)

//
// Override TurfAdjacent for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(var/turf/T)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T))
