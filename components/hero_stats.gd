class_name HeroStats
extends Resource

@export_group("Identidade")
@export var nome: String = ""

@export_group("Status")
@export var vida_max: float = 1000.0
@export var velocidade_base: float = 200.0
@export_group("Mana")
@export var mana_max: float = 1000.0

@export_group("Combate")
@export var ataque_base: float = 20.0
@export var defesa_base: float = 10.0
@export var recarga_ataque_base: float = 0.5  # Archer 0.5, Warrior 0.8
@export var is_ranged: bool = true  # Código do herói identifica se é classe Ranged
@export var frame_disparo: int = 5
