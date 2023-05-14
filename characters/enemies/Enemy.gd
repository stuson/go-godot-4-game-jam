extends KinematicBody2D
class_name Enemy

#Base enemy stats to be overridden by specific enemy types
export var damage = 1
export var max_hp = 5
export var speed = 100
export(Color) var explode_color
export(float) var explode_scale = 1.0
export(Array, AudioStream) var hit_sfx
export(String, "hp", "attack", "speed", "duplicate") var buff_icon

var velocity: Vector2
var knockback_velocity = Vector2.ZERO
var dying = false
var duplicatable = true
var basic = false

onready var player: KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var stats = $Stats
onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
onready var nav_timer = $NavigationRefreshTimer
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var sprite_material: ShaderMaterial = animated_sprite.material
onready var hit_sfx_player: AudioStreamPlayer2D = $HitSfxPlayer
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var hitbox: Area2D = $Area2D
onready var enemy_type: PackedScene = load(filename)

export(PackedScene) var death_explosion

signal duplicated

func _ready() -> void:
    stats.initialize_hp(max_hp, max_hp)
    stats.move_speed = speed
    stats.connect("die", self, "_on_Stats_die")
    nav_timer.connect("timeout", self, "_on_NavigationRefreshTimer_timeout")
    nav_agent.connect("velocity_computed", self, "_on_velocity_computed")
    
func _physics_process(delta: float) -> void:
    if dying:
        return
        
    if not nav_agent.is_navigation_finished():
        var target_pos = nav_agent.get_next_location()
        var direction = global_transform.origin.direction_to(target_pos)
        velocity = (direction * stats.move_speed).limit_length(1000)
        velocity += get_knockback_velocity()
        nav_agent.set_velocity(velocity)
    
    var closest_pos = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position)
    if closest_pos != global_position:
        global_position = closest_pos
    
    if animated_sprite.animation != "walk" and velocity.length() > 0:
        animated_sprite.animation = "walk"
    
    if animated_sprite.animation != "default" and velocity.length() == 0:
        animated_sprite.animation = "default"

func _on_velocity_computed(safe_velocity):
    move_and_slide(safe_velocity)

func take_hit(damage_taken, knockback_direction, knockback_multiplier, is_crit = false):
    hit_sfx_player.pitch_scale = rand_range(0.9, 1.1)
    hit_sfx_player.stream = hit_sfx[randi() % hit_sfx.size()]
    hit_sfx_player.play()
    knockback_velocity = knockback_direction * min(damage, 10) * speed * knockback_multiplier
    stats.take_hit(damage_taken, is_crit)
    
    sprite_material.set_shader_param("redden", true)
    if stats.current_hp > 0:
        yield(get_tree().create_timer(0.15), "timeout")
        sprite_material.set_shader_param("redden", false)
    
func get_knockback_velocity() -> Vector2:
    knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
    return knockback_velocity

func play_explosion_effect_animation(color: Color) -> void:
    sprite_material.set_shader_param("buff_color", color)
    animation_player.play("explosion_effect")

func _on_Stats_die() -> void:
    set_collision_layer_bit(2, false)
    set_collision_mask_bit(2, false)
    hitbox.set_collision_layer_bit(2, false)
    hitbox.set_collision_mask_bit(1, false)
    dying = true
    animated_sprite.animation = "die"
    yield(animated_sprite, "animation_finished")
    animated_sprite.visible = false
    player.get_node("Stats").current_hp += player.get_node("Stats").life_on_kill
    
    if not basic:
        var explosion = death_explosion.instance()
        explosion.color = explode_color
        explosion.death_action = funcref(self, "explode")
        explosion.global_position = global_position
        explosion.scale *= explode_scale * sqrt(scale.length())
        explosion.icon = buff_icon

        get_tree().current_scene.call_deferred("add_child", explosion)
    else:
        queue_free()
        
func _on_NavigationRefreshTimer_timeout() -> void:
    nav_agent.set_target_location(player.global_position)

func explode(bodies: Array) -> void:
    for body in bodies:
        if body.has_node("Stats"):
            death_explosion_effect(body)
            if body.basic:
                death_explosion_effect(body)
                
    queue_free()
    
func death_explosion_effect(body) -> void:
    pass #Implement per enemy

func clone() -> Enemy:
    var dupe = enemy_type.instance()
    dupe.scale = scale
    var dupe_stats = dupe.get_node("Stats")
    dupe_stats.update(stats)
    emit_signal("duplicated", dupe)
    return dupe
