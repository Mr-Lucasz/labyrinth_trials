extends AcceptDialog


func _ready():
	self.dialog_text = "Parabéns! Você concluiu todos os puzzles da Fase 1!"
	add_button("Ir para Fase 2", true, "go_to_level2")
	self.custom_action.connect(_on_custom_action)

func _on_custom_action(action):
	if action == "go_to_level2":
		get_tree().change_scene_to_file("res://scenes/Level_2.tscn")
