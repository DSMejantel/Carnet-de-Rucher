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

-- Ajouter une récolte
    SELECT 
    'form' as component,
    'Récolte' as id,
    ''     as validate;
    
    SELECT 'Année' AS label, 'annee' AS name, 'number' as type, 3 as width;
    --select 'hidden' as type, 'rucher_id' as name, $id as value;
    SELECT 'Type de miel' AS label, 'produit' AS name, 'select' as type, 6 as width, json_group_array(json_object("label" , categorie, "value", id )) as options FROM (select id, categorie FROM miel);
    SELECT 'Total (en kg)' AS label, 'total' AS name, 'number' as type, TRUE as required, 3 as width;

select 
    'button' as component;
select 
    'rucher.sql?tab=5&production=miel&id='||$id as link,
    'Récolte'            as form,
    'green'          as color,
    'Enregistrer'         as title;

