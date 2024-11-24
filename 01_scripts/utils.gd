extends Object
class_name Utils


static func get_time_string(total_seconds: float) -> String:
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%02d:%05.2f" % [minutes, seconds]
	hhmmss_string = hhmmss_string.replace(".", ":")
	return hhmmss_string
