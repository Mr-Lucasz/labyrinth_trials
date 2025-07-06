extends Node

# Dados do jogador
var player_nickname: String = ""
var fase_atual: int = 1
var checkpoint_alcancado: bool = false
var puzzle_atual: int = 1
var puzzles_completados: int = 0

# Caminho do arquivo de save
const SAVE_FILE_PATH = "user://savegame.dat"

func save_game_at_checkpoint():
	var save_data = {
		"nickname": player_nickname,
		"fase_atual": fase_atual,
		"checkpoint_alcancado": checkpoint_alcancado,
		"puzzle_atual": puzzle_atual,
		"puzzles_completados": puzzles_completados,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Jogo salvo no checkpoint!")
	else:
		print("Erro ao salvar o jogo!")

func load_game_data():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return null
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			return json.data
		else:
			print("Erro ao analisar dados de save")
			return null
	else:
		print("Erro ao abrir arquivo de save")
		return null

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)

func reset_game_data():
	player_nickname = ""
	fase_atual = 1
	checkpoint_alcancado = false
	puzzle_atual = 1
	puzzles_completados = 0
