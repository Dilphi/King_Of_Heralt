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

# Создание таблиц для хранения информации о смертях мобов и игрока
func create_tables():
	# Таблица для мобов
	var mob_deaths_query = """
	CREATE TABLE IF NOT EXISTS MobDeaths (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		mob_id INTEGER UNIQUE,
		death_time TEXT
	);
	"""
	if db.query(mob_deaths_query):
		print("Таблица MobDeaths создана успешно")
	else:
		print("Ошибка при создании таблицы MobDeaths:", db.error_message)

	# Таблица для игрока
	var player_stats = """
	CREATE TABLE IF NOT EXISTS player_stats (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER UNIQUE,
		mob_deaths INTEGER DEFAULT 0,
		player_deaths INTEGER DEFAULT 0,
		wins INTEGER DEFAULT 0
	);
	"""
	if db.query(player_stats):
		print("Таблица player_stats создана успешно")
		# Вставка записи для игрока с id = 1 при создании таблицы
		var init_player_query = """
		INSERT OR IGNORE INTO player_stats (player_id)
		VALUES (1);
		"""
		if db.query(init_player_query):
			print("Запись для игрока с id 1 добавлена или уже существует")
		else:
			print("Ошибка при добавлении записи для игрока:", db.error_message)
	else:
		print("Ошибка при создании таблицы player_stats:", db.error_message)

	# Создание таблицы для сохранений
	var save_table_query = """
	CREATE TABLE IF NOT EXISTS SaveStat (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER UNIQUE,
		mob_deaths INTEGER DEFAULT 0,
		save_time TEXT
	);
	"""
	if db.query(save_table_query):
		print("Таблица SaveStat создана успешно")
	else:
		print("Ошибка при создании таблицы SaveStat:", db.error_message)

	# Создание таблицы для хранения здоровья и количества монет игрока
	var player_state_table_query = """
	CREATE TABLE IF NOT EXISTS PlayerState (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER UNIQUE,
		health INTEGER DEFAULT 100,
		gold INTEGER DEFAULT 0,
		update_time TEXT
	);
	"""
	if db.query(player_state_table_query):
		print("Таблица PlayerState создана успешно")
	else:
		print("Ошибка при создании таблицы PlayerState:", db.error_message)

	# Добавление записи для игрока с player_id = 1, если она ещё не существует
	var init_player_state_query = """
	INSERT OR IGNORE INTO PlayerState (player_id)
	VALUES (1);
	"""
	if db.query(init_player_state_query):
		print("Запись для PlayerState создана или уже существует")
	else:
		print("Ошибка при добавлении записи в PlayerState:", db.error_message)

# Обновление количества смертей игрока
func add_player_death():
	var query = """
	UPDATE player_stats
	SET player_deaths = player_deaths + 1
	WHERE player_id = 1;
	"""
	if db.query(query):
		print("Количество смертей игрока увеличено")
	else:
		print("Ошибка при обновлении количества смертей игрока:", db.error_message)

# Обновление записи смерти моба
func update_mob_death_record():
	var query = """
	INSERT OR REPLACE INTO MobDeaths (mob_id, death_time)
	VALUES (2, CURRENT_TIMESTAMP);
	"""
	if db.query(query):
		print("Запись о смерти моба обновлена")
		update_player_mob_deaths()
	else:
		print("Ошибка при обновлении записи о смерти моба:", db.error_message)

# Обновление количества смертей мобов у игрока
func update_player_mob_deaths():
	var query = """
	UPDATE player_stats
	SET mob_deaths = mob_deaths + 1
	WHERE player_id = 1;
	"""
	if db.query(query):
		print("Количество смертей мобов у игрока увеличено")
	else:
		print("Ошибка при обновлении количества смертей мобов игрока:", db.error_message)

# Получение статистики игрока
func get_player_stats():
	var query = """
	SELECT mob_deaths, wins FROM player_stats WHERE player_id = 1;
	"""
	var result = db.select(query)
	if result.size() > 0:
		var mob_deaths = result[0]["mob_deaths"]
		var wins = result[0]["wins"]
		print("Статистика игрока - Смерти мобов:", mob_deaths, "Победы:", wins)
		return {"mob_deaths": mob_deaths, "wins": wins}
	else:
		print("Ошибка при получении статистики игрока:", db.error_message)
		return {"mob_deaths": 0, "wins": 0}

# Обновление записи сохранения
func update_save_record():
	var query = """
	INSERT OR REPLACE INTO SaveStat (player_id, mob_deaths, save_time)
	VALUES (1, (SELECT mob_deaths FROM player_stats WHERE player_id = 1), CURRENT_TIMESTAMP);
	"""
	if db.query(query):
		print("Запись о сохранении обновлена")
	else:
		print("Ошибка при обновлении записи о сохранении:", db.error_message)

# Обновление состояния здоровья и золота
func update_player_state(new_health: int, gold: int):
	var update_query = """
	UPDATE PlayerState
	SET health = ?, gold = ?, update_time = CURRENT_TIMESTAMP
	WHERE player_id = 1;
	"""
	if db.query_with_bindings(update_query, [new_health, gold]):
		print("Здоровье и золото обновлены в таблице PlayerState")
	else:
		print("Ошибка при обновлении здоровья и золота:", db.error_message)
		
func update_coin_state(gold: int):
	var update_query = """
	UPDATE PlayerState
	SET gold = ?, update_time = CURRENT_TIMESTAMP
	WHERE player_id = 1;
	"""
	if db.query_with_bindings(update_query, [gold]):
		print("Здоровье и золото обновлены в таблице PlayerState")
	else:
		print("Ошибка при обновлении здоровья и золота:", db.error_message)
# Закрытие базы данных
func close_database():
	if db.close_db():
		print("Соединение с базой данных закрыто успешно")
	else:
		print("Ошибка при закрытии базы данных:", db.error_message)

# Вызов функции при окончании игры, чтобы показать количество смертей и побед
# Вызов функции при окончании игры, чтобы показать количество смертей и побед
func on_game_over() -> Dictionary:
	var total_mob_deaths = 0
	var total_coin_cout = 0
	
	# Получение данных о смертях мобов
	var result = db.select_rows("player_stats", "mob_deaths > 0", ["mob_deaths"])
	if result.size() > 0:
		for row in result:
			total_mob_deaths += int(row["mob_deaths"])
		print("Общее количество смертей мобов:", total_mob_deaths)
	else:
		print("Нет записей с количеством смертей мобов больше 0")

	# Получение данных о монетах
	var result_coin = db.select_rows("PlayerState", "gold > 0", ["gold"])
	if result_coin.size() > 0:
		for row in result_coin:
			total_coin_cout += int(row["gold"])
		print("Общее количество монет:", total_coin_cout)
	else:
		print("Нет записей с количеством монет больше 0")

	return {"mob_deaths": total_mob_deaths, "coins": total_coin_cout}
