class_name PointerUI extends Control

@onready var pointer_pivot: Control = $PointerPivot
@onready var po_i_icon: TextureRect = $PointerPivot/PoIIcon

@export var display_distance: float = 30.0

var _player_ship: PlayerShip
var _collection_zone: CollectionZone


func _ready() -> void:
	pointer_pivot.visible = false
	pointer_pivot.pivot_offset = Vector2(pointer_pivot.size.x / 2, pointer_pivot.size.y / 2)
	po_i_icon.pivot_offset = Vector2(po_i_icon.size.x / 2, po_i_icon.size.y / 2)
	_player_ship = get_tree().get_first_node_in_group("player")
	_collection_zone = get_tree().get_first_node_in_group("collector")


#func _process(delta: float) -> void:
	

func _physics_process(_delta: float) -> void:
	var position_delta := _collection_zone.global_position - _player_ship.global_position
	#var distance_to_collection := _player_ship.global_position.distance_to(_collection_zone.global_position)
	if position_delta.length() >= display_distance:
		pointer_pivot.visible = true
		var angle := Vector3.FORWARD.signed_angle_to(position_delta, Vector3.UP)
		pointer_pivot.rotation = -angle
		po_i_icon.rotation = angle
	else:
		pointer_pivot.visible = false
