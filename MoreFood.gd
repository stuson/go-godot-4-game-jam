extends Button

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var player_stats: Stats = player.get_node("Stats")

signal upgrade_selected

func _on_MoreFood_pressed() -> void:
    player_stats.max_hp += 1
    player_stats.current_hp = player_stats.max_hp
    player_stats.emit_hp_change()
    
    emit_signal("upgrade_selected")
