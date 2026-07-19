## Owns the lifecycle of presentation elements that block combat progression.
## Tracked Nodes release automatically when freed; reusable audio players release
## when playback finishes.
extends Node

const BLOCKING_GROUP: StringName = &"blocking_combat_presentation"

signal blocking_started(source: Node)

func _ready() -> void:
	Signals.combat_ended.connect(clear)
	Signals.run_ended.connect(clear)

func is_blocking() -> bool:
	return not get_tree().get_nodes_in_group(BLOCKING_GROUP).is_empty()

func track(node: Node) -> void:
	assert(node != null, "A blocking combat presentation requires a node")
	if node.is_in_group(BLOCKING_GROUP):
		return
	node.add_to_group(BLOCKING_GROUP)
	blocking_started.emit(node)

func release(node: Node) -> void:
	if is_instance_valid(node):
		node.remove_from_group(BLOCKING_GROUP)

func track_audio(player: AudioStreamPlayer) -> void:
	assert(player != null, "Blocking combat audio requires an AudioStreamPlayer")
	track(player)
	var release_callback: Callable = release.bind(player)
	if not player.finished.is_connected(release_callback):
		player.finished.connect(release_callback)

func clear() -> void:
	for node: Node in get_tree().get_nodes_in_group(BLOCKING_GROUP):
		node.remove_from_group(BLOCKING_GROUP)
