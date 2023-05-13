extends KinematicBody2D

var direction: Vector2
var velocity = Vector2.ZERO
var equipped_weapon
var knockback_velocity = Vector2.ZERO
var invincible = false
var rolling = false
var can_roll = true
var roll_velocity = Vector2.ZERO
var apply_blink_opacity = false
var is_looking_right = true

onready var on_hit_invincibility_timer = $OnHitInvicibilityTimer
onready var blink_timer = $BlinkTimer
onready var roll_timer = $RollCooldown
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var sprite_material: ShaderMaterial = $AnimatedSprite.material
onready var stats: Stats = $Stats

signal player_died

export(PackedScene) var StartingWeapon

func _ready() -> void:
    equipped_weapon = StartingWeapon.instance()
    add_child(equipped_weapon)
    
func _physics_process(delta: float) -> void:
    # Move
    direction = Vector2.ZERO    
    if Input.is_action_pressed("move_right"):
        direction.x += 1
    if Input.is_action_pressed("move_left"):
        direction.x -= 1
    if Input.is_action_pressed("move_up"):
        direction.y -= 1
    if Input.is_action_pressed("move_down"):
        direction.y += 1
    
    # Roll
    if can_roll and not rolling and Input.is_action_just_pressed("roll"):
        start_roll()
    
    if rolling:
        velocity = roll_velocity
    else:
        velocity = direction.normalized() * stats.move_speed
        velocity += get_knockback(delta)
        
        # Look
        var vp = get_viewport()
        var mouse_pos = vp.get_mouse_position()
        if mouse_pos.x >= vp.size.x / 2:
            is_looking_right = true
        else:
            is_looking_right = false
            
        var animation_name = "walk" if direction else "default"
        animation_name += "_r" if is_looking_right else "_l"
        if animated_sprite.animation != animation_name:
            animated_sprite.animation = animation_name
                    
        # Attack
        if Input.is_action_pressed("attack"):
            equipped_weapon.attack(get_global_mouse_position())
    move_and_slide(velocity)

func start_roll():
    can_roll = false
    rolling = true
    if direction == Vector2.ZERO:
        direction = get_global_mouse_position() - global_position
    animated_sprite.animation = "roll_r" if direction.x >= 0 else "roll_l"
    roll_velocity = direction.normalized() * stats.move_speed * 1.7
    invincible = true

func get_knockback(delta) -> Vector2:
    knockback_velocity = lerp(knockback_velocity, Vector2.ZERO, 0.2)
    return knockback_velocity

func take_hit(damage, enemy_pos):
    if not invincible:
        $Stats.take_hit(damage)
        var knockback_direction = (global_position - enemy_pos).normalized()
        knockback_velocity = knockback_direction * min(damage, 10) * 1000
        
        start_invincibility()
        
        sprite_material.set_shader_param("whiten", true)
        yield(get_tree().create_timer(0.15), "timeout")
        sprite_material.set_shader_param("whiten", false)
        
func start_invincibility() -> void:
    invincible = true
    on_hit_invincibility_timer.start()
    blink_timer.start()

func end_invincibility() -> void:
    if rolling:
        return
        
    blink_timer.stop()
    apply_blink_opacity = false
    sprite_material.set_shader_param("apply_blink_opacity", apply_blink_opacity)
    invincible = false
    var enemy_overlaps = $HurtBox.get_overlapping_areas()
    if enemy_overlaps:
        var enemy = enemy_overlaps[0].get_parent()
        take_hit(enemy.damage, enemy.global_position)
   
func _on_Stats_die() -> void:
    emit_signal("player_died")
    get_tree().paused = true

func _on_OnHitInvicibilityTimer_timeout() -> void:
    end_invincibility()

func _on_HurtBox_area_entered(area: Area2D) -> void:
    var enemy = area.get_parent()
    take_hit(enemy.damage * enemy.stats.damage_multiplier, enemy.global_position)

func _on_BlinkTimer_timeout() -> void:
    apply_blink_opacity = !apply_blink_opacity
    sprite_material.set_shader_param("apply_blink_opacity", apply_blink_opacity)


func _on_AnimatedSprite_animation_finished() -> void:
    if animated_sprite.animation in ["roll_l", "roll_r"]:
        rolling = false
        end_invincibility()
        roll_timer.start()

func _on_RollCooldown_timeout() -> void:
    can_roll = true
