extends Node2D

onready var fade_out = $FadeOut
onready var swing_area = $SwingArea
onready var sfx_player = $SfxPlayer
onready var animation_player = $FadeOut

export(Array, AudioStream) var swoosh_sfx

var damage
var knockback_multiplier
var swing_travel
var is_crit
var hit_objects = []

func _ready() -> void:
    sfx_player.pitch_scale = rand_range(0.9, 1.1)
    sfx_player.stream = swoosh_sfx[randi() % swoosh_sfx.size()]
    sfx_player.play()
    fade_out.play("Fade Out")

func _physics_process(delta: float) -> void:
    position = position + swing_travel * delta * transform.x

func _on_SwingArea_body_entered(body: Node) -> void:
    if body.has_node("Stats"):
        var id = body.get_instance_id()
        
        if not id in hit_objects:
            body.take_hit(damage, (body.global_position - global_position).normalized(), knockback_multiplier, is_crit)
            hit_objects.append(id)
        
func _on_FadeOut_animation_finished(anim_name):
    queue_free()
