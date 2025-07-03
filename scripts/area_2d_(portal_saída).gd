extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jogador":
		print("Passou no portal!")
		# Quando tiver o Level2:
		# get_tree().change_scene("res://scenes/Level2.tscn")
