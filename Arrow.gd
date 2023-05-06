extends Node2D

onready var life_timer = $Timer

var projectile_speed = 500
var velocity
var damage

func _ready() -> void:
    life_timer.start()
    
func _physics_process(delta: float) -> void:
    velocity = transform.x.normalized() * projectile_speed
    global_translate(velocity * delta)
    
func _on_Timer_timeout() -> void:
    queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("HpManager"):
        body.take_hit(damage, transform.x.normalized())
    
    queue_free()
