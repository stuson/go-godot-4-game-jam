extends KinematicBody2D
class_name Enemy

#Base enemy stats to be overridden by specific enemy types
export var damage = 1
export var max_hp = 5
export var speed = 100
export(Color) var explode_color
export(float) var explode_scale = 1

var velocity
var knockback_velocity = Vector2.ZERO

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var stats = $Stats
onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
onready var nav_timer = $NavigationRefreshTimer

export(PackedScene) var death_explosion

func _ready() -> void:
    stats.max_hp = max_hp
    stats.current_hp = max_hp
    stats.move_speed = speed
    stats.connect("die", self, "_on_Stats_die")
    nav_timer.connect("timeout", self, "_on_NavigationRefreshTimer_timeout")
    
func _physics_process(delta: float) -> void:
    if not nav_agent.is_navigation_finished():
        var target_pos = nav_agent.get_next_location()
        var direction = global_transform.origin.direction_to(target_pos)
        velocity = direction * stats.move_speed
        velocity += get_knockback_velocity()
        move_and_slide(velocity)

func take_hit(damage, knockback_direction, knockback_multiplier):
    knockback_velocity = knockback_direction * min(damage, 10) * speed * 5 * knockback_multiplier
    stats.take_hit(damage)

func get_knockback_velocity() -> Vector2:
    knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
    return knockback_velocity

func _on_Stats_die() -> void:
    var explosion = death_explosion.instance()
    explosion.color = explode_color
    explosion.death_action = funcref(self, "death_explosion")
    explosion.global_position = global_position
    explosion.scale *= explode_scale * sqrt(scale.length())
    get_tree().current_scene.add_child(explosion)
    

func _on_Area2D_body_entered(body: Node) -> void:
    if body.has_node("Stats"):
        body.take_hit(damage, self.global_position)

func _on_NavigationRefreshTimer_timeout() -> void:
    nav_agent.set_target_location(player.global_position)

func death_explosion(bodies: Array) -> void:
    for body in bodies:
        if body.has_node("Stats"):
            death_explosion_effect(body)
    queue_free()
    
func death_explosion_effect(body) -> void:
    pass #Implement per enemy
