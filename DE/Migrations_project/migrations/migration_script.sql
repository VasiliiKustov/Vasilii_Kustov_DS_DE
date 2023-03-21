--shipping_country_rates
insert into public.shipping_country_rates 
(shipping_country, shipping_country_base_rate)
select shipping_country,
       shipping_country_base_rate
from (select distinct shipping_country, shipping_country_base_rate from public.shipping) as sub;

--select * from public.shipping_country_rates scr limit 10; 
/*
|id |shipping_country|shipping_country_base_rate|
|---|----------------|--------------------------|
|1  |usa             |0.02                      |
|2  |norway          |0.04                      |
|3  |germany         |0.01                      |
|4  |russia          |0.03                      |
 
 */
--Checking the filling of the table
--shipping_agreement
insert into public.shipping_agreement
(agreementid, agreement_number, agreement_rate, agreement_commission)
select distinct description[1]:: int as agreementid,
       description[2]::text as agreement_number,
       description[3]::numeric(14,2) as agreement_rate,
       description[4]:: numeric(14,2) as agreement_comission
from (select regexp_split_to_array(vendor_agreement_description, E'\\:+') as description
      from public.shipping) as vendor_agreement_information
order by agreementid;
--Checking the filling of the table
--select * from shipping_agreement sa limit 10;
/*
 |agreementid|agreement_number|agreement_rate|agreement_commission|
|-----------|----------------|--------------|--------------------|
|0          |vspn-4092       |0.14          |0.02                |
|1          |vspn-366        |0.13          |0.01                |
|2          |vspn-4148       |0.01          |0.01                |
|3          |vspn-3023       |0.05          |0.01                |
|4          |vspn-1909       |0.03          |0.03                |
|5          |vspn-7339       |0.04          |0.03                |
|6          |vspn-4215       |0.04          |0.01                |
|7          |vspn-1005       |0.08          |0.02                |
|8          |vspn-8118       |0.11          |0.02                |
|9          |vspn-675        |0.15          |0.03                |

 */

--shipping_transfer
insert into public.shipping_transfer
(transfer_type, transfer_model, shipping_transfer_rate)
select description[1]::varchar(2) as transfer_type,
       description[2]::text as transfer_model,
       shipping_transfer_rate::numeric(14,3)
from (select distinct shipping_transfer_rate, regexp_split_to_array(shipping_transfer_description, E'\\:+') as description
      from public.shipping) as shipping_information;

--Checking the filling of the table
--select * from public.shipping_transfer st limit 10;
/*
|id |transfer_type|transfer_model|shipping_transfer_rate|
|---|-------------|--------------|----------------------|
|1  |1p           |multiplie     |0.05                  |
|2  |1p           |ship          |0.03                  |
|3  |3p           |multiplie     |0.045                 |
|4  |3p           |train         |0.02                  |
|5  |1p           |train         |0.025                 |
|6  |3p           |ship          |0.025                 |
|7  |1p           |airplane      |0.04                  |
|8  |3p           |airplane      |0.035                 |

 */
--shipping info
insert into public.shipping_info
(shippingid, shipping_country_id, agreementid, 
 transfer_type_id, shipping_plan_datetime,
 payment_amount, vendorid)
select shippingid, 
       scr.id as shipping_country_id, 
       sa.agreementid, 
       st.id as transfer_type_id,
       shipping_plan_datetime,
       payment_amount,
       vendorid
       from (select distinct shippingid,
                    shipping_country,
                    shipping_country_base_rate,
                    payment_amount,
                    vendorid,
                    (regexp_split_to_array(vendor_agreement_description, E'\\:+'))[1]::int as agreement_id,
                    (regexp_split_to_array(shipping_transfer_description, E'\\:+'))[1] as transfer_type,
                    (regexp_split_to_array(shipping_transfer_description, E'\\:+'))[2] as transfer_model,
                    shipping_plan_datetime
       from shipping s) as t1
       join shipping_agreement sa on t1.agreement_id = sa.agreementid
       join shipping_country_rates scr on t1.shipping_country = scr.shipping_country 
           and t1.shipping_country_base_rate = scr.shipping_country_base_rate
       join shipping_transfer st on t1.transfer_type = st.transfer_type and 
           t1.transfer_model = st.transfer_model
       order by shippingid;

--Checking the filling of the table
--select * from public.shipping_info si limit 10;
/*
|shippingid|shipping_country_id|agreementid|transfer_type_id|shipping_plan_datetime |payment_amount|vendorid|
|----------|-------------------|-----------|----------------|-----------------------|--------------|--------|
|1         |4                  |0          |5               |2021-09-15 16:43:42.434|6.06          |1       |
|2         |1                  |1          |5               |2021-12-12 10:49:50.468|21.93         |1       |
|3         |2                  |2          |7               |2021-10-27 10:33:16.659|3.1           |1       |
|4         |3                  |3          |5               |2021-09-21 10:14:30.148|8.57          |3       |
|5         |2                  |3          |5               |2022-01-02 21:21:08.844|1.5           |3       |
|6         |3                  |0          |7               |2021-11-01 07:05:50.404|3.73          |1       |
|7         |3                  |4          |8               |2021-10-07 23:27:52.573|5.27          |1       |
|8         |3                  |4          |5               |2021-09-03 18:37:43.059|4.79          |1       |
|9         |3                  |4          |5               |2021-09-10 01:29:58.337|5.58          |1       |
|10        |2                  |4          |5               |2021-12-28 14:16:05.720|8.61          |1       |

 */
      
--shipping_status
with last_status as (
   select shippingid,
          state, 
          status, 
          row_number () OVER (PARTITION BY shippingid 
                              ORDER BY state_datetime desc) as rn
   from public.shipping)
insert into public.shipping_status
(shippingid, state, status, shipping_start_fact_datetime, shipping_end_fact_datetime)
select lr.shippingid, 
       lr.state, 
       lr.status, 
       b.state_datetime as shipping_start_fact_datetime, 
       f.state_datetime as shipping_end_fact_datetime
   from last_status as lr
   left outer join (select shippingid, state_datetime
                    from public.shipping s
                    where state = 'booked') as b on lr.shippingid=b.shippingid
   left outer join (select shippingid, state_datetime
                    from public.shipping s
                    where state = 'recieved') as f on lr.shippingid=f.shippingid
   where rn = 1
   order by lr.shippingid;

--Checking the filling of the table
--select * from public.shipping_status ss limit 10;
/*
|shippingid|status  |state   |shipping_start_fact_datetime|shipping_end_fact_datetime|
|----------|--------|--------|----------------------------|--------------------------|
|1         |finished|recieved|2021-09-05 06:42:34.249     |2021-09-15 04:26:57.690   |
|2         |finished|recieved|2021-12-06 22:27:48.306     |2021-12-11 21:00:44.409   |
|3         |finished|recieved|2021-10-26 10:33:16.659     |2021-10-27 04:03:32.884   |
|4         |finished|recieved|2021-09-13 16:21:32.421     |2021-09-19 13:00:30.088   |
|5         |finished|recieved|2021-12-29 14:47:46.141     |2022-01-09 20:21:08.963   |
|6         |finished|recieved|2021-10-31 07:05:50.404     |2021-11-01 02:21:46.579   |
|7         |finished|recieved|2021-10-06 23:27:52.573     |2021-10-07 17:11:07.012   |
|8         |finished|returned|2021-09-02 02:42:48.067     |2021-09-03 11:27:42.602   |
|9         |finished|recieved|2021-09-08 04:47:59.753     |2021-09-09 14:50:14.936   |
|10        |finished|recieved|2021-12-18 09:41:19.969     |2021-12-28 00:55:32.210   |

 */ 