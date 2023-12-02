extends TextureButton

# Component vars
@onready var tree : SceneTree = get_tree();


func _on_pressed() -> void:
	tree.get_first_node_in_group("GMultiplayerController").toggleReady();
