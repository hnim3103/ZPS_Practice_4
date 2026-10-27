extends Node3D

## This door's name is a spawn point. A door in another stage leads here
## with target_door = id.
@export var id := ""
@export_file("*.tscn") var target_stage := ""
@export var target_door := ""
## A locked door opens only once GameManager has the flag `unlock_flag`
## (see unlock_door()).
@export var locked := false
@export var unlock_flag := ""
## On: the door stays shut while any enemy of the stage is still alive.
@export var unlock_when_cleared := false

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
    add_to_group("spawn_points")
    $InteractiveArea3D.interacted.connect(_on_interacted)
    var arriving := id != "" and GameManager.pending_spawn == id
    _sprite.play("closing" if arriving else "idle")

func is_locked() -> bool:
    if unlock_when_cleared and _enemies_left() > 0:
        return true
    return locked and not GameManager.is_door_unlocked(unlock_flag)

func _enemies_left() -> int:
    var count := 0
    for enemy: Node in get_tree().get_nodes_in_group(EnemyCharacter.GROUP):
        if not enemy.is_queued_for_deletion():
            count += 1
    return count

func _on_interacted() -> void:
    if is_locked():
        _tell_locked()
        return
    if _sprite.animation == "opening":
        return    # already opening — a second press changes nothing
    _sprite.play("opening")
    await _sprite.animation_finished
    if target_stage == "":
        # Same stage: no reload, just move the fox to the other door behind a fade.
        await Transition.fade_out()
        GameManager.current_stage.place_player_at(target_door)
        _sprite.play("idle")
        Transition.fade_in()
        return
    GameManager.change_stage(target_stage, target_door)

func _tell_locked() -> void:
    for body: Node3D in $InteractiveArea3D.get_overlapping_bodies():
        if body is Player:
            var timeline := "door_enemies" if unlock_when_cleared and _enemies_left() > 0 else "door_locked"
            Conversation.play(timeline, body)
            return