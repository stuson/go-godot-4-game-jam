extends Weapon

const BASE_DAMAGE = 8
const BASE_ATTACK_INTERVAL = 2.5

var fireball: Node2D
export(PackedScene) var Fireball

func _ready() -> void:
    base_damage = BASE_DAMAGE
    base_attack_interval = BASE_ATTACK_INTERVAL
    update_rof()

func make_attack() -> void:
    fireball = Fireball.instance()
    fireball.global_transform = global_transform
    fireball.damage = damage
    fireball.knockback_multiplier = player_stats.knockback_multiplier
    fireball.scale *= player_stats.attack_size_multiplier

    get_tree().current_scene.add_child(fireball)
