extends Control

# Object vars
var player_name : String = "";

# Component vars
@onready var NameLabel : Label = $NameLabel;
@onready var ColorIndicator : TextureRect = $ColorIndicator;


# Functions

func initialize(set_name : String, color : Color) -> void:
	player_name = set_name;
	NameLabel.text = player_name;
	ColorIndicator.modulate = color;
