extends Camera2D

onready var player: Node2D = get_tree().get_nodes_in_group("Player")[0]

func _process(delta: float) -> void:
    global_position = player.global_position
