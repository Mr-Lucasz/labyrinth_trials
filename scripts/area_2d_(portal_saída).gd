
extends Area2D

func _ready():
	# Garante que o portal será ativado se a fase já estiver completa ao carregar a cena
	if has_node("../Level1"):
		var manager = get_node("../Level1")
		if manager.has_method("get_puzzles_completed") and manager.get_puzzles_completed() >= 3:
			ativar_portal()

# Realce visual do portal
@onready var highlight_sprite = $Sprite2D if has_node("Sprite2D") else null
var portal_ativo := false

# Chame esta função quando todos os puzzles forem concluídos
func ativar_portal():
	if portal_ativo:
		print("[DEBUG] ativar_portal() chamado, mas portal já estava ativo!")
		return
	portal_ativo = true
	print("[DEBUG] ativar_portal() chamado! portal_ativo=", portal_ativo)
	if highlight_sprite:
		highlight_sprite.modulate = Color(0.2, 1.0, 0.2, 1.0) # Verde claro
		print("[DEBUG] Sprite do portal modificado para verde!")
	else:
		print("[DEBUG] Portal não tem Sprite2D para destacar!")
	print("Portal de saída ativado e realçado!")

func _on_body_entered(body: Node2D) -> void:
	print("[DEBUG] _on_body_entered chamado! portal_ativo=", portal_ativo, " body.name=", body.name)
	if not portal_ativo:
		print("[DEBUG] Portal não está ativo, ignorando entrada.")
		return
	if body.name == "Jogador":
		print("Passou no portal! Indo para Fase 2...")
		get_tree().change_scene_to_file("res://scenes/Level_2.tscn")
	else:
		print("[DEBUG] Corpo entrou, mas não é o Jogador: ", body.name)
