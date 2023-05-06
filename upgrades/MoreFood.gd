extends Upgrade

func apply_upgrade():
	player_stats.max_hp += 1
	player_stats.current_hp = player_stats.max_hp
	player_stats.emit_hp_change()

