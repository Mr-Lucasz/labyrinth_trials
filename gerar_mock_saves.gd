extends SceneTree

# Script para gerar arquivos de save mockados para teste
# Execute este script com: godot -s gerar_mock_saves.gd
# Você não precisa modificar o código do jogo, apenas executar este script
# antes de iniciar os testes para ter saves disponíveis para carregar

func _init():
	print("Gerador de saves mock iniciado...")
	
	# Mostra o diretório real onde os arquivos são salvos
	print("Diretório de saves: " + OS.get_user_data_dir())
	
	# Criar alguns saves de exemplo com diferentes progressos
	criar_save("jogador1", true, true, false, 3)
	criar_save("jogador2", true, true, true, 3)
	criar_save("teste", true, false, false, 1)
	
	print("Saves mock criados com sucesso! Execute o jogo e clique em Carregar.")
	print("Os seguintes saves estão disponíveis:")
	print("- jogador1 (2 puzzles completos, checkpoint alcançado)")
	print("- jogador2 (todos puzzles completos)")
	print("- teste (1 puzzle completo)")
	
	quit()

func criar_save(nickname: String, shape_completed: bool, number_completed: bool, arrow_completed: bool, next_number_index: int):
	# 1. Criar arquivo no formato jogador.gd (.save)
	var save_data = {
		"player_name": nickname,
		"shape_completed": shape_completed,
		"number_completed": number_completed,
		"arrow_completed": arrow_completed,
		"next_number_index": next_number_index,
		"checkpoint_reached": shape_completed and number_completed,
		"all_completed_printed": shape_completed and number_completed and arrow_completed,
		"position": {"x": 500, "y": 300},
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file_path = "user://savegame_%s.save" % nickname
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Criado save jogador.gd para: " + nickname)
	
	# 2. Criar arquivo no formato Global (.dat)
	var global_data = {
		"nickname": nickname,
		"fase_atual": 1,
		"checkpoint_alcancado": shape_completed and number_completed,
		"puzzle_atual": 1 + int(shape_completed) + int(number_completed) + int(arrow_completed),
		"puzzles_completados": int(shape_completed) + int(number_completed) + int(arrow_completed),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	file_path = "user://savegame_%s.dat" % nickname
	file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(global_data))
		file.close()
		print("Criado save Global para: " + nickname)
