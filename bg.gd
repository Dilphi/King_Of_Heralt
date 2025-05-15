extends ParallaxBackground
#Переменная для скорости передвежения
var spead = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Сдвиг по оси Х
	scroll_offset.x -= spead * delta
