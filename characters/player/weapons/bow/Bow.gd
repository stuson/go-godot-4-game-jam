extends Weapon

const BASE_DAMAGE = 5

var arrow: Node2D
export(PackedScene) var Projectile

func make_attack() -> void:
    arrow = Projectile.instance()
    arrow.global_transform = global_transform
    arrow.damage = BASE_DAMAGE
    get_tree().current_scene.add_child(arrow)

