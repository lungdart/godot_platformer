extends RichTextLabel


# Declare member variables here. Examples:
var fps = 0.0
# var b = "text"


func _process(delta):
	fps = Engine.get_frames_per_second()
	clear()
	add_text( "fps: " + str(fps) )
