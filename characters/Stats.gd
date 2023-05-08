extends Node
class_name Stats

export var max_hp = 5 setget set_max_hp
export var damage_multiplier = 1
export var crit_chance = 0
export var crit_multiplier = 2
export var move_speed = 200
export var attack_speed_multiplier = 1
export var lifesteal = 0
export var knockback_multiplier = 1
export var attack_size_multiplier = 1

export var enemy_move_speed_multiplier = 1
export var enemy_health_multiplier = 1
export var enemy_count_reduction = 0

var current_hp = max_hp setget set_current_hp

onready var parent: KinematicBody2D = get_parent()

signal hp_changed
signal die

func emit_hp_change() -> void:
    emit_signal("hp_changed", current_hp, max_hp)

func take_hit(damage) -> void:
    current_hp -= damage
    emit_hp_change()
    
    if current_hp <= 0:
        emit_signal("die")

func set_max_hp(new_max_hp):
    max_hp = new_max_hp
    emit_hp_change()

func set_current_hp(new_current_hp):
    current_hp = min(new_current_hp, max_hp)
    emit_hp_change()
