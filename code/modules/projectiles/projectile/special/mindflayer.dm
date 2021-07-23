/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.body.apply_injury(BP_BRAIN, /datum/injury/organ_damage, 2)
		M.hallucination += 30
