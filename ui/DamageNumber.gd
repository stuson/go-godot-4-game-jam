extends Position2D

var amount
var velocity = Vector2.ZERO
var max_scale = Vector2(1, 1)
var color = Color.white

onready var tween: Tween = $Tween
onready var label: Label = $Label

const MAX_H_MOVEMENT = 60
const V_MOVEMENT = -50

func _ready() -> void:
    label.text = str(amount)
    label.set("custom_colors/font_color", color)
        
    randomize()
    var hor_movement = randi() % (MAX_H_MOVEMENT * 2 + 1) - MAX_H_MOVEMENT
    velocity = Vector2(hor_movement, V_MOVEMENT)
    
    tween.interpolate_property(self, "scale", scale, max_scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    tween.interpolate_property(self, "scale", max_scale, Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
    tween.start()

func _process(delta: float) -> void:
    position += velocity * delta

func _on_Tween_tween_all_completed() -> void:
    queue_free()
