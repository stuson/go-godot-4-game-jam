extends KinematicBody2D
class_name Enemy

#Base enemy stats to be overridden by specific enemy types
export var damage = 1
export var max_hp = 5
export var speed = 100

var velocity
var knockback_velocity = Vector2.ZERO
var direction: Vector2

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var stats = $Stats

func _ready() -> void:
    stats.max_hp = max_hp
    stats.current_hp = max_hp
    stats.connect("die", self, "_on_Stats_die")
    
func _physics_process(delta: float) -> void:
    direction = (player.global_position - global_position).normalized()
    velocity = direction * speed
    velocity += get_knockback_velocity()
    move_and_slide(velocity)

func take_hit(damage, knockback_direction, knockback_multiplier):
    knockback_velocity = knockback_direction * min(damage, 10) * speed * 5 * knockback_multiplier
    stats.take_hit(damage)

func get_knockback_velocity() -> Vector2:
    knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
    return knockback_velocity

func _on_Stats_die() -> void:
    queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("Stats"):
        body.take_hit(damage, self.global_position)
