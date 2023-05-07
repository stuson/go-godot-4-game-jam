extends Node2D
class_name Weapon

var can_attack = true
onready var rof_timer = $RofTimer


func attack() -> void:
    if can_attack:
        can_attack = false
        
        make_attack()
        
        rof_timer.start()
        
func make_attack() -> void:
    pass

func _on_Timer_timeout() -> void:
    can_attack = true
