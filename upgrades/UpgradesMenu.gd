extends CanvasLayer

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var container = $UpgradesContainer
onready var animation_player: AnimationPlayer = $AnimationPlayer

var upgradePanelScene = preload("res://upgrades/Upgrade.tscn")

const NUM_UPGRADES = 3

signal upgrade_menu_finished

func _on_SpawnManager_wave_cleared() -> void:
    get_tree().paused = true
    var unused_upgrades = UpgradeList.upgrades.duplicate(true)
    for _i in range(0, NUM_UPGRADES):
        if unused_upgrades:
            randomize()
            var rarity = upgrade_rarity()
            var upgrade = unused_upgrades[rarity].pop_at(int(rand_range(0, unused_upgrades[rarity].size())))
            var upgradePanel = upgradePanelScene.instance()
            upgradePanel.upgrade_name = upgrade["title"]
            upgradePanel.upgrade_desc = upgrade["description"]
            upgradePanel.upgrades = upgrade["upgrades"]
            
            upgradePanel.connect("upgrade_selected", self, "_on_Upgrade_selected")
            container.add_child(upgradePanel)
            
            match rarity:
                "Uncommon": 
                    upgradePanel.name_tag.set("custom_colors/font_color", Color.green)
                    upgradePanel.desc_tag.set("custom_colors/font_color", Color.green)
                "Rare": 
                    upgradePanel.name_tag.set("custom_colors/font_color", Color.blue)
                    upgradePanel.desc_tag.set("custom_colors/font_color", Color.blue)
                    upgradePanel.name_tag.set("custom_colors/font_outline_modulate", Color.white)
                    upgradePanel.desc_tag.set("custom_colors/font_outline_modulate", Color.white)

    visible = true
    $ColorRect.visible = true
    animation_player.play("UpgradesTransition")

func _on_Upgrade_selected() -> void:
    for node in container.get_children():
        container.remove_child(node)
        
    get_tree().paused = false
    visible = false
    emit_signal("upgrade_menu_finished")
    
func upgrade_rarity():
    randomize()
    var chance = randf()
    if chance > 0.9:
        return "Rare"
    elif chance > 0.6:
        return "Uncommon"
    else:
        return "Common"

func allow_interact() -> void:
    $ColorRect.visible = false
