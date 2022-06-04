
/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && HAS_TRAIT(src, TRAIT_TOXINLOVER)) //damage becomes healing and healing becomes damage
		amount = -amount
		if(amount > 0)
			blood_volume -= 5*amount
		else
			blood_volume -= amount
	if(HAS_TRAIT(src, TRAIT_TOXIMMUNE)) //Prevents toxin damage, but not healing
		amount = min(amount, 0)
	return ..()

/mob/living/carbon/getStaminaLoss()
	. = 0
	for(var/obj/item/bodypart/BP as() in bodyparts)
		. += round(BP.stamina_dam * BP.stam_damage_coeff, DAMAGE_PRECISION)

/mob/living/carbon/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, 0, amount, updating_health)
	else
		heal_overall_damage(0, 0, abs(amount), null, updating_health)
	return amount

/mob/living/carbon/setStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	var/current = getStaminaLoss()
	var/diff = amount - current
	if(!diff)
		return
	adjustStaminaLoss(diff, updating_health, forced)

/** adjustOrganLoss
  * inputs: slot (organ slot, like ORGAN_SLOT_HEART), amount (damage to be done), and maximum (currently an arbitrarily large number, can be set so as to limit damage)
  * outputs:
  * description: If an organ exists in the slot requested, and we are capable of taking damage (we don't have GODMODE on), call the damage proc on that organ.
  */
/mob/living/carbon/adjustOrganLoss(slot, amount, maximum, required_status)
	var/obj/item/organ/O = getorganslot(slot)
	if(O && !(status_flags & GODMODE))
		if(required_status && O.status != required_status)
			return FALSE
		O.applyOrganDamage(amount, maximum)

/** setOrganLoss
  * inputs: slot (organ slot, like ORGAN_SLOT_HEART), amount(damage to be set to)
  * outputs:
  * description: If an organ exists in the slot requested, and we are capable of taking damage (we don't have GODMODE on), call the set damage proc on that organ, which can
  *				 set or clear the failing variable on that organ, making it either cease or start functions again, unlike adjustOrganLoss.
  */
/mob/living/carbon/setOrganLoss(slot, amount)
	var/obj/item/organ/O = getorganslot(slot)
	if(O && !(status_flags & GODMODE))
		O.setOrganDamage(amount)

/** getOrganLoss
  * inputs: slot (organ slot, like ORGAN_SLOT_HEART)
  * outputs: organ damage
  * description: If an organ exists in the slot requested, return the amount of damage that organ has
  */
/mob/living/carbon/getOrganLoss(slot)
	var/obj/item/organ/O = getorganslot(slot)
	if(O)
		return O.damage

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/proc/get_damaged_bodyparts(brute = FALSE, burn = FALSE, stamina = FALSE, status)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(status && !(BP.bodytype & status))
			continue
		if((brute && BP.brute_dam) || (burn && BP.burn_dam) || (stamina && BP.stamina_dam))
			parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/proc/get_damageable_bodyparts(status)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(status && !(BP.bodytype & status))
			continue
		if(BP.brute_dam + BP.burn_dam < BP.max_damage)
			parts += BP
	return parts
