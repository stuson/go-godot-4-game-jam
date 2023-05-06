extends CanvasLayer

onready var hp_label = $HpLabel
onready var wave_label = $WaveInfoContainer/WaveLabel
onready var enemies_remaining_label = $WaveInfoContainer/EnemiesRemainingLabel
onready var player: Node2D = get_tree().get_nodes_in_group("Player")[0]
onready var spawn_manager: Node = get_tree().get_nodes_in_group("SpawnManager")[0]

func _ready() -> void:
    player.get_node("Stats").connect("hp_changed", self, "_on_Player_Stats_hp_changed")
    spawn_manager.connect("new_wave_spawned", self, "_on_SpawnManager_new_wave_spawned")
    spawn_manager.connect("enemies_to_kill_updated", self, "_on_SpawnManager_enemies_to_kill_updated")
        
func _on_Player_Stats_hp_changed(hp, max_hp) -> void:
    hp_label.text = "HP: %s/%s" % [hp, max_hp]

func _on_SpawnManager_new_wave_spawned(wave_idx, num_enemies) -> void:
    wave_label.text = "Wave %s" % (wave_idx + 1)
    enemies_remaining_label.text = "Enemies Remaining: %s" % num_enemies

func _on_SpawnManager_enemies_to_kill_updated(enemies_to_kill) -> void:
    if enemies_to_kill <= 0:
        enemies_remaining_label.text = "More..."
    else:
        enemies_remaining_label.text = "Enemies Remaining: %s" % enemies_to_kill
