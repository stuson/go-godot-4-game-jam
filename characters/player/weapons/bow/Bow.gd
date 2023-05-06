extends Node2D

const BASE_DAMAGE = 1

var can_shoot = true
var arrow: Node2D

onready var rof_timer = $Timer

export(PackedScene) var Projectile


func attack() -> void:
    if can_shoot:
        can_shoot = false
        
        arrow = Projectile.instance()
        arrow.global_transform = global_transform
        arrow.damage = BASE_DAMAGE
        get_tree().current_scene.add_child(arrow)
        
        rof_timer.start()


func _on_Timer_timeout() -> void:
    can_shoot = true
