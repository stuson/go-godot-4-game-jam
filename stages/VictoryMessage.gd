extends CanvasLayer

export(Array, String) var rewards

func _unhandled_key_input(event: InputEventKey) -> void:
    if visible:
        if event.is_action_pressed("restart"):
            get_tree().paused = false
            get_tree().reload_current_scene()
        elif event.is_action_pressed("ui_cancel"):
            MainMenuMusic.play()
            get_tree().change_scene("res://ui/MainMenu.tscn")

func _on_SpawnManager_game_won() -> void:
    randomize()
    var reward = rewards[randi() % rewards.size()]
    $VBoxContainer/RewardBody.text = reward
    visible = true
