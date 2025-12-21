class_name IntroState extends Node


@export var animation_player: AnimationPlayer



func _ready() -> void :
    AudioManager.play_music(Music.new(preload("res://assets/music/main_menu/intro.ogg")))
