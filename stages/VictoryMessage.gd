extends CanvasLayer

export(Array, String) var rewards

func _unhandled_key_input(event: InputEventKey) -> void:
    if visible and event.is_action_pressed("restart"):
        get_tree().paused = false
        get_tree().reload_current_scene()

func _on_SpawnManager_game_won() -> void:
    randomize()
    var reward = rewards[randi() % rewards.size()]
    $VBoxContainer/RewardBody.text = reward
    visible = true
