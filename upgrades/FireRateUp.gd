extends Upgrade

func apply_upgrade() -> void:
    player_stats.attack_speed_multiplier += 0.5
    player.equipped_weapon.update_rof()
