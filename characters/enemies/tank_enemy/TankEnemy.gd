extends Enemy

func death_explosion_effect(body: KinematicBody2D) -> void:
    var stats: Stats = body.get_node("Stats")
    var heal = round(body.max_hp * 0.3)
    stats.max_hp = round(body.max_hp * 1.3)
    stats.current_hp += heal
    body.scale += Vector2(0.3, 0.3)
