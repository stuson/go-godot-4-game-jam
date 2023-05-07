extends Upgrade

func apply_upgrade():
    player_stats.crit_chance = min(player_stats.crit_chance + 0.1, 1)
