extends Node2D

onready var life_timer = $Timer
onready var fade_out = $FadeOut
onready var Explosion = $Explosion

var projectile_speed = 300
var velocity
var damage
var knockback_multiplier

func _ready() -> void:
    life_timer.start()
    
func _physics_process(delta: float) -> void:
    velocity = transform.x.normalized() * projectile_speed
    global_translate(velocity * delta)
    
func _on_LifeTimer_timeout() -> void:
    Explosion.monitoring = false
    fade_out.play("Fade Out")


func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("Stats"):
        body.take_hit(damage, transform.x.normalized(), knockback_multiplier)
        
    
    queue_free()
