extends Node2D

var death_action: FuncRef
var color: Color

onready var area = $Area2D
onready var explosion_material: ShaderMaterial = $Sprite.material
onready var player = $AnimationPlayer

func _ready() -> void:
    explosion_material.set_shader_param("color", color)
    player.play("Explosion")

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "Explosion":
        var bodies = area.get_overlapping_bodies()
        death_action.call_func(bodies)
        player.play("Explosion Fade")
    elif anim_name == "Explosion Fade":
        queue_free()
        
