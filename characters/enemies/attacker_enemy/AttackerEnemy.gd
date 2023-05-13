extends Enemy

func death_explosion_effect(body: KinematicBody2D) -> void:
    var stats: Stats = body.get_node("Stats")
    stats.damage_multiplier += 1
