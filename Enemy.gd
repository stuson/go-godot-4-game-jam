extends KinematicBody2D

var speed = 100
var velocity
var direction: Vector2

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]

export var damage = 1
    
func _physics_process(delta: float) -> void:
    direction = (player.global_position - global_position).normalized()
    velocity = direction * speed
    move_and_slide(velocity)


func _on_HpManager_die() -> void:
    queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("HpManager"):
        body.take_hit(damage, self.global_position)
