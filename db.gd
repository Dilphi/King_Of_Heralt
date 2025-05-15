extends Node

var db: SQLite

func _init():
	db = SQLite.new()
	db.path = "res://stat.db"
	if db.open_db():
		print("База данных открыта успешно")
		create_tables()
	else:
		print("Ошибка при открытии базы данных:", db.error_message)

func create_tables():
	# Таблица игрока
	var player_query = """
	CREATE TABLE IF NOT EXISTS Player (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_deaths INTEGER DEFAULT 0,
		collected_gold INTEGER DEFAULT 0,
		collected_rocks INTEGER DEFAULT 0
	);
	"""


	db.query(player_query)
	db.query("INSERT OR IGNORE INTO Player (id) VALUES (1);")

	# Таблица мобов
	var mobs_query = """
	CREATE TABLE IF NOT EXISTS Mobs (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT UNIQUE,
		total_deaths INTEGER DEFAULT 0,
		deaths_by_player INTEGER DEFAULT 0
	);
	"""
	db.query(mobs_query)
	db.query("INSERT OR IGNORE INTO Mobs (name) VALUES ('mushroom'), ('skelet');")

	# Таблица игровой сессии
	var game_query = """
	CREATE TABLE IF NOT EXISTS Game (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER,
		duration_seconds INTEGER,
		game_days INTEGER,
		total_gold INTEGER,
		game_end_time TEXT DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY(player_id) REFERENCES Player(id)
	);
	"""
	db.query(game_query)

	# Таблица сохранений
	var save_game_query = """
	CREATE TABLE IF NOT EXISTS SaveGame (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER,
		current_gold INTEGER,
		save_time TEXT DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY(player_id) REFERENCES Player(id)
	);
	"""
	db.query(save_game_query)

	print("Все таблицы созданы и инициализированы.")

func add_player_death():
	var query = "UPDATE Player SET player_deaths = player_deaths + 1 WHERE id = 1;"
	db.query(query)

func add_mob_death(mob_name: String, by_player := true):
	var query = "UPDATE Mobs SET total_deaths = total_deaths + 1 WHERE name = ?;"
	db.query_with_bindings(query, [mob_name])
	if by_player:
		var by_player_query = "UPDATE Mobs SET deaths_by_player = deaths_by_player + 1 WHERE name = ?;"
		db.query_with_bindings(by_player_query, [mob_name])

func add_collected_rock(amount: int):
	var query = """
	UPDATE Player
	SET collected_rocks = collected_rocks + ?
	WHERE id = 1;
	"""
	if db.query_with_bindings(query, [amount]):
		print("Добавлено камней:", amount)
	else:
		print("Ошибка при обновлении собранных камней:", db.error_message)



func record_game(duration_seconds: int, game_days: int, total_gold: int):
	var query = """
	INSERT INTO Game (player_id, duration_seconds, game_days, total_gold)
	VALUES (1, ?, ?, ?);
	"""
	db.query_with_bindings(query, [duration_seconds, game_days, total_gold])

func save_game(current_gold: int):
	var query = """
	INSERT INTO SaveGame (player_id, current_gold)
	VALUES (1, ?);
	"""
	db.query_with_bindings(query, [current_gold])

func get_player_stats():
	db.query("SELECT * FROM Player WHERE id = 1;")
	var result = db.query_result
	return result[0] if result.size() > 0 else {}


func get_mob_stats():
	db.query("SELECT * FROM Mobs;")
	var result = db.query_result
	return result

	
func add_collected_gold(amount: int):
	var query = """
	UPDATE Player
	SET collected_gold = collected_gold + ?
	WHERE id = 1;
	"""
	if db.query_with_bindings(query, [amount]):
		print("Добавлено золота:", amount)
	else:
		print("Ошибка при обновлении собранного золота:", db.error_message)

func update_coin_state(gold: int):
	var update_query = """
		UPDATE SaveGame
		SET current_gold = ?, save_time = CURRENT_TIMESTAMP
		WHERE player_id = 1;
	"""
	if db.query_with_bindings(update_query, [gold]):
		print("Золото успешно обновлено")
	else:
		print("Ошибка при обновлении золота:", db.error_message)


func on_game_over(duration_seconds := 0, game_days := 0, total_gold := 0) -> Dictionary:
	record_game(duration_seconds, game_days, total_gold)
	save_game(total_gold)
	
	var mob_stats = get_mob_stats()
	var total_deaths = 0
	for mob in mob_stats:
		total_deaths += int(mob.get("deaths_by_player", 0))
	
	var coins = get_collected_gold()
	
	return {
		"mob_deaths": total_deaths,
		"coins": coins
	}



func get_collected_gold() -> int:
	db.query("SELECT collected_gold FROM Player WHERE id = 1;")
	var result = db.query_result
	return int(result[0]["collected_gold"]) if result.size() > 0 else 0
