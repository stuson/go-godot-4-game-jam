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
var weapons = []
var weapon_idx = 0

onready var on_hit_invincibility_timer = $OnHitInvicibilityTimer
onready var blink_timer = $BlinkTimer
onready var roll_timer = $RollCooldown
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var sprite_material: ShaderMaterial = $AnimatedSprite.material
onready var stats: Stats = $Stats
onready var footstep_sfx: AudioStreamPlayer = $FootstepSfx
onready var hit_sfx: AudioStreamPlayer = $HitSfx

signal player_died
signal weapon_cycled

export(Array, PackedScene) var StartingWeapons

func _ready() -> void:
    for StartingWeapon in StartingWeapons:
        var weapon = StartingWeapon.instance()
        weapons.append(weapon)
        add_child(weapon)
    equipped_weapon = weapons[0]
    
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
        
    # Switch weapons
    if Input.is_action_just_pressed("cycle_weapon"):
        cycle_weapon()
    if Input.is_action_just_pressed("select_weapon_1"):
        select_weapon(0)
    if Input.is_action_just_pressed("select_weapon_2"):
        select_weapon(1)
    
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

func cycle_weapon() -> void:
    var idx = (weapon_idx + 1) % weapons.size()
    select_weapon(idx)
    
func select_weapon(idx) -> void:
    weapon_idx = idx
    equipped_weapon = weapons[weapon_idx]
    emit_signal("weapon_cycled", weapon_idx)

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
        hit_sfx.play()
        $Stats.take_hit(damage)
        var knockback_direction = (global_position - enemy_pos).normalized()
        knockback_velocity = knockback_direction * min(damage, 10) * 100
        
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

func _on_FootstepTimer_timeout() -> void:
    if velocity:
        randomize()
        footstep_sfx.pitch_scale = rand_range(0.8, 1.2)
        footstep_sfx.play()
