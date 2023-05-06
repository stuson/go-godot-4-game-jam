extends Button
class_name Upgrade

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var player_stats: Stats = player.get_node("Stats")

signal upgrade_selected

func _ready() -> void:
    connect("pressed", self, "_on_Button_pressed")

func apply_upgrade() -> void:
    pass

func _on_Button_pressed() -> void:
    apply_upgrade()
    emit_signal("upgrade_selected")
