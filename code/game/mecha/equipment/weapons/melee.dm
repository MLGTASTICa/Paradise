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
	var/list/damage_sounds = list(
		BRUTE = 'sound/weapons/punch4.ogg',
		BURN = 'sound/items/welder.ogg',
		TOXIN = 'sound/effects/spray2.ogg'
	)

/obj/item/mecha_parts/mecha_equipment/melee/can_attach(obj/mecha/combat/M as obj)
	if(..())
		if(locate(src.type) in M)
			return FALSE
		return TRUE

/// Only called if the initial attack was succesfull (dealt over 50% of its damage)
/obj/item/mecha_parts/mecha_equipment/melee/proc/after_attack(atom/target)

/obj/item/mecha_parts/mecha_equipment/melee/action(atom/target)
	. = ..()
	var/sound_turf = get_turf(target)
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
			for(var/atom/attackable in target_turf.contents)
				attack_target(attackable)
	else if(melee_flags == WIDE_ATTACK_CONCENTRATED)
		for(var/atom/attackable in sound_turf)
			attack_target(attackable)
	else
		attack_target(target)

	chassis.do_attack_animation(sound_turf)
	if(damage_type in damage_sounds)
		playsound(sound_turf, damage_sounds[damage_type], 100)

	if(chassis && chassis.occupant)
		chassis.occupant.changeNext_click(attack_cooldown)

/obj/item/mecha_parts/mecha_equipment/melee/proc/attack_target(atom/target)
	var/true_damage = force
	if(melee_flags & STRUCTURE_DEMOLISHER && isstructure(target))
		true_damage *= 3
	if(melee_flags & WIDE_ATTACK_CONCENTRATED)
		true_damage *= 0.6
	else if(melee_flags & WIDE_ATTACK)
		true_damage *= 0.3
	var/damage_dealt = target.mech_melee_attack(chassis, true_damage, damage_type, src)
	if(!QDELETED(target))
		after_attack(target, damage_dealt)

/obj/item/mecha_parts/mecha_equipment/melee/sword
	name = "mecha sword"
	desc = "slash slash all your worries away."
	damage = 45



