extends TextureButton


# Component vars
@onready var ErrorLabel : Label = $ErrorLabel;
@onready var tree : SceneTree = get_tree();


# Processes

func _on_pressed() -> void:
	var join_attempt : bool = tree.get_first_node_in_group("GMultiplayerController").joinGame();
	if(!join_attempt):
		ErrorLabel.visible = true;
		return;
	tree.get_first_node_in_group("GLobbyMenu").visible = true;
	tree.get_first_node_in_group("GStartMenu").visible = false;
