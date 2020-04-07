extends RichTextLabel

var _kill_counter = 0
var _update = false

func increment(value):
	_kill_counter += value
	_update = true

func _process(delta):
	if _update:
		_update = false
		clear()
		add_text( "Kills: " + str(_kill_counter) )
