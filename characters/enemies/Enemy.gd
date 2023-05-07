extends KinematicBody2D
class_name Enemy

#Base enemy stats to be overridden by specific enemy types
export var damage = 1
export var max_hp = 5
export var speed = 100

var velocity
var knockback_velocity = Vector2.ZERO

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var stats = $Stats
onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
onready var nav_timer = $NavigationRefreshTimer
onready var sprite_material: ShaderMaterial = $Sprite.material

func _ready() -> void:
    stats.max_hp = max_hp
    stats.current_hp = max_hp
    stats.connect("die", self, "_on_Stats_die")
    nav_timer.connect("timeout", self, "_on_NavigationRefreshTimer_timeout")
    
func _physics_process(delta: float) -> void:
    if not nav_agent.is_navigation_finished():
        var target_pos = nav_agent.get_next_location()
        var direction = global_transform.origin.direction_to(target_pos)
        velocity = direction * speed
        velocity += get_knockback_velocity()
        move_and_slide(velocity)

func take_hit(damage, knockback_direction, knockback_multiplier):
    knockback_velocity = knockback_direction * min(damage, 10) * speed * 5 * knockback_multiplier
    stats.take_hit(damage)
    
    sprite_material.set_shader_param("redden", true)
    yield(get_tree().create_timer(0.15), "timeout")
    sprite_material.set_shader_param("redden", false)

func get_knockback_velocity() -> Vector2:
    knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
    return knockback_velocity

func _on_Stats_die() -> void:
    queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("Stats"):
        body.take_hit(damage, self.global_position)

func _on_NavigationRefreshTimer_timeout() -> void:
    nav_agent.set_target_location(player.global_position)
