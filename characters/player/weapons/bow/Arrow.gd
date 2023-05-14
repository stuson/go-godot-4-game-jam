extends KinematicBody2D

onready var life_timer = $Timer
onready var bounce_sfx: AudioStreamPlayer = $BounceSfx

var projectile_speed = 500
var velocity
var damage
var knockback_multiplier
var chain
var is_crit
var hit_objects = []
var pitch_amount = 0

func _ready() -> void:
    life_timer.start()
    
func _physics_process(delta: float) -> void:
    var collision: KinematicCollision2D = move_and_collide(velocity * delta)
    if collision:
        hit(collision)
    
func _on_Timer_timeout() -> void:
    queue_free()

func hit(collision: KinematicCollision2D) -> void:
    var id = collision.collider_id
    var body = collision.collider
    if body.has_node("Stats") and not id in hit_objects:
        body.take_hit(damage, transform.x.normalized(), knockback_multiplier, is_crit)
        hit_objects.append(id)
            
    if chain > 0:
        bounce(collision)
    else:
        queue_free()

func bounce(collision: KinematicCollision2D) -> void:
    randomize()
    bounce_sfx.pitch_scale = rand_range(1.2, 1.4) + pitch_amount
    bounce_sfx.play()
    
    chain -= 1
    pitch_amount += 0.5
    
    var all_enemies = get_tree().get_nodes_in_group("enemy")
    var enemy_found = false
    var min_distance = 10000
    var remainder = collision.remainder.bounce(collision.normal)
    var direction = remainder.normalized()
    velocity = velocity.bounce(collision.normal)
    
    for enemy in all_enemies:
        var distance = global_position.distance_to(enemy.global_position)
        if distance < min_distance and not enemy.get_instance_id() in hit_objects:
            direction = (enemy.global_position - global_position).normalized()
            min_distance = distance
            enemy_found = true
    
    if enemy_found:
        remainder *= direction
        velocity = direction * projectile_speed
    
    look_at(global_position + direction)
    move_and_collide(remainder)
        
