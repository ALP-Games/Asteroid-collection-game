class_name CollectionZone extends Node3D


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is not Asteroid:
		return
	var asteroid := area.get_parent() as Asteroid
	#GameManager.credist_amount += asteroid.get_asteroid_value()
	asteroid.destroy_asteroid()
	# play effect
