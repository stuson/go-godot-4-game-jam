extends CanvasLayer

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var container = $UpgradesContainer

export(Array, PackedScene) var possible_upgrades

const NUM_UPGRADES = 3

signal upgrade_selected

func _on_SpawnManager_wave_cleared() -> void:
    get_tree().paused = true
    var unused_upgrades = possible_upgrades.duplicate()
    for i in range(0, NUM_UPGRADES):
        if unused_upgrades:
            randomize()
            var upgrade = unused_upgrades.pop_at(int(rand_range(0, unused_upgrades.size()))).instance()
            upgrade.connect("upgrade_selected", self, "_on_Upgrade_selected")
            container.add_child(upgrade)
        
    visible = true

func _on_Upgrade_selected() -> void:
    for node in container.get_children():
        container.remove_child(node)
        
    get_tree().paused = false
    visible = false
    emit_signal("upgrade_selected")
