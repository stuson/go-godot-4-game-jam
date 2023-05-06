extends KinematicBody2D

var speed = 100
var velocity
var knockback_velocity = Vector2.ZERO
var direction: Vector2

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var stats = $Stats

export var damage = 1
	
func _physics_process(delta: float) -> void:
	direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	velocity += get_knockback_velocity()
	move_and_slide(velocity)

func take_hit(damage, knockback_direction):
	knockback_velocity = knockback_direction * min(damage, 10) * 500
	stats.take_hit(damage)

func get_knockback_velocity() -> Vector2:
	knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
	return knockback_velocity

func _on_Stats_die() -> void:
	queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
	if body.has_node("Stats"):
		body.take_hit(damage, self.global_position)
