SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Description
SELECT 'table' as component,
	'Actions' as markdown;
SELECT 
	nom as Rucher,
	alt as altitude,
	description as description,
	'[
    ![](./icons/home.svg)
](rucher.sql?tab=1&id='||id||')[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=2&id='||id||')[
    ![](./icons/tool.svg)
](intervention_rucher.sql?tab=4&id='||id||')[
    ![](./icons/milk.svg)
](production_rucher.sql?tab=5&id='||id||')' as Actions
	 FROM rucher WHERE id=$id;

-- Ajouter une intervention
    SELECT 
    'form' as component,
    'intervention' as id,
    ''     as validate,
    'Recommencer'           as reset;
    
    SELECT 'Date' AS label, 'horodatage' AS name, 'date' as type, 3 as width;
    SELECT 'Intervention' AS label, 'suivi' AS name, 'select' as type, 6 as width, json_group_array(json_object("label" , action, "value", id )) as options FROM (select id, action FROM intervention  UNION ALL
  SELECT NULL, 'Aucune'
);
    SELECT 'Détails' AS label, 'details' AS name, 'textarea' as type, TRUE as required, 12 as width;

select 
    'button' as component;
select 
    'rucher.sql?tab=4&id='||$id as link,
    'intervention'         as form,
    'green'      as color,
    'Enregistrer'         as title;
select 
    'rucher.sql?tab=4&action=deploy&id='||$id as link,
    'intervention'            as form,
    'orange'          as color,
    'Déployer sur toutes les ruches'         as title;

