
#define PANEL_STATE_INITIAL 0
#define PANEL_STATE_CREATE_SHIP_FACTION 1
#define PANEL_STATE_JOIN_SHIP_PANEL 2

/datum/new_player_panel
	///The initial state of the panel
	var/current_state = PANEL_STATE_INITIAL

/datum/new_player_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NewPlayerPanel")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/new_player_panel/ui_data(mob/user)
	var/list/data = list()

	data["state"] = current_state

	switch (current_state)
		if (PANEL_STATE_JOIN_SHIP_PANEL)
			//List the current ships in the game that are joinable
			data["a"] = "b"

	return data

/datum/new_player_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/mob/dead/new_player/new_player = usr

	switch (action)
		//Switch the player panel state
		if ("switch_state")
			var/new_state = params["new_state"]
			current_state = new_state
			return TRUE
		//Enter observe mode
		if ("observe")
			new_player.ready = PLAYER_READY_TO_OBSERVE
			//if it's post initialisation and they're trying to observe we do the needful
			if(!SSticker.current_state < GAME_STATE_PREGAME)
				new_player.make_me_an_observer()
				return
		//Create a new ship as the captain
		//Join the selected ship
		//Go to character setup screen

/datum/new_player_panel/ui_state(mob/user)
	return GLOB.always_state
