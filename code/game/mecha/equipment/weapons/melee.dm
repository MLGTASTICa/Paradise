/obj/item/mecha_parts/mecha_equipment/melee
	name = "mecha melee weapon"
	range = MECHA_MELEE
	origin_tech = "materials=3;combat=3"
	var/damage = 10
	var/damage_type = BRUTE
	var/attack_cooldown = 1 SECONDS
	var/wide = FALSE

/obj/item/mecha_parts/mecha_equipment/melee/can_attach(obj/mecha/combat/M as obj)
	if(..())
		if(locate(src.type) in M)
			return FALSE
		return TRUE

/// Only called if the initial attack was succesfull (dealt over 50% of its damage)
/obj/item/mecha_parts/mecha_equipment/melee/proc/after_attack(atom/target)

/obj/item/mecha_parts/mecha_equipment/melee/action(atom/target)
	. = ..()
	if(!.)
		return
	if(wide)
		var/list/attack_turfs = list()
		var/target_dir = get_dir(chassis, target)
		var/current_turf = get_step(chassis, target_dir)
		target_dir = turn(target_dir, -90)
		attack_turfs.Add(get_step(current_turf, target_dir))
		attack_turfs.Add(current_turf)
		target_dir = turn(target_dir, 270)
		attack_turfs.Add(get_step(current_turf, target_dir))

	if(chassis && chassis.occupant)
		chassis.occupant.changeNext_click(attack_cooldown)
	if(target.mech_melee_attack(chassis, damage, damage_type, src) > round(damage/2))
		after_attack(target)

/obj/item/mecha_parts/mecha_equipment/melee/sword
	name = "mecha sword"
	desc = "slash slash all your worries away."
	damage = 45



