class_name CollectionZone extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Asteroid:
		return
	var asteroid := body as Asteroid
	GameManager.credist_amount += asteroid.get_asteroid_value()
	asteroid.queue_free()
	# play effect
