extends Node

signal on_manager_ready(in_manager: Manager)


func clear_signal(in_signal: Signal) -> void:
    for connection: Dictionary in in_signal.get_connections():
        in_signal.disconnect(connection["callable"])