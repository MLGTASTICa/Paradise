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
	force = 10
	damtype = BRUTE
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

/obj/item/mecha_parts/mecha_equipment/melee/proc/after_attack(atom/target)
	return

/obj/effect/melee_swing
	icon = 'icons/mecha/mecha_swing.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/melee_swing/New(loc, dir)
	. = ..()
	src.dir = dir

/obj/effect/melee_swing/Initialize(mapload)
	. = ..()
	flick(pick("left_swing","right_swing"), src)
	QDEL_IN(src, 1 SECONDS)

/obj/item/mecha_parts/mecha_equipment/melee/action(atom/target)
	. = ..()
	var/sound_turf = get_turf(target)
	if(melee_flags == WIDE_ATTACK)
		var/list/attack_turfs = list()
		var/target_dir = get_dir(chassis, target)
		var/current_turf = get_step(chassis, target_dir)
		new /obj/effect/melee_swing(get_turf(chassis), target_dir)
		attack_turfs.Add(get_step(current_turf, turn(target_dir,90)))
		attack_turfs.Add(current_turf)
		attack_turfs.Add(get_step(current_turf, turn(target_dir,-90)))
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
	force = true_damage
	var/damage_dealt = target.mech_melee_attack(chassis, true_damage, damage_type, src)
	if(!QDELETED(target))
		after_attack(target, damage_dealt)
	force = initial(true_damage)

/obj/item/mecha_parts/mecha_equipment/melee/sword
	name = "mecha sword"
	desc = "slash slash all your worries away."
	icon_state = "mecha_sword"
	damtype = BRUTE
	melee_flags = WIDE_ATTACK
	force = 45

/obj/item/mecha_parts/mecha_equipment/melee/glove
	name = "mecha glove"
	desc = "the flesh is weak."
	icon_state = "mecha_glove"
	damtype = STAMINA
	force = 60

/obj/item/mecha_parts/mecha_equipment/melee/fist
	name = "mecha fist"
	desc = "NT-approved standard fit mecha fists. Guaranteed to decimate carps and other space threats."
	icon_state = "mecha_fist"
	melee_flags = STRUCTURE_DEMOLISHER
	damtype = BRUTE
	force = 30

/obj/item/mecha_parts/mecha_equipment/melee/axe
	name = "mecha battle axe"
	desc = "A mech-sized version of the famous energy axe."
	icon_state = "mecha_axe"
	melee_flags = WIDE_ATTACK
	damtype = BURN
	force = 75


