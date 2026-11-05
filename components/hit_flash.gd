class_name HitFlash extends Node

@export var target: CanvasItem
var _mat := ShaderMaterial.new()


func _ready() -> void:
	_mat.shader = load("res://components/hit_flash.gdshader")
	target.material = _mat


func flash(duration: float = 0.08) -> void:
	_mat.set_shader_parameter("flash", 1.0)
	get_tree().create_timer(duration).timeout.connect(func() -> void: _mat.set_shader_parameter("flash", 0.0))
