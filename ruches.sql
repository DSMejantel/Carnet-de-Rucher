SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Colonies'  as title, 'archive' as icon, 1  as active, 'ruches.sql?tab=1&id=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Ajouter' as title, 'square-plus' as icon, 0 as active, 'ruches.sql?tab=2&id=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;

 
-- Ruches
-- Enregistrer la colonie dans la base
 INSERT INTO colonie(numero, rucher_id, rang, couleur, modele, début, reine, souche, caractere, info, disparition) SELECT $numero, $rucher, $rang, $couleur, $modele, $début, $reine, $souche, $caractere, $info, 0 WHERE $numero IS NOT NULL;

-- Formulaire d'ajout
    SELECT 
    'form' as component,
    'Créer une ruche' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset  where $tab='2';
    
    SELECT 'Numéro' AS label, 'numero' AS name, 'number' as prefix_icon, TRUE as required, 2 as width where $tab='2';
    SELECT 'Rucher' AS label, 'rucher' AS name, 'select' as type, 3 as width, json_group_array(json_object("label" , nom, "value", id )) as options FROM (select * FROM rucher ORDER BY nom ASC) where $tab='2';
    SELECT 'Rangée' AS label, 'rang' AS name, 'number' as type, 2 as width where $tab='2';
    SELECT 'couleur' AS name, 'select' as type, 2 as width, json_group_array(json_object("label", coloris, "value", id)) as options FROM (select * FROM couleur ORDER BY coloris ASC) where $tab='2';
    SELECT 'modele' AS name, 'select' as type, 3 as width, json_group_array(json_object("label", type, "value", id)) as options FROM (select * FROM modele ORDER BY type ASC) where $tab='2';
    SELECT 'Date d''installation' AS label, 'début' AS name, 'date' as type, 4 as width where $tab='2';
    SELECT 'Année de la reine' AS label, 'reine' AS name, 'number' as type, '2020' as value, 'calendar-event' as prefix_icon, 4 as width where $tab='2';
    SELECT 'souche' AS name, 'select' as type, 4 as width,
    json_group_array(json_object('label' , label, 'value', value )) as options FROM (
  SELECT 'colonie n°'||numero as label, numero as value FROM colonie
  UNION ALL
  SELECT origine as label, NULL as value FROM provenance ORDER BY origine asc
)
 where $tab='2';
    SELECT 'Caractères' AS label,'textarea' as type, 'caractere' AS name, 6 as width where $tab='2';
    SELECT 'Remarques' AS label,'textarea' as type, 'info' AS name, 6 as width where $tab='2';
    
-- Liste
SELECT 'table' as component,
	1 as sort,
	'Alerte' as markdown,
	'Actions' as markdown,
	'Reine' as markdown,
	'Rucher' as markdown,
	'Ruche' as markdown where $tab<>'2';
SELECT 
    CASE WHEN tracing=2
    THEN '[
    ![](./icons/alert-orange.svg)
]()'
    WHEN tracing=3
    THEN '[
    ![](./icons/alert-red.svg)
]()'
    ELSE '[
    ![](./icons/alert-green.svg)
]()'
    END as Alerte,
    numero as Num,
    '[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=1&id='||colonie.rucher_id||')' as Rucher,
    nom as Rucher,
    rang as Rang,
    '[
    ![](./icons/archive_'||code||'.svg)
](ruche.sql?tab=1&id='||colonie.numero||')' as Ruche,
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
](ruche.sql?tab=3&id='||colonie.numero||')' as Actions
	 FROM colonie INNER JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id  where disparition<>1 and $tab='1'  ORDER BY numero::int;


