extends Area2D

const VELOCIDADE = 1000.0
const TEMPO_VIDA = 2.0

var direcao: Vector2 = Vector2.ZERO
var tempo_atual = 0.0
var fincada = false # Nova variável para saber se a flecha bateu no chão

func inicializar(dir: Vector2):
	direcao = dir.normalized()
	rotation = direcao.angle()

func _physics_process(delta):
	tempo_atual += delta
	
	# REGRA ÚNICA DE DESTRUIÇÃO: Sumir SEMPRE com 2 segundos, no ar ou no chão
	if tempo_atual >= TEMPO_VIDA:
		queue_free()
		return

	# Se a flecha já bateu no chão, não movemos mais ela
	if fincada:
		return

	# Move a flecha apenas se ela estiver voando
	position += direcao * VELOCIDADE * delta

func _on_body_entered(body: Node2D) -> void:
	# Em vez de destruir com queue_free(), nós apenas paramos a flecha no lugar
	fincada = true
	
	# Desativa o monitoramento de novas colisões (evita bugar batendo em 2 coisas)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
