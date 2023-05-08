extends Node

var upgrades

func _ready():
    var upgrade_file = File.new()
    upgrade_file.open("res://data/Upgrades.json", File.READ)
    var upgrade_json = JSON.parse(upgrade_file.get_as_text())
    upgrade_file.close()
    upgrades = upgrade_json.result
