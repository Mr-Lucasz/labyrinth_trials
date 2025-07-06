extends Control

# Esta função será chamada quando o botão "Novo Jogo" for pressionado.
# Ela irá carregar a cena da primeira fase do seu jogo.
# ATENÇÃO: Substitua "res://caminho/para/sua/fase1.tscn" pelo caminho real da sua cena da Fase 1.
func _on_button_novo_pressed():
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

# Esta função será chamada pelo botão "Carregar Jogo".
func _on_button_carregar_pressed():
	# A lógica para carregar o jogo salvo (checkpoint) virá aqui.
	# Por enquanto, podemos apenas imprimir uma mensagem.
	print("Botão Carregar Pressionado!")
	# Você precisará verificar se existe um arquivo de save antes de habilitar este botão.

# Esta função será chamada pelo botão "Ranking".
func _on_button_ranking_pressed():
	# A lógica para mostrar a tela de Ranking virá aqui.
	print("Botão Ranking Pressionado!")

# Esta função será chamada pelo botão "Sobre".
func _on_button_sobre_pressed():
	# A lógica para mostrar a tela com os nomes dos desenvolvedores virá aqui.
	print("Botão Sobre Pressionado!")
