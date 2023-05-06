extends CanvasLayer

onready var player = get_tree().get_nodes_in_group("Player")[0]

signal upgrade_selected

func _on_SpawnManager_wave_cleared() -> void:
    get_tree().paused = true
    visible = true

func _on_Upgrade_selected() -> void:
    get_tree().paused = false
    visible = false
    emit_signal("upgrade_selected")
