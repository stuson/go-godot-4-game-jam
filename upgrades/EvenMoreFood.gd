extends Upgrade

func apply_upgrade() -> void:
	player_stats.max_hp += 2
	player_stats.current_hp = player_stats.max_hp
	player_stats.emit_hp_change()
