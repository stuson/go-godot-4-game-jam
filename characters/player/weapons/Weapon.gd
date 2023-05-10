extends Node2D
class_name Weapon

var can_attack = true
var damage
var base_damage
var base_attack_interval

onready var rof_timer = $RofTimer
onready var player = get_parent()
onready var player_stats: Stats = player.stats

func attack(direction: Vector2) -> void:
    if can_attack:
        can_attack = false
        
        damage = base_damage * player_stats.damage_multiplier
        
        randomize()
        if rand_range(0, 1) < player_stats.crit_chance:
            damage *= player_stats.crit_multiplier
            
        make_attack(direction)
        
        rof_timer.start()
        
func update_rof() -> void:
    rof_timer.wait_time = base_attack_interval / player_stats.attack_speed_multiplier
        
func make_attack(direction: Vector2) -> void:
    pass

func _on_RofTimer_timeout() -> void:
    can_attack = true
