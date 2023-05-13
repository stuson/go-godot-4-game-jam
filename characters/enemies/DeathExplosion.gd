extends Node2D

var death_action: FuncRef
var color: Color

onready var area = $Area2D
onready var explosion_material: ShaderMaterial = $Sprite.material
onready var player = $AnimationPlayer

func _ready() -> void:
    explosion_material.set_shader_param("color", color)
    player.play("Explosion")

func apply_explosion_effect():
    var bodies = area.get_overlapping_bodies()
    for body in bodies:
        body.play_explosion_effect_animation(color)
    death_action.call_func(bodies)
        
func remove_explosion():
    queue_free()
