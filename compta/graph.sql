SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

   
select 
    'chart' as component,
    'red' as color,
    TRUE as labels,
    'green' as color,
    'bar'      as type;

select 
    categorie as series,
    strftime('%Y',date_created) as x,
    CASE WHEN sum(prix)>0
    THEN  sum(prix)
    ELSE sum(prix)*(-1)
    END as y
    FROM finances group by strftime('%Y',date_created), categorie order by date_created;
