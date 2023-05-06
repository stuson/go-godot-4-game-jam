extends Node
class_name Stats

export var max_hp = 5

var current_hp = max_hp

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
	
