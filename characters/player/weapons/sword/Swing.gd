extends Node2D

onready var life_timer = $LifeTimer
onready var fade_out = $FadeOut
onready var swing_area = $SwingArea
var damage
var knockback_multiplier

func _ready() -> void:
    life_timer.start()
       
func _on_LifeTimer_timeout() -> void:
    swing_area.monitoring = false
    fade_out.play("Fade Out")

func _on_SwingArea_body_entered(body: Node) -> void:
    print("hit")
    if body.has_node("Stats"):
        body.take_hit(damage, (body.global_position - global_position).normalized(), knockback_multiplier)

func _on_FadeOut_animation_finished(anim_name):
    queue_free()
