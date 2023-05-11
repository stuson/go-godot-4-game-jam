extends Node2D

onready var life_timer = $Timer

var projectile_speed = 500
var velocity
var damage
var knockback_multiplier
var is_crit

func _ready() -> void:
    life_timer.start()
    
func _physics_process(delta: float) -> void:
    velocity = transform.x.normalized() * projectile_speed
    global_translate(velocity * delta)
    
func _on_Timer_timeout() -> void:
    queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("Stats"):
        body.take_hit(damage, transform.x.normalized(), knockback_multiplier, is_crit)
    
    queue_free()
