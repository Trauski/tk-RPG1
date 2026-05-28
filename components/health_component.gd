class_name HealthComponent
extends Node

# Sinais atualizados (No Godot 4, usamos .emit() que é mais moderno que emit_signal)
signal morreu
signal vida_alterada(vida_atual: float, vida_max: float)

var vida_maxima: float = 100.0
var vida_atual: float = 100.0
var defesa: float = 0.0
var esta_morto: bool = false

# FUNÇÃO ESSENCIAL: O herói/inimigo chama isso no _ready para configurar o componente
func inicializar(max_vida: float, defesa_base: float = 0.0):
	vida_maxima = max_vida
	vida_atual = max_vida
	defesa = defesa_base
	esta_morto = false

func receber_dano(quantidade: float):
	if esta_morto:
		return

	# Calcula o dano considerando a defesa (garante que o dano mínimo seja pelo menos 1 se você quiser, ou 0)
	var dano_real = max(0, quantidade - defesa)
	vida_atual -= dano_real
	vida_alterada.emit(vida_atual, vida_maxima)

	if vida_atual <= 0:
		vida_atual = 0
		esta_morto = true
		morreu.emit()

func curar(quantidade: float):
	if esta_morto:
		return
	vida_atual = min(vida_atual + quantidade, vida_maxima)
	vida_alterada.emit(vida_atual, vida_maxima)
