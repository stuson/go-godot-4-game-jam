extends Button


func _unhandled_key_input(event: InputEventKey) -> void:
    if event.is_action_pressed("ui_cancel"):
        go_to_main_menu()
    
func _on_MainMenuButton_pressed() -> void:
    go_to_main_menu()
    
func go_to_main_menu() -> void:
    get_tree().change_scene("res://ui/MainMenu.tscn")
    
