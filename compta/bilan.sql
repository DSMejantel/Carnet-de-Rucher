SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

   
select 
    'datagrid' as component;

select 
    'Bilan financier global ' as title,
    CASE WHEN sum(prix)<0 Then 'red' ELSE 'green'
    END as color,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances;
