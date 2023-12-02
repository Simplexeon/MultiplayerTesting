extends Node2D

# Export vars
@export var IpParam : String;
@export_range(0, 66666) var PortParam : int;

# Object Vars
var connection_ip : String = IpParam;
var connection_port : int = PortParam;
var upnp : UPNP = null;
var players : Array[Classes.PlayerInfo] = [];
var colors : Array[Color] = [Color.RED, Color.WHITE, Color.BLUE, Color.GREEN, Color.ORANGE, Color.CYAN, Color.YELLOW];
var next_color : int = 0; # Index of the next color in colors, will loop when max colors reached

# Component Vars
@onready var ServerQueryTimer : Timer = $ServerQueryTimer;
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
	


func _on_server_query_timer_timeout() -> void:
	queryUPNP();


func _exit_tree() -> void:
	if(upnp != null):
		upnp.delete_port_mapping(connection_port, "UDP");
		upnp.delete_port_mapping(connection_port, "TCP");

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
func _on_receiveLobbyUpdate(player_id : int, player_color : String, player_ready : bool) -> void:
	var new_player_info : Classes.PlayerInfo = Classes.PlayerInfo.new();
	new_player_info.id = player_id;
	new_player_info.color = Color(player_color);
	players.append(new_player_info);
	var PlayerListDisplay : LobbyPlayerList = tree.get_first_node_in_group("GLobbyPlayerList");
	PlayerListDisplay.addPlayerInfo(str(player_id), Color(player_color), player_ready);


@rpc("any_peer", "reliable", "call_local")
func _on_playerReady(player_id : int) -> void:
	var player_info : Classes.PlayerInfo = getPlayerFromId(player_id);
	if(player_info == null):
		return;
	player_info.ready = !player_info.ready;
	var PlayerListDisplay : LobbyPlayerList = tree.get_first_node_in_group("GLobbyPlayerList");
	if(player_info.ready):
		PlayerListDisplay.readyPlayer(str(player_id));
	else:
		PlayerListDisplay.unreadyPlayer(str(player_id));



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
	portForward();
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new();
	var error : Error = peer.create_server(connection_port);
	if(error):
		return;
	multiplayer.multiplayer_peer = peer;


func portForward() -> void:
	upnp = UPNP.new();
	var discover_result = upnp.discover();
	
	if(discover_result != UPNP.UPNP_RESULT_SUCCESS):
		return;
	
	print(upnp.get_device_count());
	
	if(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway()):
		var map_result_udp : int = upnp.add_port_mapping(connection_port, 0, "godot_multiplayer_udp", "UDP");
		var map_result_tcp : int = upnp.add_port_mapping(connection_port, 0, "godot_multiplayer_tcp", "TCP");
		while(map_result_udp == UPNP.UPNP_RESULT_CONFLICT_WITH_OTHER_MAPPING):
			connection_port += 1;
			if(connection_port - PortParam > 30):
				return;
			map_result_udp = upnp.add_port_mapping(connection_port, 0, "godot_multiplayer_udp", "UDP");
			map_result_tcp = upnp.add_port_mapping(connection_port, 0, "godot_multiplayer_tcp", "TCP");
		
		connection_ip = upnp.query_external_address();
		print(connection_port);
		print(connection_ip);


func queryUPNP() -> void:
	if(upnp == null):
		return;
	
	var map_result_udp : int = upnp.add_port_mapping(connection_port, 0, "godot_multiplayer_udp", "UDP");
	var map_result_tcp : int = upnp.add_port_mapping(connection_port, 0, "godot_multiplayer_tcp", "TCP");
	
	connection_ip = upnp.query_external_address();
	ServerQueryTimer.start();


func joinGame() -> bool:
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new();
	var error : Error = peer.create_client(IpParam, PortParam);
	if(error):
		return false;
	multiplayer.multiplayer_peer = peer;
	return true;


func updateLobby(id : int) -> void:
	for player in players:
		_on_receiveLobbyUpdate.rpc_id(id, player.id, player.color.to_html(), player.ready);
	var new_player_info : Classes.PlayerInfo = Classes.PlayerInfo.new();
	new_player_info.id = id;
	new_player_info.color = getNewColor();
	players.append(new_player_info);
	_on_receiveLobbyUpdate.rpc(new_player_info.id, new_player_info.color.to_html(), false);
	var PlayerListDisplay : LobbyPlayerList = tree.get_first_node_in_group("GLobbyPlayerList");
	PlayerListDisplay.addPlayerInfo(str(new_player_info.id), new_player_info.color, false);


func toggleReady() -> void:
	_on_playerReady.rpc(multiplayer.get_unique_id());


func getPlayerFromId(player_id : int) -> Classes.PlayerInfo:
	var i : int = 0;
	while(i < players.size()):
		if(players[i].id == player_id):
			return players[i];
		i += 1;
	return null;


func getNewColor() -> Color :
	var gotten_color : Color = colors[next_color];
	next_color += 1;
	return gotten_color;


