extends Node
class_name Stats

export var max_hp = 100 setget set_max_hp
export var damage_multiplier = 1
export var crit_chance = 0.05
export var crit_multiplier = 1.5
export var move_speed = 200
export var attack_speed_multiplier = 1 setget set_attack_speed
export var life_on_kill = 0
export var knockback_multiplier = 1
export var attack_size_multiplier = 1
export var chain = 0
export var swing_travel = 50

export var enemy_move_speed_multiplier = 1
export var enemy_health_multiplier = 1
export var enemy_count_reduction = 0

onready var current_hp = max_hp setget set_current_hp
var DamageNumber = preload("res://ui/DamageNumber.tscn")

onready var parent: KinematicBody2D = get_parent()

signal hp_changed
signal die

func initialize_hp(init_current_hp, init_max_hp):
    current_hp = init_current_hp
    max_hp = init_max_hp

func emit_hp_change() -> void:
    emit_signal("hp_changed", current_hp, max_hp)

func take_hit(damage, is_crit=false) -> void:
    set_current_hp(current_hp - damage, is_crit)
    
    if current_hp <= 0:
        emit_signal("die")

func set_max_hp(new_max_hp):
    max_hp = new_max_hp
    emit_hp_change()

func set_current_hp(new_current_hp, is_crit=false):
    
    if current_hp == new_current_hp:
        return

    var damage_number = DamageNumber.instance()
    damage_number.amount = abs(current_hp - new_current_hp)
    if new_current_hp > current_hp:
        damage_number.color = Color.green
    elif is_crit:
        damage_number.max_scale = Vector2(1.5, 1.5)
        damage_number.color = Color.darkorange
    elif parent.is_in_group("Player"):
        damage_number.color = Color.red
    get_tree().current_scene.add_child(damage_number)
    damage_number.global_position = parent.global_position
    
    current_hp = min(new_current_hp, max_hp)
    
    emit_hp_change()

func set_attack_speed(new_attack_speed):
    attack_speed_multiplier = new_attack_speed
    if parent:
        for weapon in parent.weapons:
            weapon.update_rof()

func update(other_stats: Stats) -> void:
    max_hp = other_stats.max_hp
    damage_multiplier = other_stats.damage_multiplier
    crit_chance = other_stats.crit_chance
    crit_multiplier = other_stats.crit_multiplier
    move_speed = other_stats.move_speed
    attack_speed_multiplier = other_stats. attack_speed_multiplier
    life_on_kill = other_stats.life_on_kill
    knockback_multiplier = other_stats.knockback_multiplier
    attack_size_multiplier = other_stats.attack_size_multiplier

    enemy_move_speed_multiplier = other_stats.enemy_move_speed_multiplier
    enemy_health_multiplier = other_stats.enemy_health_multiplier
    enemy_count_reduction = other_stats.enemy_count_reduction

    current_hp = max_hp
