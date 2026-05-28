extends Node2D

@onready var player = $Player # <-- Garanta que na árvore de cenas o Archer se chame "Player"
@onready var hud = $ContainerHUD # <-- Garanta que na árvore de cenas o seu HUD se chame "ContainerHUD"

func _ready():
	# Este bloco roda assim que o mapa carrega. Ele funciona como o "gerente" que liga o herói à interface:
	if player and hud and player.stats:
		# 1. Pega os valores máximos de vida e mana do HeroStats do Archer
		var hp_maximo = player.stats.vida_max
		var mana_maxima = player.stats.mana_max if "mana_max" in player.stats else 100.0
		
		# 2. Configura os textos do HUD para iniciarem cheios (ex: 500/500 HP)
		hud.inicializar_hud(hp_maximo, mana_maxima)
		
		# 3. Faz o HUD "escutar" o componente de vida do Arqueiro
		var health_comp = player.get_node("HealthComponent")
		if health_comp:
			# Toda vez que a vida mudar (pelo botão K), o componente avisa o HUD automaticamente!
			health_comp.vida_alterada.connect(hud.atualizar_hp)
