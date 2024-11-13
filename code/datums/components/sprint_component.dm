
/**
 * Sprint component.
 *
 * When given to a mob, they will be given the ability to sprint
 */

/datum/component/sprint
	var/sprinting = FALSE

/datum/component/sprint/Initialize(...)
	. = ..()
	if (!isliving(owner))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(intercept_clicks))

/datum/component/sprint/proc/start_sprinting()

/datum/component/sprint/proc/stop_sprinting()

/datum/component/sprint/proc/intercept_clicks()
	if (sprinting)
		return COMSIG_MOB_CANCEL_CLICKON
