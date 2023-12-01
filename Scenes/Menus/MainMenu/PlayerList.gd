extends VBoxContainer
class_name LobbyPlayerList

# Component vars
@onready var tree : SceneTree = get_tree();

# File vars
@onready var player_info_file = preload("res://Scenes/Menus/MainMenu/PlayerLobbyInfo.tscn");


# Functions

func addPlayerInfo(player_name : String, color : Color) -> void:
	var PlayerInfoDisplay : Control = player_info_file.instantiate();
	add_child(PlayerInfoDisplay);
	PlayerInfoDisplay.initialize(player_name, color);


func removePlayerInfo(player_name : String) -> void:
	var player_info_labels : Array[Node] = get_children();
	for player_label in player_info_labels:
		if(player_label.player_name == player_name):
			player_label.queue_free();
