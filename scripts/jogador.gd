extends CharacterBody2D

var speed = 100

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	update_animation(input_vector)

func update_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		$AnimatedSprite2D.play("parado_frente")
	else:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				$AnimatedSprite2D.play("andando_ladoR")
			else:
				$AnimatedSprite2D.play("andando_ladoL")
		else:
			if input_vector.y < 0:
				$AnimatedSprite2D.play("parado_costa")
			else:
				$AnimatedSprite2D.play("parado_frente")
