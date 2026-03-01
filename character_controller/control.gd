extends Control

@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var _1_st_label: Label = $"CanvasLayer/ColorRect/1st_label"
@onready var _2_nd_label: Label = $"CanvasLayer/ColorRect/2nd_label"
@onready var _3_rd_label: Label = $"CanvasLayer/ColorRect/3rd_label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start()


func _start():
	_1_st_label.show()
	await get_tree().create_timer(3).timeout
	_1_st_label.hide()
	_2_nd_label.show()
	await get_tree().create_timer(3).timeout
	_2_nd_label.hide()
	_3_rd_label.show()
	await get_tree().create_timer(2).timeout
	_3_rd_label.hide()
	color_rect.hide()
	get_tree().change_scene_to_file("res://test.tscn")
