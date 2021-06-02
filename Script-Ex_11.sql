-- ������������ ������� ���� "����������� ��������"
-- 1. �������� ������� logs ���� Archive. ����� ��� ������ �������� ������ � �������� users,
-- catalogs � products � ������� logs ���������� ����� � ���� �������� ������, ��������
-- �������, ������������� ���������� ����� � ���������� ���� name.

SHOW VARIABLES LIKE 'datadir';-- ������� � ������� ������

CREATE TABLE Logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    created_at datetime DEFAULT CURRENT_TIMESTAMP,
-- ��������������� ������� ��� �������� ������ ����������.
    table_name varchar(50) NOT NULL,
    row_id INT UNSIGNED NOT NULL,
    row_name varchar(255)
) ENGINE = Archive;-- ������������ ���� �������
/*
 * ���� ������ - "������"
 * InnoDB - �� ���������
 * Memory - ��������� ���������� ������ � ����������� ������
 * Archive - ����� ������
 * MyISAM - ������ ����������� � ����������� ����� � ����������� MYD, � ������� � � ����� MYI.

��� �� �������� �������� � ��� ��� ������� (table_name, row_id, row_name) ������� ������� AFTER INSERT 
�� ������ �� ������. 
 */
CREATE TRIGGER products_insert AFTER INSERT ON products
FOR EACH ROW
begin
	/*
	 * ��� ���������� ������ � ������� ������� (users, catalogs � products) � ������� logs ��������� ������ � �������
�������: (NULL, DEFAULT, "��� �������", NEW.id, NEW.name)
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
-- 2. (�� �������) �������� SQL-������, ������� �������� � ������� users ������� �������.
CREATE TABLE samples (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT '��� ����������',
  birthday_at DATE COMMENT '���� ��������',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = '����������';

INSERT INTO samples (name, birthday_at) VALUES
  ('��������', '1990-10-05'),
  ('�������', '1984-11-12'),
  ('���������', '1985-05-20'),
  ('������', '1988-02-14'),
  ('����', '1998-01-12'),
  ('�����', '1992-08-29'),
  ('�������', '1994-03-17'),
  ('�����', '1981-07-10'),
  ('��������', '1988-06-12'),
  ('���������', '1992-09-20');

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



-- ������������ ������� ���� "NoSQL"
-- 1. � ���� ������ Redis ��������� ��������� ��� �������� ��������� � ������������ IP-�������.

/*
 * ������� ��������� IP-�������. � �� ������ ����� IP-����� '127.0.0.1' ������ ����������� ���������, � 1 (�������) 
 * ����������� ��������� � ����� IP-�������.
 */
HINCRBY addresses '127.0.0.1' 1-- ���������� ����������� ��������� � ����� '127.0.0.1' IP-�������, ��������� 1.
HGETALL addresses

HINCRBY addresses '127.0.0.2' 1
HGETALL addresses

HGET addresses '127.0.0.1'-- ��������� ���-�� ��������� �� �����. 



-- 2. ��� ������ ���� ������ Redis ������ ������ ������ ����� ������������ �� ������������
-- ������ � ��������, ����� ������������ ������ ������������ �� ��� �����.

/*���� ������ Redis ��������� ���� ������ �� �����. �� ����� - ����� � �������.
 * ������� ��� ��������� users � emails. � emails ������ ����� 'igor - ��� ����������', � ��������� ������ 
 * ����������� �����. � ��������� users - ��������.
 */
HSET emails 'igor' 'igorsimdyanov@gmail.com'-- 
HSET emails 'sergey' 'sergey@gmail.com'
HSET emails 'olga' 'olga@mail.ru'

HGET emails 'igor'

HSET users 'igorsimdyanov@gmail.com' 'igor'
HSET users 'sergey@gmail.com' 'sergey'
HSET users 'olga@mail.ru' 'olga'

HGET users 'olga@mail.ru'
-- �� ���� �� ��������� ���� � �� �� ������ ������, �� �������� ������� �����.




-- 3. ����������� �������� ��������� � �������� ������� ������� ���� ������ shop � ���� MongoDB.

-- ���� MongoDB - ���������-��������������� �� �� ���� ��� ������������ �����������, ��������� � ��������� �������.
-- ������� ����� ������� ��������� MongoDB, ��� ������. �������� ���-� ������� MySQL

show dbs

use shop
-- ������� ��� ���������
db.createCollection('catalogs')
db.createCollection('products')
-- ��������� �������� ����������
db.catalogs.insert({name: '����������'})
db.catalogs.insert({name: '���.�����'})
db.catalogs.insert({name: '����������'})

-- ��� ������� �������� �������������� ���������� ��������� ���������� �������� ���� (catalog_id) � ��������� �� 
-- �������������� ObjectId("id"), ��� ������, ������� ����������� ��� �������� �������������� �������� ��������.
db.products.insert(
  {
    name: 'Intel Core i3-8100',
    description: '��������� ��� ���������� ������������ �����������, ���������� �� ��������� Intel.',
    price: 7890.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'Intel Core i5-7400',
    description: '��������� ��� ���������� ������������ �����������, ���������� �� ��������� Intel.',
    price: 12700.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'ASUS ROG MAXIMUS X HERO',
    description: '����������� ����� ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX',
    price: 19310.00,
    catalog_id: new ObjectId("5b56c74788f700498cbdc56c")
  }
);

db.products.find()

db.products.find({catalog_id: ObjectId("5b56c73f88f700498cbdc56bdb")})


