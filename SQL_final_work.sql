=================================== РАЗДЕЛ 2: ЗАПРОСЫ ===================================

Вопрос № 1: В каких городах больше одного аэропорта?

Решение (запрос):

SELECT city, COUNT(*) AS airports_amount
FROM airports 
GROUP BY city 
HAVING COUNT(*) > 1;

Логика запроса:
1. Обращаемся к таблице airports, группируем (GROUP BY) строки по значению атрибута city. 
2. Для каждой из групп проверяем (HAVING), где количество строк с одинаковым атрибутом 
city больше 1.
3. Выводим названия городов и количество аэропортов.

Вопрос № 2: В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью 
перелета? В решении обязательно должен быть использован подзапрос.

Решение (запрос):

SELECT DISTINCT airports.airport_name, f.departure_airport
FROM (SELECT aircraft_code, "range"
	FROM aircrafts
	ORDER BY "range" DESC
	LIMIT 1) q 
JOIN flights f ON q.aircraft_code = f.aircraft_code
JOIN airports ON airports.airport_code = f.departure_airport

Логика запроса:
1. Из формулировки вопроса следует, что при его решении нам потребуется использовать данные 
минимум из двух таблиц: самолеты (aircrafts) и полеты (flights). Но если мы хотим вывести в 
добавок название аэропорта (airport_name), то нам будет необходимо также использовать данные 
таблицы аэропорты (airports). 
2. Сперва напишем подзапрос для поиска в таблице самолеты (aircrafts) самолета с максимальной 
дальностью перелета, выведем код этого самолета (aircraft_code) и дальность его перелета 
(range). Для этого нам потребуется отсортировать самолеты по дальности перелета в обратном 
порядке (DESC), а затем использовать оператор  LIMIT со значением 1, чтобы в результате 
остался единственный самолет, дальность перелета которого будет самой большой. 
3. В результирующем запросе нам нужно вывести аэропорты, при этом в задании не уточняется, 
имеется ли в виду название аэропорта (airport_name) из таблицы airports или же речь идёт про 
трехбуквенный код аэропорта отправления (departure_airport) / аэропорта прибытия 
(arrival_airport) из таблицы flights. В связи с этим присоединим обе эти таблицы, чтобы п
олучить и названия аэропортов, и их трехбуквенные коды. По какому аэропорту (departure_airport 
или arrival_airport) нам присоединять таблицу airports значения не имеет, т.к. из описания 
таблицы flights следует, что рейс всегда соединяет две точки - аэропорты вылета и прибытия, 
а такое понятие как рейс с пересадками отсутствует.
4. Для получения уникальных данных в результирующем запросе используем оператор DISTINCT.

Вопрос № 3: Вывести 10 рейсов с максимальным временем задержки вылета. В решении обязательно 
должен быть использован оператор LIMIT.

Решение (запрос):

SELECT flight_id, actual_departure - scheduled_departure AS delay
FROM flights
WHERE actual_departure IS NOT NULL
ORDER BY delay DESC
LIMIT 10

Логика запроса:
1. При решении мы будем исходить из того, что задержка вылета (назовем ее delay) - это разность 
между фактическим временем вылета и временем вылета по расписанию. Вместе с delay будем выводить 
flight_id, так как под перелетом (рейсом) мы понимаем именно flight_id.
2. При решении задачи нам нужно учесть, что рейс может не отставать от расписания, т.е. не иметь 
задержки (delay). Из описания таблицы flights мы также видим, что столбец actual_departure 
допускает значения NULL. Отсеять все строки столбца actual_departure со значением NULL мы сможем 
при помощи оператора WHERE, после которого пропишем: actual_departure IS NOT NULL.
3. Чтобы получить топ 10 рейсов с максимальным временем задержки, нам нужно отсортировать 
полученный в шагах 1 и 2 результат по столбцу delay в обратном порядке (DESC), а затем использовать 
оператор LIMIT со значением 10.

Вопрос № 4: Были ли брони, по которым не были получены посадочные талоны? В решении нужно 
использовать верный тип JOIN.

Решение (запрос):

Вариант 1: Выводим список броней без полученных посадочных талонов
SELECT b.book_ref, bp.boarding_no
FROM bookings b
JOIN tickets t ON b.book_ref = t.book_ref
LEFT JOIN boarding_passes bp ON t.ticket_no = bp.ticket_no
WHERE bp.boarding_no IS NULL

Вариант 2: Выводим общее количество броней без посадочных талонов
SELECT bp.boarding_no, COUNT(b.book_ref) AS amount
FROM bookings b
JOIN tickets t ON b.book_ref = t.book_ref
LEFT JOIN boarding_passes bp ON bp.ticket_no = t.ticket_no
WHERE bp.boarding_no IS NULL
GROUP BY bp.boarding_no

Логика запроса:
1. Из условий задачи следует, что нам нужно проверить, были ли такие бронирования, значение 
посадочных талонов по которым отсутствовало, т.е. было NULL.
2. Для ответа на вопрос задания нам нужно присоединить к таблице bookings через таблицу tickets 
таблицу boarding_passes, содержащую информацию о посадочных талонах.
3. Таблицу tickets присоединяем оператором JOIN, а таблицу boarding_passes - оператором LEFT JOIN, 
поскольку нам нужно получить все возможное количество броней (в т.ч. со значением NULL), чтобы затем 
отобрать те брони, по которым не были получены посадочные талоны.
4. Для отбора броней, по которым посадочные талоны получены не были, используем оператор WHERE с 
оператором IS NULL.
5. Чтобы подсчитать общее количество броней без посадочных талонов (Вариант 2), дополнительно 
проводим группировку по столбцу bp.boarding_no, а для подсчета количества строк используем оператор 
COUNT.

Вопрос № 5: Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству 
мест в самолете. Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных 
пассажиров из каждого аэропорта на каждый день. Т.е. в этом столбце должна отражаться накопительная 
сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течение 
дня. В решении нужно использовать оконную функцию, подзапросы и (или) СТЕ.

Решение (запрос):
WITH aircraft_seats AS (
	SELECT aircraft_code, COUNT(seat_no) AS seats_amount
	FROM seats
	GROUP BY aircraft_code
),
issued_passes AS (
SELECT f.flight_id, f.flight_no, f.aircraft_code, f.departure_airport, f.scheduled_departure, 
f.actual_departure, COUNT(bp.boarding_no) AS issued_passes
FROM flights f
JOIN boarding_passes bp ON f.flight_id = bp.flight_id
WHERE f.actual_departure IS NOT NULL
GROUP BY f.flight_id
)
SELECT 
cte2.flight_id,
cte2.flight_no,
cte2.departure_airport,
cte2.scheduled_departure,
cte2.actual_departure,
cte1.seats_amount,
cte2.issued_passes, 
cte1.seats_amount - cte2.issued_passes AS free_seats, 
ROUND(((cte1.seats_amount - cte2.issued_passes) / cte1.seats_amount::numeric(5, 2)), 4) * 100 AS 
"free_seats (%)",
SUM(cte2.issued_passes) OVER(PARTITION BY(cte2.departure_airport, cte2.actual_departure::date) 
ORDER BY cte2.actual_departure) AS cumulative_total
FROM issued_passes AS cte2
JOIN aircraft_seats AS cte1 ON cte2.aircraft_code = cte1.aircraft_code;

Логика запроса:
1. Наиболее удобно решать задачу через СТЕ, на мой взгляд. Первым СТЕ (aircraft_seats) посчитаем общее 
количество мест в каждом самолете (модели самолета).
2. Вторым СТЕ (issued_passes) найдем количество выданных посадочных талонов для каждого рейса. Для этого 
присоединим к таблице полеты (flights) таблицу посадочные талоны (boarding_passes). При этом нас 
интересуют только те рейсы, которые фактически вылетели, для чего прописываем в операторе WHERE условие 
f.actual_departure IS NOT NULL.
3. В результирующем запросе присоединяем к СТЕ issued_passes наше первое СТЕ (aircraft_seats) и 
производим необходимые вычисления:
4.1. От общего количества мест в самолете отнимаем общее количество выданных посадочных талонов и 
получаем количество свободных мест в самолете.
4.2. Вычисляем процентное соотношение свободных мест к общему количеству мест в самолете, для этого 
делим количество свободных мест на общее количество мест в самолете и умножаем полученный результат 
на 100%. Округляем полученный результат с помощью функции ROUND.
4.3. Теперь самое сложное. Для подсчета вывезенных пассажиров накопительным итогом за день используем 
оконную функцию SUM, группируем данные в окне по аэропорту отправления (cte2.departure_airport) и 
фактическому времени вылета (cte2.actual_departure::date), которое приводим к типу “дата” (т.к. копим 
пассажиров за день), затем сортируем по времени вылета.

Вопрос № 6: Найдите процентное соотношение перелетов по типам самолетов от общего количества. В решении 
нужно использовать оконную функцию или подзапрос, а также оператор ROUND.

Решение (запрос):

SELECT q.model, ROUND(amount / (SUM(amount) OVER()), 4) * 100 AS "flights (%)"
FROM(
	SELECT a.model, COUNT(flight_id) AS amount
	FROM flights f 
	JOIN aircrafts a ON f.aircraft_code = a.aircraft_code
	GROUP BY a.model
) q

Логика запроса:
1. Для начала вычислим количество перелетов для каждого самолета (amount) среди всех перелетов. Присоединяем 
к таблице flights таблицу aircrafts, группируем данные по столбцу a.model, затем оператором COUNT подсчитываем 
количество перелетов по каждому самолету.
2. Чтобы найти процентное соотношение перелетов по каждому самолету, нам нужно разделить количество перелетов 
каждого самолета на общее количество перелетов и умножить результат деления на 100%. Для подсчета общего 
количества перелетов используем оконную функцию SUM(amount) OVER(). Так как разделение внутри окна нам не 
нужно, скобки после OVER оставляем пустыми.
3. Результат вычислений округляем с помощью функции ROUND до четырех знаков после запятой - чтобы снизить 
погрешность вычислений.

Вопрос № 7: Были ли города, в которые можно добраться бизнес-классом дешевле, чем эконом-классом в рамках 
перелета? В решении нужно использовать СТЕ.

Решение (запрос):
WITH cte_economy AS (
	SELECT DISTINCT flight_id, fare_conditions, MAX(amount) AS economy_price  
	FROM ticket_flights
	WHERE fare_conditions = 'Economy'
	GROUP BY flight_id, fare_conditions 
	ORDER BY flight_id
),
cte_business AS (
	SELECT DISTINCT flight_id, fare_conditions, MIN(amount) AS business_price 
	FROM ticket_flights
	WHERE fare_conditions = 'Business'
	GROUP BY flight_id, fare_conditions 
	ORDER BY flight_id
)
SELECT a.city, cte_business.business_price, cte_economy.economy_price
FROM cte_economy
JOIN cte_business ON cte_economy.flight_id = cte_business.flight_id
JOIN flights f ON cte_economy.flight_id = f.flight_id
JOIN airports a ON f.arrival_airport = a.airport_code
WHERE business_price < economy_price

Логика запроса:
1. Используя СТЕ, сначала в таблице ticket_flights найдем максимальную стоимость билета класса эконом в рамках 
перелета (cte_economy), а затем найдем минимальную стоимость билета бизнес-класса (cte_business) в рамках того 
же перелета. Максимальную стоимость эконома и минимальную стоимость бизнеса ищем для, условно говоря, создания 
условий для их пересечения, и, тем самым, ещё снижаем нагрузку на БД. 
2. Затем присоединяем к нашим СТЕ таблицу airports через таблицу flights (присоединяем её по аэропорту прибытия).
3. В результирующем запросе используем оператор WHERE, где прописываем условие для выборки городов business_price 
< economy_price, тем самым сравниваем стоимость билета класса эконом с классом бизнес в рамках перелета, и, если 
условие в операторе WHERE выполнится, то мы получим список городов, по которым наше условие отработало. Пока таких 
городов нет.

Вопрос № 8: Между какими городами нет прямых рейсов? В решении нужно использовать декартово произведение в 
предложении FROM, а также самостоятельно созданные представления (если облачное подключение, то без представления), 
оператор EXCEPT.

Решение (запрос):

CREATE VIEW cities_view AS
SELECT a1.city AS dep_city, a2.city AS arr_city
FROM flights f
JOIN airports a1 ON f.departure_airport = a1.airport_code
JOIN airports a2 ON f.arrival_airport = a2.airport_code;

SELECT a1.city AS dep_city, a2.city AS arr_city
FROM airports AS a1
CROSS JOIN airports AS a2
WHERE a1.city != a2.city AND a1.city > a2.city
EXCEPT
SELECT * FROM cities_view

Логика запроса:
1. Создаем представление cities_view, куда добавляем все возможные комбинации городов, для чего дважды 
присоединяем к таблице flights таблицу airports, чтобы получить связку “город отправления - город прибытия”.
2. В результирующем запросе используем декартово произведение (CROSS JOIN) по таблице airports с условием 
неравенства городов (WHERE a1.city != a2.city) и условием, которое позволит избавить нас от пар “городов-перевертышей” 
(AND a1.city > a2.city).
3. Затем из результирующего запроса с помощью оператора EXCEPT убираю данные представления cities_view.
