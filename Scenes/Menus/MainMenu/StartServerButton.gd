extends TextureButton


# Component vars
@onready var tree : SceneTree = get_tree();


# Processes

func _on_pressed() -> void:
	tree.get_first_node_in_group("GMultiplayerController").startServer();
	tree.get_first_node_in_group("GReadyButton").visible = false;
	tree.get_first_node_in_group("GLobbyMenu").visible = true;
	tree.get_first_node_in_group("GStartMenu").visible = false;
