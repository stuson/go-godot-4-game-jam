extends Button
class_name Upgrade

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var player_stats: Stats = player.get_node("Stats")
onready var name_tag = $VBoxContainer/UpgradeName
onready var desc_tag = $VBoxContainer/UpgradeDescription

var upgrade_name: String
var upgrade_desc: String
var upgrades: Array

signal upgrade_selected

func _ready() -> void:
    connect("pressed", self, "_on_Button_pressed")
    name_tag.text = upgrade_name
    desc_tag.text = upgrade_desc

func apply_upgrade() -> void:
    for upgrade in upgrades:
        match upgrade["operand"]:
            "+":
                player_stats.set(
                    upgrade["property"], 
                    player_stats.get(upgrade["property"]) + upgrade["modifier"]
                )
            "-":
                player_stats.set(
                    upgrade["property"], 
                    player_stats.get(upgrade["property"]) - upgrade["modifier"]
                )
            "*":
                player_stats.set(
                    upgrade["property"], 
                    player_stats.get(upgrade["property"]) * upgrade["modifier"]
                )
            "/":
                player_stats.set(
                    upgrade["property"], 
                    player_stats.get(upgrade["property"]) / upgrade["modifier"]
                )

func _on_Button_pressed() -> void:
    apply_upgrade()
    emit_signal("upgrade_selected")
