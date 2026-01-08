extends Node3D

@export var cook_interval := 5.0  # time to cook rice
@export var rice_scene: PackedScene = preload("res://rice.tscn")  # cooked rice prefab

var is_cooking := false

func _ready():
	$Timer.wait_time = cook_interval
	$Timer.autostart = true
	$Timer.one_shot = false
	$Timer.start()
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout() -> void:
	var plates = get_tree().get_nodes_in_group("plates")
	if plates.size() >= 3:
		return  # stop cooking if 3 plates already exist

	if not is_cooking:
		is_cooking = true
		if $AudioStreamPlayer:
			$AudioStreamPlayer.play()

		var cook_timer := Timer.new()
		cook_timer.wait_time = cook_interval
		cook_timer.one_shot = true
		cook_timer.timeout.connect(_spawn_rice)
		add_child(cook_timer)
		cook_timer.start()

func _spawn_rice() -> void:
	var plates = get_tree().get_nodes_in_group("plates")
	var index = plates.size()  # 0, 1, or 2

	var marker_name = "SpawnPoint" + str(index + 1)
	var marker = get_node(marker_name)

	if marker == null:
		push_warning("Missing spawn marker: " + marker_name)
		is_cooking = false
		return

	var rice = rice_scene.instantiate()
	rice.add_to_group("plates")
	rice.global_transform.origin = marker.global_transform.origin
	get_tree().current_scene.add_child(rice)

	is_cooking = false
