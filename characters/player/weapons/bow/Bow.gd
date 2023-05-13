extends Weapon

const BASE_DAMAGE = 70
const BASE_ATTACK_INTERVAL = 1.4

var arrow: Node2D
export(PackedScene) var Projectile

func _ready() -> void:
    base_damage = BASE_DAMAGE
    base_attack_interval = BASE_ATTACK_INTERVAL
    update_rof()

func make_attack(direction: Vector2, is_crit: bool) -> void:
    arrow = Projectile.instance()
    arrow.global_transform = global_transform
    arrow.damage = damage
    arrow.knockback_multiplier = player_stats.knockback_multiplier
    arrow.scale *= player_stats.attack_size_multiplier
    arrow.chain = player_stats.chain
    arrow.is_crit = is_crit

    get_tree().current_scene.add_child(arrow)
    arrow.look_at(direction)
    arrow.velocity = arrow.transform.x.normalized() * arrow.projectile_speed
