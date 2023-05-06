extends Node

export var max_hp = 5

var current_hp = max_hp

signal hp_changed
signal die

func take_hit(damage) -> void:
    current_hp -= damage
    emit_signal("hp_changed", current_hp, max_hp)
    
    if current_hp <= 0:
        emit_signal("die")
