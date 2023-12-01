extends Node2D


# Component Vars

@onready var multiplayerController : Node2D = $MultiplayerController;


# Processes

func _ready() -> void:
	randomize();
	multiplayerController.startGame();
