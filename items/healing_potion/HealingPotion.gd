extends Node2D

const potion = true
const healing = 30

func _on_Area2D_area_entered(area):
    var player = area.get_parent()
    player.stats.current_hp += healing
    queue_free()
