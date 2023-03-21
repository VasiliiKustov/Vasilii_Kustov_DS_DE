--showcase creation
drop view if exists shipping_datamart;
create view shipping_datamart as
(select si.shippingid,
        si.vendorid,
        st.transfer_type,
        date_part('day', age(ss.shipping_end_fact_datetime,ss.shipping_start_fact_datetime))::int as full_day_at_shipping,
        case
        	when ss.shipping_end_fact_datetime > si.shipping_plan_datetime then 1
       	else 0
        end as is_delay,
        case
        	when ss.status = 'finished' then 1
       	else 0
        end as is_shipping_finished,
        case
        	when ss.shipping_end_fact_datetime > si.shipping_plan_datetime then 
       	    date_part('day', age(ss.shipping_end_fact_datetime, si.shipping_plan_datetime))::int
       	else 0
        end as delay_day_at_shipping,
        si.payment_amount,
        (si.payment_amount*(scr.shipping_country_base_rate + sa.agreement_rate + st.shipping_transfer_rate))::numeric(14,5) as vat,
        (si.payment_amount*agreement_commission)::numeric(14,5) as profit 
from public.shipping_info as si
left outer join public.shipping_status ss on si.shippingid = ss.shippingid
left outer join public.shipping_transfer st on si.transfer_type_id = st.id
left outer join public.shipping_country_rates scr on si.shipping_country_id = scr.id
left outer join public.shipping_agreement sa on si.agreementid = sa.agreementid); 

--Checking the filling of the showcase
--select * 
--from public.shipping_datamart sd
--limit 30;
/*
|shippingid|vendorid|transfer_type|full_day_at_shipping|is_delay|is_shipping_finished|delay_day_at_shipping|payment_amount|vat    |profit|
|----------|--------|-------------|--------------------|--------|--------------------|---------------------|--------------|-------|------|
|2         |1       |1p           |4                   |0       |1                   |0                    |21.93         |3.83775|0.2193|
|4         |3       |1p           |5                   |0       |1                   |0                    |8.57          |0.72845|0.0857|
|6         |1       |1p           |0                   |0       |1                   |0                    |3.73          |0.7087 |0.0746|
|7         |1       |3p           |0                   |0       |1                   |0                    |5.27          |0.39525|0.1581|
|8         |1       |1p           |1                   |0       |1                   |0                    |4.79          |0.31135|0.1437|
|9         |1       |1p           |1                   |0       |1                   |0                    |5.58          |0.3627 |0.1674|
|10        |1       |1p           |9                   |0       |1                   |0                    |8.61          |0.81795|0.2583|
|11        |3       |1p           |2                   |0       |1                   |0                    |2.38          |0.1785 |0.0714|
|13        |3       |1p           |0                   |0       |1                   |0                    |6.04          |0.7852 |0.1208|
|16        |2       |3p           |1                   |0       |1                   |0                    |7.9           |1.185  |0.158 |
|17        |3       |3p           |4                   |0       |1                   |0                    |4.66          |0.3728 |0.0466|
|18        |3       |1p           |0                   |0       |1                   |0                    |7.34          |0.734  |0.0734|
|19        |1       |3p           |1                   |0       |1                   |0                    |2.01          |0.3618 |0.0402|
|21        |3       |1p           |9                   |0       |1                   |0                    |1.74          |0.1653 |0.0174|
|22        |1       |3p           |16                  |0       |1                   |0                    |10.56         |1.9536 |0.1056|
|24        |1       |1p           |1                   |0       |1                   |0                    |2.12          |0.4134 |0.0424|
|25        |2       |3p           |0                   |0       |1                   |0                    |1.94          |0.3783 |0.0582|
|29        |2       |1p           |3                   |0       |1                   |0                    |30.85         |6.63275|0.9255|
|30        |1       |3p           |3                   |0       |1                   |0                    |5.01          |0.9519 |0.1002|
|31        |2       |1p           |2                   |0       |1                   |0                    |5.09          |0.83985|0.1527|
|39        |3       |1p           |0                   |0       |1                   |0                    |3.81          |0.4953 |0.0762|
|42        |3       |3p           |9                   |1       |1                   |7                    |2.06          |0.1648 |0.0206|
|43        |2       |3p           |2                   |0       |1                   |0                    |4.76          |0.952  |0.1428|
|44        |3       |3p           |11                  |1       |1                   |8                    |2.88          |0.2592 |0.0864|
|45        |2       |1p           |5                   |0       |1                   |0                    |11.36         |1.8744 |0.3408|
|46        |2       |3p           |3                   |0       |1                   |0                    |4.74          |0.7584 |0.1422|
|49        |3       |1p           |6                   |0       |1                   |0                    |6.76          |0.9126 |0.1352|
|52        |1       |1p           |4                   |0       |1                   |0                    |9.55          |0.71625|0.2865|
|53        |1       |1p           |2                   |0       |1                   |0                    |3             |0.135  |0.03  |
|55        |3       |3p           |0                   |0       |1                   |0                    |5.84          |0.9052 |0.1168|
*/
