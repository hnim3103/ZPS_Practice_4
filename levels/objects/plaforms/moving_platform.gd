extends AnimatableBody3D

@export var offset := Vector3(0, 4, 0)

@export var speed := 2.0

@export var acceleration := 4.0

@export var wait_time := 1.0

## On: the platform stays at each end until the fox stands on it and presses interact.
@export var on_interact := false

var _start: Vector3
var _going_out := true
var _wait := 0.0
var _velocity := 0.0
var _parked := false

func _ready() -> void:
	_start = position
	if on_interact:
		_parked = true
		_add_interactive_area()

func _physics_process(delta: float) -> void:
	if _parked:
		return
	if _wait > 0.0:
		_wait -= delta
		return

	var target:= _start + offset if _going_out else _start
	var desired := minf(speed, sqrt(2.0 * acceleration * position.distance_to(target)))
	_velocity = move_toward(_velocity, desired, acceleration * delta)
	position = position.move_toward(target, _velocity * delta)

	if position.is_equal_approx(target):
		_going_out = not _going_out
		_wait = wait_time
		_velocity = 0.0
		_parked = on_interact

## A zone just above the deck, as wide as the platform: only a fox standing on it can start it.
func _add_interactive_area() -> void:
	var deck := ($CollisionShape3D.shape as BoxShape3D).size
	var box := BoxShape3D.new()
	box.size = Vector3(deck.x, 1.0, deck.z)
	var shape := CollisionShape3D.new()
	shape.shape = box
	shape.position.y = deck.y / 2.0 + 0.5
	var area := InteractiveArea3D.new()
	area.add_child(shape)
	area.interacted.connect(func() -> void: _parked = false)
	add_child(area)
