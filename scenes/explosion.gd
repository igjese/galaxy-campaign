extends Node2D

@onready var inner = $Inner
@onready var outer = $Outer

func _ready():
    inner.modulate = Color(1, 1, 0, 0)   # yellow, invisible
    outer.modulate = Color(1, 0.5, 0, 0) # orange, invisible
    inner.scale = Vector2(0.2, 0.2)
    outer.scale = Vector2(0.2, 0.2)
    
    var tween = create_tween()

    # Pop in
    tween.tween_property(inner, "modulate", Color(1, 1, 0, 1), 0.05)
    tween.parallel().tween_property(outer, "modulate", Color(1, 0.5, 0, 1), 0.05)
    tween.parallel().tween_property(inner, "scale", Vector2(1.0, 1.0), 0.1)
    tween.parallel().tween_property(outer, "scale", Vector2(1.4, 1.4), 0.1)

    # Fade out
    tween.tween_property(inner, "modulate", Color(1, 1, 0, 0), 0.2)
    tween.parallel().tween_property(outer, "modulate", Color(1, 0.5, 0, 0), 0.2)
    tween.parallel().tween_property(inner, "scale", Vector2(1.6, 1.6), 0.2)
    tween.parallel().tween_property(outer, "scale", Vector2(2.0, 2.0), 0.2)

    tween.tween_callback(queue_free)
