extends Node

# Notes
# 1. For some reason, opening the settings file with READ_WRITE results in bad parts of strings being written to the file.
# To correct this issue, we open the file two times, once in read mode, and another time in write mode. This appears to have corrected the strange issue.

@export_category("Settings")
@export var default_width = 1920
@export var default_height = 1080
@export var default_windowed = true
@export var settings_path = "./settings.json"

@onready var menu = $Menu
@onready var port = $Menu/Container/Port

@onready var width_input = $Menu/Container/Port/Width/Value
@onready var height_input = $Menu/Container/Port/Height/Value
@onready var windowed_input = $Menu/Container/Port/Windowed/Value

var json = JSON.new()
	
func load_settings(save = false):
	# Open settings file.
	var f = FileAccess.open(settings_path, FileAccess.READ)
	
	if f == null:
		print("Failed to open settings file: %s" % settings_path)
		
		return
		
	# Retrieve contents of settings file.
	var contents = f.get_as_text()
	
	f.close()
	
	var jsonData = {}
	
	# Try parsing as JSON.
	var err = json.parse(contents)
	
	if err != OK:
		print("Failed to load settings. Error: %s. Line: %s" % [json.get_error_message(), json.get_error_line()])
	else:
		jsonData = json.data
	
	# Initialize defaults.
	var width = default_width
	var height = default_height
	var windowed = default_windowed
	
	if save:
		# If we're saving, this means the control values have the correct values.
		width = int(width_input.text)
		height = int(height_input.text)
		windowed = bool(windowed_input.button_pressed)
	else:
		# If we're not saving, use contents from JSON.
		# Check for width override.
		if "width" in jsonData:
			width = int(jsonData.width)
		
		# Check for height override.
		if "height" in jsonData:
			height = int(jsonData.height)
			
		# Check for windowed override.
		if "windowed" in jsonData:
			windowed = bool(jsonData.windowed)
			
	# Set view ports size.
	#port.size = Vector2i(width, height)
	
	# Set window's width and height.
	DisplayServer.window_set_size(Vector2i(width, height))
	#DisplayServer.window_set_position(Vector2i(0, 0))
	
	# Set screen mode.
	if windowed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
	# Check if we're saving.
	if save:
		f = FileAccess.open(settings_path, FileAccess.WRITE)
		
		if f != null:
			# Create new data dictionary to convert to JSON.
			var newData = {}
			
			newData["width"] = width
			newData["height"] = height
			newData["windowed"] = windowed
		
			# Convert JSON object to string.
			var jsonStr = json.stringify(newData)
			
			# Store JSON string into settings file.
			f.store_string(jsonStr)
			
			f.close()
		else:
			print("Failed to save config. Not able to open settings file!")
	else:
		# No saving means the game just started. Set form values.
		width_input.text = str(width)
		height_input.text = str(height)
		windowed_input.button_pressed = windowed
		
	# Close settings file.
	f.close()
	
func _ready():
	load_settings()

func _on_apply_pressed():
	load_settings(true)
	
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_pressed():
			menu.visible = !menu.visible
	
