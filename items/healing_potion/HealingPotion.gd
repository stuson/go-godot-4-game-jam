extends Node2D

const potion = true
const healing = 30

onready var animation_player = $AnimationPlayer

func _ready() -> void:
    animation_player.play("Fade Out")

func _on_Area2D_area_entered(area):
    var player = area.get_parent()
    player.stats.current_hp += healing
    queue_free()



func _on_AnimationPlayer_animation_finished(anim_name):
    queue_free()
