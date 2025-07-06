extends CharacterBody2D

@export var speed: float = 300.0
const HOLD_OFFSET := Vector2(0, -24)  # ajuste pra posicionar o item na mão

var nearby_item: Node2D = null
var carried: Node2D = null

func _ready() -> void:
	# Conecta sinais do detector de itens
	$PickupDetector.body_entered.connect(_on_body_entered)
	$PickupDetector.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	if Input.is_action_just_pressed("ui_select"):
		if carried:
			_drop_item()
		elif nearby_item:
			_pick_item(nearby_item)

func _handle_movement(delta: float) -> void:
	var iv = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	).normalized()
	velocity = iv * speed
	move_and_slide()
	_update_animation(iv)

func _update_animation(iv: Vector2) -> void:
	if iv == Vector2.ZERO:
		$AnimatedSprite2D.play("parado_frente")
	else:
		if abs(iv.x) > abs(iv.y):
			# ternário em GDScript
			var anim = "andando_ladoR" if iv.x > 0 else "andando_ladoL"
			$AnimatedSprite2D.play(anim)
		else:
			var anim = "parado_costa" if iv.y < 0 else "parado_frente"
			$AnimatedSprite2D.play(anim)

# —–––––––––––––––––––––––––––––––––––––––––––––––––
# Sinais do PickupDetector
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("pickable") and carried == null:
		print("body")
		nearby_item = body

func _on_body_exited(body: Node) -> void:
	if body == nearby_item:
		nearby_item = null

# —–––––––––––––––––––––––––––––––––––––––––––––––––
# Funções de pegar e soltar
func _pick_item(item: Node2D) -> void:
	carried = item
	# remove do nível original e adiciona como filho do jogador
	var orig_parent = item.get_parent()
	orig_parent.remove_child(item)
	add_child(item)
	# posiciona na mão
	item.position = HOLD_OFFSET
	# opcional: desativa colisão do item enquanto carrega
	if item.has_node("CollisionShape2D"):
		item.get_node("CollisionShape2D").disabled = true

func _drop_item() -> void:
	# posição global para soltar
	var world_pos = to_global(carried.position)
	# reparenta para a cena raiz
	remove_child(carried)
	get_tree().current_scene.add_child(carried)
	carried.global_position = world_pos
	# reativa colisão
	if carried.has_node("CollisionShape2D"):
		carried.get_node("CollisionShape2D").disabled = false

	# se houver zonas de drop, faz “snap” automático
	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if zone is Area2D and zone.get_overlapping_bodies().has(carried):
			carried.global_position = zone.global_position
			break

	carried = null
	nearby_item = null
