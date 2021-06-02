-- Практическое задание тема "Оптимизация запросов"
-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users,
-- catalogs и products в таблицу logs помещается время и дата создания записи, название
-- таблицы, идентификатор первичного ключа и содержимое поля name.

SHOW VARIABLES LIKE 'datadir';-- переход в каталог данных

CREATE TABLE Logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    created_at datetime DEFAULT CURRENT_TIMESTAMP,
-- Предусматриваем столбцы для хранения нужной информации.
    table_name varchar(50) NOT NULL,
    row_id INT UNSIGNED NOT NULL,
    row_name varchar(255)
) ENGINE = Archive;-- Присваивание типа таблицы
/*
 * Типы таблиц - "движки"
 * InnoDB - по умолчанию
 * Memory - полностью разместить данные в оперативной памяти
 * Archive - сжать данные
 * MyISAM - данные сохраняются в одноименном файле с расширением MYD, а индексы — в файле MYI.

Что бы значения попадали в эти три столбца (table_name, row_id, row_name) создаем триггер AFTER INSERT 
на каждую из таблиц. 
 */
CREATE TRIGGER products_insert AFTER INSERT ON products
FOR EACH ROW
begin
	/*
	 * При добавлении строки в целевую таблицу (users, catalogs и products) в таблицу logs добавляем строку с нужными
данными: (NULL, DEFAULT, "ИМЯ ТАБЛИЦЫ", NEW.id, NEW.name)
 */
    INSERT INTO Logs VALUES (NULL, DEFAULT, "products", NEW.id, NEW.name);
END;

CREATE TRIGGER users_insert AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "users", NEW.id, NEW.name);
END;

CREATE TRIGGER catalogs_insert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "catalogs", NEW.id, NEW.name);
END;


/*
-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
CREATE TABLE samples (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO samples (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29'),
  ('Аркадий', '1994-03-17'),
  ('Ольга', '1981-07-10'),
  ('Владимир', '1988-06-12'),
  ('Екатерина', '1992-09-20');

SELECT
  COUNT(*)
FROM
  samples AS fst,
  samples AS snd,
  samples AS thd,
  samples AS fth,
  samples AS fif,
  samples AS sth;

SELECT COUNT(*) FROM users;

SELECT * FROM users LIMIT 10;
*/



-- Практическое задание тема "NoSQL"
-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

/*
 * Создаем коллекцию IP-адресов. В не ключём будет IP-адрес '127.0.0.1' откуда произведено посешение, а 1 (еденица) 
 * колличество посещений с этого IP-адресса.
 */
HINCRBY addresses '127.0.0.1' 1-- прирощение колличества посещений с этого '127.0.0.1' IP-адресса, прибавляя 1.
HGETALL addresses

HINCRBY addresses '127.0.0.2' 1
HGETALL addresses

HGET addresses '127.0.0.1'-- Получение кол-ва посещений по ключу. 



-- 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному
-- адресу и наоборот, поиск электронного адреса пользователя по его имени.

/*База данных Redis прекрасно ищет данные по ключу. По ключу - проще и быстрее.
 * Создаем две коллекции users и emails. В emails ключем будет 'igor - ИМЯ пользотеля', а значением адресс 
 * элестронной почты. В коллекции users - НАОБАРОТ.
 */
HSET emails 'igor' 'igorsimdyanov@gmail.com'-- 
HSET emails 'sergey' 'sergey@gmail.com'
HSET emails 'olga' 'olga@mail.ru'

HGET emails 'igor'

HSET users 'igorsimdyanov@gmail.com' 'igor'
HSET users 'sergey@gmail.com' 'sergey'
HSET users 'olga@mail.ru' 'olga'

HGET users 'olga@mail.ru'
-- По сути мы сохраняем одни и те же данные дважды, но получаем быстрый поиск.




-- 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

-- СУБД MongoDB - документо-ориентированные БД не имею тех существенных ограничений, связанных с реляциной моделью.
-- Поэтому можно строить структуры MongoDB, как угодно. Применим вар-т близкий MySQL

show dbs

use shop
-- Создаем две коллекции
db.createCollection('catalogs')
db.createCollection('products')
-- Заполняем каталоги значениями
db.catalogs.insert({name: 'Процессоры'})
db.catalogs.insert({name: 'Мат.платы'})
db.catalogs.insert({name: 'Видеокарты'})

-- При вставке объектов соответсвующих конкретным продуктам необходимо добавить КЛЮЧ (catalog_id) и ссылаемся по 
-- идентификатору ObjectId("id"), той записи, которая создавалась при внесении соответсвующих разделов каталога.
db.products.insert(
  {
    name: 'Intel Core i3-8100',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 7890.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'Intel Core i5-7400',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 12700.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'ASUS ROG MAXIMUS X HERO',
    description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX',
    price: 19310.00,
    catalog_id: new ObjectId("5b56c74788f700498cbdc56c")
  }
);

db.products.find()

db.products.find({catalog_id: ObjectId("5b56c73f88f700498cbdc56bdb")})


