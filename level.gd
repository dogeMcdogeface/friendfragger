extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_use_accumulated_input(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var frame_deltas: Array = []
var time_accumulator: float = 0.0

func _process(delta: float) -> void:
	frame_deltas.append(delta)
	time_accumulator += delta

	if time_accumulator >= 1.0:
		# Calculate average FPS
		var avg_delta = 0.0
		for d in frame_deltas:
			avg_delta += d
		avg_delta /= frame_deltas.size()
		var average_fps = 1.0 / avg_delta

		# Sort deltas to find slowest 1%
		var sorted_deltas = frame_deltas.duplicate()
		sorted_deltas.sort()
		var count_1_percent = max(1, int(sorted_deltas.size() * 0.01))
		var slowest_deltas = sorted_deltas.slice(-count_1_percent, sorted_deltas.size())
		var avg_slowest_delta = 0.0
		for d in slowest_deltas:
			avg_slowest_delta += d
		avg_slowest_delta /= slowest_deltas.size()
		var low_1_percent_fps = 1.0 / avg_slowest_delta

		# Print stats
		print("Average FPS: %.2f, Low 1%% FPS: %.2f" % [average_fps, low_1_percent_fps])

		# Reset for next second
		frame_deltas.clear()
		time_accumulator = 0.0


func _unhandled_input(event)-> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_abscond"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("ui_skip_debug"):
		$Animation_Env.speed_scale = 1000
	if event.is_action_pressed("ui_pause_debug"):
		$Animation_Env.speed_scale = 0
