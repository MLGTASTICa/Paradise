#define NO_WIDE_ATTACK 0
/// This is a normal wide attack
#define WIDE_ATTACK (1<<0)
/// This is normally a weapon with wide attacks ,but we are focusing.
#define WIDE_ATTACK_CONCENTRATED (1<<1)
/// Deals 3x damage against structures
#define STRUCTURE_DEMOLISHER (1<<2)

/obj/item/mecha_parts/mecha_equipment/melee
	name = "mecha melee weapon"
	range = MECHA_MELEE
	origin_tech = "materials=3;combat=3"
	var/damage = 10
	var/damage_type = BRUTE
	var/attack_cooldown = 1 SECONDS
	var/melee_flags = NO_WIDE_ATTACK

/obj/item/mecha_parts/mecha_equipment/melee/can_attach(obj/mecha/combat/M as obj)
	if(..())
		if(locate(src.type) in M)
			return FALSE
		return TRUE

/// Only called if the initial attack was succesfull (dealt over 50% of its damage)
/obj/item/mecha_parts/mecha_equipment/melee/proc/after_attack(atom/target)

/obj/item/mecha_parts/mecha_equipment/melee/action(atom/target)
	. = ..()
	if(melee_flags == WIDE_ATTACK)
		var/list/attack_turfs = list()
		var/target_dir = get_dir(chassis, target)
		var/current_turf = get_step(chassis, target_dir)
		target_dir = turn(target_dir, -90)
		attack_turfs.Add(get_step(current_turf, target_dir))
		attack_turfs.Add(current_turf)
		target_dir = turn(target_dir, 270)
		attack_turfs.Add(get_step(current_turf, target_dir))
		target_dir = get_dir(chassis,target)
		for(var/turf/target_turf in attack_turfs)
			for(var/obj/attackable in target_turf.contents)
				attack_target(attackable)
	else
		attack_target(target)

	if(chassis && chassis.occupant)
		chassis.occupant.changeNext_click(attack_cooldown)

/obj/item/mecha_parts/mecha_equipment/melee/proc/attack_target(atom/target)
	var/true_damage = damage
	if(melee_flags & STRUCTURE_DEMOLISHER && isstructure(target))
		true_damage *= 3
	if(melee_flags & WIDE_ATTACK_CONCENTRATED)
		true_damage *= 0.6
	else if(melee_flags & WIDE_ATTACK)
		true_damage *= 0.3
	else
		chassis.do_attack_animation(target)
		chassis.visible_message("<span class='danger'>[chassis.name] hits [target]!</span>", "<span class='danger'>You hit [target]!</span>")

	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		if(TOX)
			playsound(src, 'sound/effects/spray2.ogg', 50, TRUE)

	if(target.mech_melee_attack(chassis, true_damage, damage_type, src) > round(true_damage/2))
		chassis.visible_message("<span class='danger'>[chassis.name] hits [target]!</span>", "<span class='danger'>You hit [target]!</span>")
		if(QDELETED(target))
			return
		after_attack(target)
	else if(isliving(target))
		chassis.visible_message("<span class='warning'>[chassis.name] pushes [target] out of the way.</span>")

/obj/item/mecha_parts/mecha_equipment/melee/sword
	name = "mecha sword"
	desc = "slash slash all your worries away."
	damage = 45



