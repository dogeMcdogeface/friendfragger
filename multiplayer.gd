extends Node

@export var PORT = 4433


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var args = Array(OS.get_cmdline_args())
	multiplayer.server_relay = false
	if args.has("host"):
		begin_host.call_deferred()
	if args.has("join"):
		begin_join.call_deferred()
	pass # Replace with function body.


func begin_host():
	print("hosting")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	pass

func begin_join():
	print("joining")
	var txt : String =$Control/HBoxContainer/LineEdit_remote.text.strip_edges()
	if txt == "":
		txt = $Control/HBoxContainer/LineEdit_remote.placeholder_text.strip_edges()
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func start_game():
	print("Game Starting")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
