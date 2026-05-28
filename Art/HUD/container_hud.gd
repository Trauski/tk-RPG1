extends CanvasLayer # Certifique-se de que o node raiz é um Control

# Pegando a referência de todos os seus nós filhos (exatamente com os nomes que você citou)
@onready var moldura_base = $MolduraBase
@onready var barra_hp = $BarraHP
@onready var texto_hp = $TextoHP
@onready var barra_mp = $BarraMP
@onready var texto_mp = $TextoMP
@onready var barra_xp = $BarraXP
@onready var texto_xp = $TextoXP

# Variáveis para o script memorizar os valores máximos
var hp_maximo: float = 100.0
var mp_maximo: float = 100.0
var xp_maximo: float = 100.0

# Esta função configura o HUD inteiro logo no início do jogo
func inicializar_hud(hp_max: float, mp_max: float, xp_max: float = 100.0):
	hp_maximo = hp_max
	mp_maximo = mp_max
	xp_maximo = xp_max
	
	# Define os limites máximos das barras de texturas
	barra_hp.max_value = hp_max
	barra_hp.value = hp_max
	
	barra_mp.max_value = mp_max
	barra_mp.value = mp_max
	
	barra_xp.max_value = xp_max
	barra_xp.value = 0 # Começa com zero de XP
	
	# Atualiza os textos numéricos iniciais
	_atualizar_texto_hp(hp_max)
	_atualizar_texto_mp(mp_max)
	_atualizar_texto_xp(0)

# Funções que o jogo vai chamar para atualizar as barras e textos
func atualizar_hp(hp_atual: float, _hp_max: float):
	if barra_hp:
		barra_hp.value = hp_atual
	_atualizar_texto_hp(hp_atual)

func atualizar_mp(mp_atual: float):
	barra_mp.value = mp_atual
	_atualizar_texto_mp(mp_atual)

func atualizar_xp(xp_atual: float):
	barra_xp.value = xp_atual
	_atualizar_texto_xp(xp_atual)

# Funções internas que montam as strings de texto (ex: "500 / 500 HP")
func _atualizar_texto_hp(hp_atual: float):
	if texto_hp:
		texto_hp.text = str(int(hp_atual)) + " / " + str(int(hp_maximo)) + " HP"

func _atualizar_texto_mp(mp_atual: float):
	if texto_mp:
		texto_mp.text = str(int(mp_atual)) + " / " + str(int(mp_maximo)) + " MP"

func _atualizar_texto_xp(xp_atual: float):
	if texto_xp:
		texto_xp.text = str(int(xp_atual)) + " / " + str(int(xp_maximo)) + " XP"
