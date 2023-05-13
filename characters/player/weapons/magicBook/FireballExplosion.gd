extends Node2D

var damage_action: FuncRef
var color: Color
var Fireball: Node2D
var damage
var knockback_multiplier
var knockback_direction

onready var area = $Area2D
onready var explosion_material: ShaderMaterial = $Sprite.material
onready var player = $AnimationPlayer

func _ready() -> void:
    explosion_material.set_shader_param("color", color)
    player.play("Explosion")
    

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "Explosion":
        var bodies = area.get_overlapping_bodies()
        for body in bodies: 
            if body.has_node("Stats"):
                body.take_hit(damage, Vector2.ZERO, 0)
        player.play("Explosion Fade")
    elif anim_name == "Explosion Fade":
        queue_free()
