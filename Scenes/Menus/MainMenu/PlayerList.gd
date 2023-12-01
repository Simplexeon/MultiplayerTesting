extends VBoxContainer
class_name LobbyPlayerList

# Component vars
@onready var tree : SceneTree = get_tree();

# File vars
@onready var player_info_file = preload("res://Scenes/Menus/MainMenu/PlayerLobbyInfo.tscn");


# Functions

func addPlayerInfo(player_name : String, color : Color, ready : bool) -> void:
	var PlayerInfoDisplay : Control = player_info_file.instantiate();
	add_child(PlayerInfoDisplay);
	PlayerInfoDisplay.initialize(player_name, color, ready);


func removePlayerInfo(player_name : String) -> void:
	var PlayerInfo : Control = getPlayerInfoFromName(player_name);
	if(PlayerInfo == null):
		return;
	
	PlayerInfo.queue_free();


func readyPlayer(player_name : String) -> void:
	var PlayerInfo : Control = getPlayerInfoFromName(player_name);
	if(PlayerInfo == null):
		return;
	
	PlayerInfo.readyUp();


func unreadyPlayer(player_name : String) -> void:
	var PlayerInfo : Control = getPlayerInfoFromName(player_name);
	if(PlayerInfo == null):
		return;
	
	PlayerInfo.unready();


func getPlayerInfoFromName(player_name : String) -> Control:
	var player_info_labels : Array[Node] = get_children();
	for player_label in player_info_labels:
		if(player_label.player_name == player_name):
			return player_label;
	
	return null;
