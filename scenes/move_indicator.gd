extends Node2D

func setup(from_pos: Vector2, to_pos: Vector2, text: String):
    position = (from_pos + to_pos) / 2
    $Label.text = text
    
    var diff = to_pos - from_pos
    $Arrow.flip_h = (diff.x < 0)

    # Rotate arrow to point from → to
    var angle = (to_pos - from_pos).angle()
    rotation = angle if diff.x >= 0 else angle - PI
    
    $Arrow.modulate = Color.LIGHT_GREEN
    $Label.modulate = Color.LIGHT_GREEN
