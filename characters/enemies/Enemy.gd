extends KinematicBody2D
class_name Enemy

#Base enemy stats to be overridden by specific enemy types
export var damage = 1
export var max_hp = 5
export var speed = 100
export(Color) var explode_color
export(float) var explode_scale = 1.0
export(Array, AudioStream) var hit_sfx

var velocity: Vector2
var knockback_velocity = Vector2.ZERO
var dying = false

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var stats = $Stats
onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
onready var nav_timer = $NavigationRefreshTimer
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var sprite_material: ShaderMaterial = animated_sprite.material
onready var hit_sfx_player: AudioStreamPlayer2D = $HitSfxPlayer

export(PackedScene) var death_explosion

func _ready() -> void:
    stats.max_hp = max_hp
    stats.current_hp = max_hp
    stats.move_speed = speed
    stats.connect("die", self, "_on_Stats_die")
    nav_timer.connect("timeout", self, "_on_NavigationRefreshTimer_timeout")
    
func _physics_process(delta: float) -> void:
    if dying:
        return
        
    if not nav_agent.is_navigation_finished():
        var target_pos = nav_agent.get_next_location()
        var direction = global_transform.origin.direction_to(target_pos)
        velocity = direction * stats.move_speed
        velocity += get_knockback_velocity()
        move_and_slide(velocity)
    
    if animated_sprite.animation != "walk" and velocity.length() > 0:
        animated_sprite.animation = "walk"
    
    if animated_sprite.animation != "default" and velocity.length() == 0:
        animated_sprite.animation = "default"

func take_hit(damage_taken, knockback_direction, knockback_multiplier):
    hit_sfx_player.pitch_scale = rand_range(0.9, 1.1)
    hit_sfx_player.stream = hit_sfx[randi() % hit_sfx.size()]
    hit_sfx_player.play()
    knockback_velocity = knockback_direction * min(damage, 10) * speed * 5 * knockback_multiplier
    stats.take_hit(damage_taken)
    
    sprite_material.set_shader_param("redden", true)
    if stats.current_hp > 0:
        yield(get_tree().create_timer(0.15), "timeout")
        sprite_material.set_shader_param("redden", false)

func get_knockback_velocity() -> Vector2:
    knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
    return knockback_velocity

func _on_Stats_die() -> void:
    set_collision_layer_bit(3, false)
    dying = true
    animated_sprite.animation = "die"
    yield(animated_sprite, "animation_finished")
    animated_sprite.visible = false
    
    var explosion = death_explosion.instance()
    explosion.color = explode_color
    explosion.death_action = funcref(self, "explode")
    explosion.global_position = global_position
    explosion.scale *= explode_scale * sqrt(scale.length())

    get_tree().current_scene.call_deferred("add_child", explosion)



func _on_NavigationRefreshTimer_timeout() -> void:
    nav_agent.set_target_location(player.global_position)

func explode(bodies: Array) -> void:
    for body in bodies:
        if body.has_node("Stats"):
            death_explosion_effect(body)
    queue_free()
    
func death_explosion_effect(body) -> void:
    pass #Implement per enemy
