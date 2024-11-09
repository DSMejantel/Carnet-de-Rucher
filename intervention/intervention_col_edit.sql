SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu_admin.json') AS properties;

-- Description
-- Titre : Ruche
SELECT 'table' as component,
	'Actions' as markdown,
	'Reine' as markdown,
	'Rucher' as markdown,
	'Ruche' as markdown;
SELECT 
    numero as Num,
    '[
    ![](../icons/grip-horizontal.svg)
](../rucher.sql?tab=1&id='||colonie.rucher_id||')' as Rucher,
    nom as Rucher,
    rang as Rang,
    '[
    ![](../icons/archive_'||code||'.svg)
]()' as Ruche,
    type as Ruche,
    strftime('%d/%m/%Y',début) as Début,
    '[
    ![](../icons/circle-number-'||substr( reine, -1,1 )||'.svg)
]()' as Reine,
    reine as Reine,
    caractere as Caractères,
    info as infos,
	'[
    ![](../icons/eye.svg)
](../ruche.sql?tab=1&id='||colonie.numero||')[
    ![](../icons/pencil.svg)
](../ruche.sql?tab=2&id='||colonie.numero||')[
    ![](../icons/tool.svg)
](../intervention_col.sql?id='||colonie.numero||')[
    ![](../icons/status-change.svg)
](../ruche_changement.sql?id='||colonie.numero||')' as Actions
	FROM colonie JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE colonie.numero=$id; 

-- Mettre à jour une intervention
SET suivi = (SELECT suivi from colvisite where id=$intervention);

    SELECT 
    'form' as component,
    'intervention' as id,
    ''     as validate,
    'Recommencer'           as reset;
    
    SELECT 'Date' AS label, 'horodatage' AS name, 'date' as type, 3 as width, (SELECT horodatage from colvisite where id=$intervention) as value;
    SELECT 'Intervention' AS label, 'suivi' AS name, 'select' as type, 6 as width, CAST($suivi as integer) as value, json_group_array(json_object("label" , action, "value", id )) as options FROM (select id, action FROM intervention);
    SELECT 'Inscription au registre d''élevage' AS label, 'registre' AS name, 'checkbox' as type, 1 as value, 3 as width; 
    SELECT 'Détails' AS label, 'details' AS name, 'textarea' as type, TRUE as required, 12 as width, (SELECT details from colvisite where id=$intervention) as value;

select 
    'button' as component;
select 
    'intervention_col_update.sql?intervention='||$intervention||'&id='||$id as link,
    'intervention'         as form,
    'green'      as color,
    'Enregistrer'         as title;


