extends RichTextLabel

export var kill_counter = 0
var _update = false

func increment(value):
	kill_counter += value
	_update = true

func _process(delta):
	if _update:
		_update = false
		clear()
		add_text( "Kills: " + str(kill_counter) )
