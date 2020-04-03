extends RichTextLabel

var fps = 0.0

func _process(delta):
	fps = Engine.get_frames_per_second()
	clear()
	add_text( "fps: " + str(fps) )
