extends Node3D

# Declare local objects as variables
@onready var main_menu = $"CanvasLayer/Main Menu"
@onready var address_entry = $"CanvasLayer/Main Menu/MarginContainer/VBoxContainer/AddressEntry"
@onready var hud = $CanvasLayer/Hud
@onready var health_bar = $CanvasLayer/Hud/HealthBar


# Declare local variables
const Player = preload("res://player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

# Quit the game upon pressing quit (Escape)
func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


# Host button gets pressed, hide the main menu and show the player hud
func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	# Create the Peer server with the assigned port
	enet_peer.create_server(PORT)
	
	# Create a player when connecting and disconnect players who leave
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())


# Join a locally hosted game
func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	# Create the client 
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer


# Adds a player to the scene and assigns it to the current client or host
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
			player.health_changed.connect(update_health_bar)


# Removes a player from the local server
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


# Update the players health
func update_health_bar(health_value):
	health_bar.value = health_value


# Update the health bar of new players or when players are spawned
func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
			node.health_changed.connect(update_health_bar)

# To Be Set Up Later
func upnp_setup():
	pass
