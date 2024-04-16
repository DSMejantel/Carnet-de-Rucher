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
	 FROM rucher WHERE id=$rucher;

-- Mettre à jour une récolte
SET prod = (SELECT produit from production where production.id=$production);
    SELECT 
    'form' as component,
    'Récolte' as id,
    ''     as validate;
    
    SELECT 'Année' AS label, 'calendar-event' as prefix_icon, 'annee' AS name, 'number' as type, 2 as width, (SELECT annee from production where id=$production) as value;
    SELECT 'Type de miel' AS label, 'produit' AS name, 'select' as type, 4 as width, $prod::int as value, json_group_array(json_object("label" , categorie, "value", id )) as options FROM (select id, categorie FROM miel);
    SELECT 'Total (en kg)' AS label, 'total' AS name, 'number' as type, 'weight' as prefix_icon, TRUE as required, 3 as width, (SELECT total from production where id=$production) as value;
     SELECT 'Lot' AS label, 'lot' AS name, 'text' as type, 'barcode' as prefix_icon, TRUE as required, 3 as width, (SELECT lot from production where id=$production) as value;

select 
    'button' as component;
select 
    'production_update.sql?production='||$production||'&rucher='||$rucher as link,
    'Récolte'            as form,
    'green'          as color,
    'Enregistrer'         as title;
