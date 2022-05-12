Задание 2
Ниже 2 задачи на проверку знаний SQL.

Для решения заданий следует использовать синтаксис - PostgreSQL.
Ответы нужно представить в виде файла с запросами.

Схема данных = структура Базы данных
● Это название таблицы
○ Это название столбца/колонки

1. Написать 2 SQL запроса для поиска значений среднего и медианы по сумме продажи. Сумму транзакции округляем до целой части. 
Нельзя использовать стандартные функции среднего и медианы в SQL. Можно использовать только агрфункции SUM и COUNT.

Схема данных:
● orders
○ id
○ sale_amount - в центах
○ user_id
○ datetime


SELECT SUM(ROUND(sale_amount)) / COUNT(sale_amount) AS sales_mean
  FROM orders


SELECT SUM(sale_amount_rounded) / COUNT(sale_amount_rounded) AS sales_median
FROM
(
	SELECT ROUND(sale_amount) AS sale_amount_rounded
	 , RANK() OVER(ORDER BY ROUND(sale_amount)) rn
	 , qty
  FROM orders
 CROSS JOIN (SELECT COUNT(*) AS qty FROM orders) sales_qty
) subq
WHERE rn IN (CEIL(qty/2::FLOAT), FLOOR(qty/2::FLOAT + 1));


2. Написать SQL-запрос для поиска задублированных в результате ошибки
транзакций.
Схема данных:
● purchases
○ transaction_id
○ datetime
○ amount
○ user_id


SELECT *
  FROM purchases
 GROUP BY 1, 2, 3, 4
HAVING COUNT(transaction_id) > 1;


3. Написать SQL-запрос для построения воронки перехода из установки в
оформление пробного периода и в покупку платной версии приложения в разрезе
стран. На одного юзера возможна только одно оформление пробного периода и одна
покупка платной версии. Покупка возможна только после истечения срока пробного
периода. На выходе должна получится таблица с колонками “country”, “installs”, “trials”,
“purchases”, “conversion_rate_to_trial”, “conversion_rate_to_purchase”


Схема данных:
● events
○ transaction_id
○ datetime
○ event_type (значение может быть либо “instal”, либо “trial”, либо “purchase”)
○ user_id
○ country

SELECT country
	 , installs
	 , trials
	 , purchases
	 , installs / NULLIF(trials, 0) * 100 AS conversion_rate_to_trial
	 , trials / NULLIF(purchases, 0) * 100 AS conversion_rate_to_purchase
 FROM (
SELECT country
	 , SUM(CASE WHEN event_type = 'instal' THEN 1 ELSE 0 END) AS installs
	 , SUM(CASE WHEN event_type = 'trial' THEN 1 ELSE 0 END) AS trials
	 , SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchases
  FROM events
 GROUP BY country
 ) subq