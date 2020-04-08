extends Node2D


onready var enemy_count = get_children().size()
onready var enemy_scene = load("res://src/actors/enemy/enemy.tscn")

func spawn_new(count):
	for i in range(count):
		var instance = enemy_scene.instance()
		var position = Vector2(0, 0)
		enemy_count += 1
		instance.set_name("enemy"+str(enemy_count))
		var rand_x = round(rand_range(-300, 300))
		instance.set_position(Vector2(rand_x, 0))
		add_child(instance)
		print("Spawned in ", instance.name, " at ", instance.position)
		
		

