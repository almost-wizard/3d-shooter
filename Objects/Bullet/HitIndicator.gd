extends Sprite3D

func _on_timer_timeout():
	while modulate.a > 0:
		modulate.a -= 0.05
		await get_tree().create_timer(0.05).timeout
	queue_free()
