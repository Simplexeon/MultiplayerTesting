extends Node2D

# Export vars
@export var IpParam : String;
@export_range(0, 66666) var PortParam : int;

# Object Vars
var players : Array[Classes.PlayerInfo] = [];
var colors : Array[Color] = [Color.RED, Color.WHITE, Color.BLUE, Color.GREEN, Color.ORANGE, Color.CYAN, Color.YELLOW];
var next_color : int = 0; # Index of the next color in colors, will loop when max colors reached

# Component Vars
@onready var tree : SceneTree = get_tree();

# File Vars
@onready var player_file : PackedScene = preload("res://Scenes/Actors/Player/player.tscn");


# Processes

func _ready() -> void:
	
	# Randomize colors
	colors.shuffle();
	
	#region Multiplayer signal connections
	multiplayer.peer_connected.connect(_on_playerConnected);
	multiplayer.peer_disconnected.connect(_on_playerDisconnected);
	multiplayer.connected_to_server.connect(_on_connectedToServer);
	multiplayer.connection_failed.connect(_on_connectionFailed);
	multiplayer.server_disconnected.connect(_on_serverDisconnected);
	#endregion
	


#region Connection Signals

func _on_playerConnected(id : int) -> void:
	
	#region Server stuff
	
	if(multiplayer.is_server()):
		updateLobby(id);
	
	#endregion


func _on_playerDisconnected(id : int) -> void:
	players.erase(id);


func _on_connectedToServer() -> void:
	pass


func _on_connectionFailed() -> void:
	pass


func _on_serverDisconnected() -> void:
	pass

#endregion


@rpc("authority", "reliable", "call_remote")
func _on_receiveLobbyUpdate(player_id : int, player_color : String) -> void:
	var new_player_info : Classes.PlayerInfo = Classes.PlayerInfo.new();
	new_player_info.id = player_id;
	new_player_info.color = Color(player_color);
	players.append(new_player_info);
	var PlayerListDisplay : LobbyPlayerList = tree.get_first_node_in_group("GLobbyPlayerList");
	PlayerListDisplay.addPlayerInfo(str(player_id), Color(player_color));


# Functions

func startGame() -> void:
	
	#region Spawn the players
	var spawn_points : Array[Node] = tree.get_nodes_in_group("GSpawnPoints");
	spawn_points.shuffle();
	var current_spawn_point : int = 0;
	for player in players:
		var PlayerInst : Player = player_file.instantiate();
		tree.current_scene.add_child(PlayerInst);
		PlayerInst.initialize(spawn_points[current_spawn_point].global_position, player.color);
		player.node = PlayerInst;
		current_spawn_point += 1;
	#endregion


func startServer() -> void:
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new();
	var error : Error = peer.create_server(PortParam);
	if(error):
		return;
	multiplayer.multiplayer_peer = peer;


func joinGame() -> bool:
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new();
	var error : Error = peer.create_client(IpParam, PortParam);
	if(error):
		return false;
	multiplayer.multiplayer_peer = peer;
	return true;


func updateLobby(id : int) -> void:
	for player in players:
		_on_receiveLobbyUpdate.rpc_id(id, player.id, player.color.to_html());
	var new_player_info : Classes.PlayerInfo = Classes.PlayerInfo.new();
	new_player_info.id = id;
	new_player_info.color = getNewColor();
	players.append(new_player_info);
	_on_receiveLobbyUpdate.rpc(new_player_info.id, new_player_info.color.to_html());
	var PlayerListDisplay : LobbyPlayerList = tree.get_first_node_in_group("GLobbyPlayerList");
	PlayerListDisplay.addPlayerInfo(str(new_player_info.id), new_player_info.color);


func getNewColor() -> Color :
	var gotten_color : Color = colors[next_color];
	next_color += 1;
	return gotten_color;


