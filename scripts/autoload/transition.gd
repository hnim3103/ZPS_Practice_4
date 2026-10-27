extends CanvasLayer

## A black screen over everything: fade_out() before the fox is moved or a stage changes,
## fade_in() once the fox is in place.

var _rect := ColorRect.new()


func _ready() -> void:
	layer = 100    # above the HUD and the Dialogic box
	_rect.color = Color.BLACK
	_rect.modulate.a = 0.0
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)


func fade_out(time := 0.3) -> void:
	await create_tween().tween_property(_rect, "modulate:a", 1.0, time).finished


func fade_in(time := 0.3) -> void:
	await create_tween().tween_property(_rect, "modulate:a", 0.0, time).finished
