extends Enemy

func death_explosion_effect(body: KinematicBody2D) -> void:
    var stats: Stats = body.get_node("Stats")
    var heal = round(stats.max_hp * 0.3)
    stats.max_hp = round(stats.max_hp * 1.3)
    stats.current_hp += heal
    body.scale *= 1.3
