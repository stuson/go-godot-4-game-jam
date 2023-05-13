extends Node2D

onready var life_timer = $LifeTimer
onready var fade_out = $FadeOut
onready var Projectile = $Hitbox

var fireballexplosion: Node2D
export(PackedScene) var FireballExplosion

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
    Projectile.monitoring = false
    fade_out.play("Fade Out")



func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("Stats"):
        fireballexplosion = FireballExplosion.instance()
        fireballexplosion.damage = damage
        get_tree().current_scene.add_child(fireballexplosion)
        fireballexplosion.global_position = global_position
        
        
    
    queue_free()
