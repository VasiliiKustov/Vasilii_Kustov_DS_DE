insert into analysis.dm_rfm_segments
with 
rfm_row as (SELECT user_id,
                    current_date - MAX(order_ts) AS R,
       				COUNT(*) AS F,
       				SUM(payment) AS M
		     FROM analysis.orders
			 where status = '4'
             GROUP BY user_id
		     order by user_id desc)
SELECT user_id,
	   NTILE(5) OVER(ORDER BY R desc) as recency,
	   NTILE(5) OVER(ORDER BY F) as frequency,
	   NTILE(5) OVER(ORDER BY M) as monetary_value
FROM rfm_row
order by user_id;


'''
The first 20 lines of the resulting showcase.
|user_id|recency|frequency|monetary_value|
|-------|-------|---------|--------------|
|0      |1      |3        |4             |
|1      |4      |3        |3             |
|2      |2      |3        |5             |
|3      |2      |3        |3             |
|4      |4      |4        |3             |
|5      |5      |5        |5             |
|6      |1      |3        |5             |
|7      |4      |2        |2             |
|8      |1      |1        |3             |
|9      |1      |2        |2             |
|10     |3      |4        |2             |
|11     |3      |5        |5             |
|12     |3      |2        |1             |
|13     |4      |1        |1             |
|14     |4      |4        |1             |
|15     |4      |5        |5             |
|16     |5      |4        |4             |
|17     |2      |3        |4             |
|18     |1      |5        |4             |
|19     |4      |5        |5             |

'''