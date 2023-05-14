extends Node2D

var death_action: FuncRef
var color: Color
var icon

const ICON_COORDS = {
    "hp": Vector2(64, 480),
    "attack": Vector2(128, 32),
    "speed": Vector2(64, 256),
    "duplicate": Vector2(0, 64)
}

onready var area = $Area2D
onready var explosion_material: ShaderMaterial = $Sprite.material
onready var player = $AnimationPlayer
onready var buff_icon: Sprite = $BuffIndicator/Icon

func _ready() -> void:
    explosion_material.set_shader_param("color", color)
    buff_icon.texture.region = Rect2(ICON_COORDS[icon], Vector2(32, 32))
    player.play("Explosion")

func apply_explosion_effect():
    var bodies = area.get_overlapping_bodies()
    for body in bodies:
        body.play_explosion_effect_animation(color)
    death_action.call_func(bodies)
        
func remove_explosion():
    queue_free()
