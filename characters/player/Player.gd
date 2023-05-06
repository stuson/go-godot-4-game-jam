extends KinematicBody2D
class_name Player

var speed = 200
var direction: Vector2
var velocity = Vector2.ZERO
var equipped_weapon
var knockback_velocity = Vector2.ZERO

export(PackedScene) var StartingWeapon

func _ready() -> void:
    equipped_weapon = StartingWeapon.instance()
    add_child(equipped_weapon)
    
func _physics_process(delta: float) -> void:
    # Movement
    direction = Vector2.ZERO
    if Input.is_action_pressed("move_right"):
        direction.x += 1
    if Input.is_action_pressed("move_left"):
        direction.x -= 1
    if Input.is_action_pressed("move_up"):
        direction.y -= 1
    if Input.is_action_pressed("move_down"):
        direction.y += 1
    
    velocity = direction.normalized() * speed
    velocity += get_knockback(delta)
    move_and_slide(velocity)
    
    # Look
    look_at(get_global_mouse_position())
    
    # Attack
    if Input.is_action_pressed("attack"):
        equipped_weapon.attack()

func get_knockback(delta) -> Vector2:
    knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
    return knockback_velocity

func take_hit(damage, enemy_pos):
    $Stats.take_hit(damage)
    var knockback_direction = (global_position - enemy_pos).normalized()
    knockback_velocity = knockback_direction * min(damage, 10) * 1000

func _on_Stats_die() -> void:
    get_tree().quit()
