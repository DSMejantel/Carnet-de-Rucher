SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--Titre
 select 
    'title'   as component,
    'Registre de comptes' as contents,
    TRUE as center,
    3         as level;

select 
    'alert'                     as component,
    'Attention !'                   as title,
    'L''opération ne sera pas effacée totalement de la base. Son montant sera ramené à 0 et l''opération ne sera plus affichée dans le registre. Il restera possible de visualiser les opérations neutralisées sans leur montant initial.' as description,
    'alert-triangle'            as icon,
    'orange'                    as color;
    
select 
    'title'   as component,
    'Neutraliser cette opération ?' as contents,
    TRUE as center,
    4         as level;    

select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'Oui' as title,
    'compta_annulation_confirm.sql?id='||$id as link,
    'coin-off' as icon,
    'green' as outline; 
select 
    'Non' as title,
    '../compta.sql?tab=1' as link,
    'arrow-back-up' as icon,
    'orange' as outline;
    

