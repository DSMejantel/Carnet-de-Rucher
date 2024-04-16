SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--Titre
 select 
    'title'   as component,
    'Registre d''élevage' as contents,
    TRUE as center,
    3         as level;   
        
--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Ruchers'  as title, 'home' as icon, 1  as active, 'elevage.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Ruches' as title, 'archive' as icon, 0 as active, 'elevage.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;

-- Onglets : Interventions sur ruchers
select 
    'table' as component,
    TRUE    as sort,
    TRUE    as search
    where $tab='1';
select 
    strftime('%d/%m/%Y',horodatage) as date,
    nom as Rucher,
    action as Interventions,
    details as Descriptions
    FROM ruvisite INNER JOIN intervention on ruvisite.suivi=intervention.id JOIN rucher on ruvisite.rucher_id=rucher.id WHERE ruvisite.registre_E=1 and $tab='1' ORDER by horodatage;

-- Onglets : Interventions sur ruches
select 
    'table' as component,
    TRUE    as sort,
    TRUE    as search
    where $tab='2';
select 
    strftime('%d/%m/%Y',horodatage) as date,
    numero as Ruche,
    action as Interventions,
    details as Descriptions
    FROM colvisite INNER JOIN intervention on colvisite.suivi=intervention.id JOIN colonie on colvisite.ruche_id=colonie.numero WHERE colvisite.registre_E=1 and $tab='2' ORDER by horodatage;




    



    

