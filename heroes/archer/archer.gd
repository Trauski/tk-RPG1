extends CharacterBody2D

# ==============================================================================
# CONF. DO PROJETO E EXPORTS
# ==============================================================================
@export_group("Recursos Básicos")
@export var stats: HeroStats
@export var cena_projetil: PackedScene

# ==============================================================================
# VARIÁVEIS DE SISTEMA / COMPONENTES
# ==============================================================================
@onready var health_component = $HealthComponent
@onready var ponto_disparo = $PontoDisparo
@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var life_bar = $LifeBar

# ==============================================================================
# VARIÁVEIS DE MOVIMENTAÇÃO PADRÃO
# ==============================================================================
var velocidade_atual: float
var ultima_direcao = Vector2.DOWN

# ==============================================================================
# VARIÁVEIS DE COMBATE (ATAQUE)
# ==============================================================================
var recarga_ataque = 0.5
var velocidade_ataque_base = 0.5

var pode_atacar = true
var tempo_recarga_ataque = 0.0
var em_ataque = false

# ==============================================================================
# VARIÁVEIS DO DASH
# ==============================================================================
const VELOCIDADE_DASH = 800.0
const DURACAO_DASH = 0.7
const RECARGA_DASH = 2.0

var em_dash = false
var pode_dar_dash = true
var tempo_dash = 0.0
var tempo_recarga_dash = 0.0

# ==============================================================================
# FUNÇÕES PRINCIPAIS DO ENGINE (CICLO DE VIDA)
# ==============================================================================
func _ready():
	animated_sprite.play("archer_idle")
	if stats:
		velocidade_atual = stats.velocidade_base
		recarga_ataque = stats.recarga_ataque_base
		velocidade_ataque_base = stats.recarga_ataque_base
	if health_component:
		health_component.inicializar(stats.vida_max, stats.defesa_base)
	if life_bar:
		life_bar.max_value = stats.vida_max
		life_bar.value = stats.vida_max
		
		_criar_segmentos_de_hp()

func _physics_process(delta):
	if em_dash:
		_processar_dash(delta)
		return

	_atualizar_recargas(delta)

	var direcao = _ler_direcao()

	if Input.is_action_just_pressed("dash"):
		_iniciar_dash(direcao)

	if Input.is_action_just_pressed("attack"):
		_disparar()

	if em_ataque:
		velocity = Vector2.ZERO
	else:
		velocity = direcao * velocidade_atual
		
	move_and_slide()
	_atualizar_animacoes(direcao)

# ==============================================================================
# SISTEMA DE MOVIMENTO E INPUTS
# ==============================================================================
func _ler_direcao() -> Vector2:
	var direcao = Vector2.ZERO
	direcao.x = Input.get_axis("move_left", "move_right")
	direcao.y = Input.get_axis("move_up", "move_down")

	if direcao != Vector2.ZERO:
		direcao = direcao.normalized()
		ultima_direcao = direcao
	return direcao

# ==============================================================================
# LÓGICA DO DASH
# ==============================================================================
func _iniciar_dash(_direcao: Vector2):
	if health_component and health_component.esta_morto:
		return
	if em_ataque:
		return
	if not pode_dar_dash:
		return
		
	em_dash = true
	pode_dar_dash = false
	tempo_dash = DURACAO_DASH
	tempo_recarga_dash = RECARGA_DASH
	animated_sprite.speed_scale = 2.5
	animated_sprite.play("archer_dash")

func _processar_dash(delta):
	tempo_dash -= delta
	velocity = ultima_direcao * VELOCIDADE_DASH
	if tempo_dash <= 0:
		em_dash = false
		_atualizar_animacoes(_ler_direcao())
	move_and_slide()

# ==============================================================================
# LÓGICA DE ATAQUE E PROJÉTEIS
# ==============================================================================
func _disparar():
	if health_component and health_component.esta_morto:
		return
	if not pode_atacar or not cena_projetil or em_dash:
		return
	pode_atacar = false
	em_ataque = true
	tempo_recarga_ataque = recarga_ataque
	# Ajusta dinamicamente a vel. da animação com base no tempo de recarga
	animated_sprite.speed_scale = velocidade_ataque_base / recarga_ataque
	
	# Vira o sprite e o ponto de disparo instantaneamente para o lado do mouse
	var direcao_mouse = global_position.direction_to(get_global_mouse_position())
	if direcao_mouse.x != 0:
		animated_sprite.flip_h = direcao_mouse.x < 0
		if direcao_mouse.x < 0:
			ponto_disparo.position.x = -abs(ponto_disparo.position.x)
		else:
			ponto_disparo.position.x = abs(ponto_disparo.position.x)
	
	animated_sprite.play("archer_attack")

func _criar_projetil():
	if not cena_projetil or not ponto_disparo:
		return
		
	var direcao_mouse = ponto_disparo.global_position.direction_to(get_global_mouse_position())
	
	var projetil = cena_projetil.instantiate()
	projetil.position = ponto_disparo.global_position
	projetil.inicializar(direcao_mouse)
	get_parent().add_child(projetil)

# ==============================================================================
# GERENCIAMENTO DE RECURSOS (CRONÔMETROS E ANIMAÇÕES)
# ==============================================================================
func _atualizar_recargas(delta):
	if not pode_dar_dash:
		tempo_recarga_dash -= delta
		if tempo_recarga_dash <= 0:
			pode_dar_dash = true

	if not pode_atacar:
		tempo_recarga_ataque -= delta
		if tempo_recarga_ataque <= 0:
			pode_atacar = true

func _atualizar_animacoes(direcao: Vector2):
	if health_component and health_component.esta_morto:
		if animated_sprite.animation != "archer_died":
			animated_sprite.play("archer_died")
		return
		
	if em_dash:
		return
		
	if em_ataque:
		return
	animated_sprite.speed_scale = 1.0 # Reseta a velocidade para locomoção e idle

	if direcao != Vector2.ZERO:
		animated_sprite.play("archer_walk")
		animated_sprite.flip_h = direcao.x < 0
		
		if direcao.x < 0:
				ponto_disparo.position.x = -abs(ponto_disparo.position.x)
		elif direcao.x > 0:
				ponto_disparo.position.x = abs(ponto_disparo.position.x)
	else:
		animated_sprite.play("archer_idle")
		
func _input(event):
	# Se você apertar a tecla "K" no teclado, o herói toma 25 de dano
	if event is InputEventKey and event.pressed:
		if event.as_text_key_label() == "K":
			print("Botão K pressionado")
			if health_component:
				health_component.receber_dano(100)
				print("Aplicado 100 de dano.", health_component.vida_atual)
	# Controle de Zoom da cksâmera com scroll do mouse
	if camera:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom = (camera.zoom + Vector2(0.1, 0.1)).clamp(Vector2(0.2, 0.2), Vector2(3.0, 3.0))
				_criar_segmentos_de_hp()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom = (camera.zoom - Vector2(0.1, 0.1)).clamp(Vector2(0.2, 0.2), Vector2(3.0, 3.0))
				_criar_segmentos_de_hp()
				
func _criar_segmentos_de_hp():
	# Calcula quantos "tijolinhos" de 100 de HP cabem na vida máxima
	var qtd_segmentos = int(stats.vida_max / 100.0)
	if qtd_segmentos <= 1 or not life_bar: return
	
	# Calcula a largura de cada bloquinho em pixels baseado no tamanho da barra
	var largura_barra = life_bar.size.x
	var largura_bloco = largura_barra / qtd_segmentos
	
	# Remove linhas antigas se o herói ganhar mais vida máxima no futuro
	for child in life_bar.get_children():
		child.queue_free()
		
	# Calcula a espessura ideal com base no zoom atual da câmera.
	# Quanto mais longe o zoom (menor o número), maior será a espessura em pixels.
	var espessura = 1
	if camera:
		espessura = max(1, int(1.0 / camera.zoom.x))
	
	for i in range(1, qtd_segmentos):
		var x_pos = i * largura_bloco
		
		var linha_divisoria = ColorRect.new()
		linha_divisoria.color = Color(0, 0, 0, 0.6)
		
		# Variável 'espessura' dinâmica no lugar do número 1 fixo
		linha_divisoria.size = Vector2(espessura, life_bar.size.y)
		linha_divisoria.position = Vector2(x_pos, 0)
		
		life_bar.add_child(linha_divisoria)

# ==============================================================================
# CONEXÕES DE SINAIS (SIGNALS)
# ==============================================================================
func _on_animated_sprite_2d_frame_changed() -> void:
	# Verifica dinamicamente se o frame atual é o de disparo.
	# Em vez de fixar o número 5, calculamos o frame ideal de cada animação.
	if animated_sprite.animation == "archer_attack" and stats:
		if animated_sprite.frame == stats.frame_disparo:
			_criar_projetil()

func _on_animated_sprite_2d_animation_finished() -> void:
	# Função universal para qualquer classe. 
	# Fim da animação de ataque? Libera o movimento, não importa qtd de frames.
	if "attack" in animated_sprite.animation:
		em_ataque = false

func _on_health_component_vida_alterada(vida_atual: float, vida_max: float) -> void:
	if life_bar:
		# Garante que o valor visual acompanhe a vida atualizada
		life_bar.value = vida_atual
		print("Barra de vida visual atualizada para: ", life_bar.value)

func _on_health_component_morreu() -> void:
	em_ataque = true 
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	print("Archer morreu! Animação archer_died iniciada.")
