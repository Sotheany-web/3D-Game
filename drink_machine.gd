extends Node3D

# How often the machine dispenses drinks (seconds)
@export var dispense_interval := 5.0

# Path to the drink cup prefab
@export var drink_scene: PackedScene = preload("res://lemon_tea11/lemon_tea11.tscn")

# Internal state
var is_dispensing := false

func _ready():
	$Timer.wait_time = dispense_interval
	$Timer.autostart = true
	$Timer.one_shot = false
	$Timer.start()
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout() -> void:

	#if the cup queue to 3 the machine will stop make it 
	var cups = get_tree().get_nodes_in_group("cups")
	if cups.size() >= 3:
		return  # stop spawning if 3 cups already exist

# Start dispensing process
	if not is_dispensing:
		is_dispensing = true
		# Play pouring sound while the machine is "making" the cup
		$AudioStreamPlayer.play()

		# Use a one-shot timer to delay the actual spawn until after dispense_interval
		var spawn_timer := Timer.new()
		spawn_timer.wait_time = dispense_interval
		spawn_timer.one_shot = true
		spawn_timer.timeout.connect(_spawn_drink)
		add_child(spawn_timer)
		spawn_timer.start()

func _spawn_drink()-> void:
	var cups = get_tree().get_nodes_in_group("cups")
	var index = cups.size()  # 0, 1, or 2

	# Get the corresponding spawn marker
	var marker_name = "SpawnPoint" + str(index + 1)
	var marker = get_node(marker_name)   # shorthand for $SpawnPoint1, $SpawnPoint2, etc.

	if marker == null:
		return  # safety check

	# Spawn a new drink cup at the SpawnPoint, every cup will be at the origin position 
	var drink = drink_scene.instantiate() #let drink be the variable that contain the drink node
	drink.add_to_group("cups")   # <-- make sure cups are tracked
	
	#Place at the chosen marker
	drink.global_transform.origin = marker.global_transform.origin

	# Add the drink to the main scene (so it's free to be picked up), with this line the drink will be added to the scene and could be pick up 
	get_tree().current_scene.add_child(drink)

	# Reset state
	is_dispensing = false
