SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

 select 
    'title'   as component,
    'Visualisation' as contents,
    TRUE as center,
    3         as level;
-- Liste des actions
select 
    'button' as component,
    'center' as justify;
select 
    'compta.sql?tab=1'  as link,
    'An'         as form,
    'green'      as color,
    TRUE as space_after,
    'Voir l''année sélectionnée'         as title;
    
select 
    'Opérations annulées' as title,
    'compta.sql?tab=4' as link,
    'coin-off' as icon,
    'red' as outline; 

