SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Titre : Ruche
SELECT 'table' as component,
	'Actions' as markdown,
	'Reine' as markdown,
	'Rucher' as markdown,
	'Ruche' as markdown;
SELECT 
    numero as Num,
    '[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=1&id='||colonie.rucher_id||')' as Rucher,
    nom as Rucher,
    rang as Rang,
    '[
    ![](./icons/home_'||code||'.svg)
]()' as Ruche,
    type as Ruche,
    strftime('%d/%m/%Y',début) as Début,
    '[
    ![](./icons/circle-number-'||substr( reine, -1,1 )||'.svg)
]()' as Reine,
    reine as Reine,
    caractere as Caractères,
    info as infos,
	'[
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||colonie.numero||')[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||')[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||')[
    ![](./icons/status-change.svg)
](ruche_changement.sql?id='||colonie.numero||')' as Actions
	FROM colonie JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE colonie.numero=$id; 
	
-- Modifier les infos de la ruche
SET rucher_edit=(SELECT rucher_id from colonie where numero = $id);

    SELECT 
    'form' as component,
    'ruche.sql?tab=1&division=chgmt&id='||$id as action,
    'Mettre à jour' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;
    
    SELECT 'Numéro' AS label, 'numero_Div' AS name, 1 as width;
    SELECT 'Rucher' AS label, 'rucher_Div' AS name, 'select' as type, 4 as width, $rucher_edit::int as value, json_group_array(json_object("label" , nom, "value", id )) as options FROM (select * FROM rucher ORDER BY nom ASC);
    SELECT 'Rangée' AS label, 'rang_Div' AS name, 'number' as type, 2 as width;
    SELECT 'couleur' AS name, 'select' as type, 6 as width, json_group_array(json_object("label", coloris, "value", id)) as options FROM (select * FROM couleur ORDER BY coloris ASC);
    SELECT 'modele' AS name, 'select' as type, 6 as width, json_group_array(json_object("label", type, "value", id)) as options FROM (select * FROM modele ORDER BY type ASC);

