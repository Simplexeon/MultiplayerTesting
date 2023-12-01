extends Control

# Object vars
var player_name : String = "";

# Component vars
@onready var NameLabel : Label = $NameLabel;
@onready var ColorIndicator : TextureRect = $ColorIndicator;
@onready var TickMark : Sprite2D = $TickMark;


# Functions

func initialize(new_name : String, color : Color, ready : bool) -> void:
	player_name = new_name;
	NameLabel.text = player_name;
	ColorIndicator.modulate = color;
	if(ready):
		TickMark.frame = 1;
	else:
		TickMark.frame = 0;


func readyUp() -> void:
	TickMark.frame = 1;


func unready() -> void:
	TickMark.frame = 0;
