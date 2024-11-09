SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu_admin.json') AS properties;

-- Description
SELECT 'table' as component,
	'Actions' as markdown;
SELECT 
	nom as Rucher,
	alt as altitude,
	description as description,
	'orange'   as _sqlpage_color,
	'[
    ![](../icons/grip-horizontal.svg)
](../rucher.sql?tab=1&id='||id||')[
    ![](../icons/archive.svg)
](../rucher.sql?tab=2&id='||id||')[
    ![](../icons/tool.svg)
](../intervention_rucher.sql?tab=4&id='||id||')[
    ![](../icons/milk.svg)
](../production_rucher.sql?tab=5&id='||id||')' as Actions
	 FROM rucher WHERE id=$id;

-- Mettre à jour une intervention
SET suivi = (SELECT suivi from ruvisite where id=$intervention);

    SELECT 
    'form' as component,
    'intervention' as id,
    ''     as validate,
    'Recommencer'           as reset;
    
    SELECT 'Date' AS label, 'horodatage' AS name, 'date' as type, 3 as width, (SELECT horodatage from ruvisite where id=$intervention) as value;
    SELECT 'Intervention' AS label, 'suivi' AS name, 'select' as type, 6 as width,  CAST($suivi as integer)  as value, json_group_array(json_object("label" , action, "value", id )) as options FROM (select id, action FROM intervention);
    SELECT 'Inscription au registre d''élevage' AS label, 'registre' AS name, 'checkbox' as type, 1 as value, 3 as width; 
    SELECT 'Détails' AS label, 'details' AS name, 'textarea' as type, TRUE as required, 12 as width, (SELECT details from ruvisite where id=$intervention) as value;

select 
    'button' as component;
select 
    'intervention_ru_update.sql?intervention='||$intervention||'&id='||$id as link,
    'intervention'         as form,
    'green'      as color,
    'Enregistrer'         as title;


