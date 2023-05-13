extends Weapon

const BASE_DAMAGE = 25
const BASE_ATTACK_INTERVAL = 0.8
const BASE_SCALING = 1.5

var swing: Node2D
export(PackedScene) var Swing

func _ready() -> void:
    base_damage = BASE_DAMAGE
    base_attack_interval = BASE_ATTACK_INTERVAL
    update_rof()

func make_attack(direction: Vector2, is_crit: bool) -> void:
    swing = Swing.instance()
    swing.damage = damage
    swing.knockback_multiplier = player_stats.knockback_multiplier
    swing.swing_travel = player_stats.swing_travel
    swing.is_crit = is_crit
    
    get_tree().current_scene.add_child(swing)
    
    swing.global_transform = global_transform
    swing.scale *= BASE_SCALING * player_stats.attack_size_multiplier
    swing.look_at(direction)
