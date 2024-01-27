SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Mettre à jour la colonie dans la base
UPDATE colonie SET numero=$numero, rucher_id=$rucher, rang=$rang, couleur=$couleur, modele=$modele, début=$début, reine=$reine, souche=$souche, caractere=$caractere, info=$info WHERE colonie.id=$id and $action is not NULL;
 
-- Enregistrer une intervention sur la ruche
INSERT INTO colvisite(ruche_id, horodatage, details, suivi, tracing)
SELECT 
    $id as ruche_id,
    $horodatage as horodatage,
    $details as details,
    $suivi as suivi,
    $Bilan as tracing
    WHERE $Bilan IS NOT NULL; 
    
-- Enregistrer le niveau d'alerte de la ruche
UPDATE colonie SET tracing=$Bilan WHERE colonie.id=$id and $Bilan is not NULL;

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Colonie'  as title, 'home' as icon, 1  as active, 'ruche.sql?tab=1&id='||$id as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Éditer' as title, 'pencil' as icon, 0 as active, 'ruche.sql?tab=2&id='||$id as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Souche' as title, 'binary-tree' as icon, 1 as active, 'ruche.sql?tab=3&id='||$id as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;

-- Titre : Ruche
SELECT 'table' as component
	WHERE $tab='2';
SELECT 
    numero as Numero,
    nom as Rucher,
    rang as Rangée,
    code as _sqlpage_color,
    type as Ruche,
    début as Début,
    reine as Reine,
    souche as Souche,
    caractere as Caractères,
    info as infos
	FROM colonie JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE colonie.id=$id and $tab='2'; 
	
-- Modifier les infos de la ruche
SET rucher_edit=(SELECT rucher_id from colonie where id = $id);
SET couleur_edit=(SELECT couleur from colonie where id = $id);
SET modele_edit=(SELECT modele from colonie where id = $id);
SET souche_edit=(SELECT souche from colonie where id = $id);

    SELECT 
    'form' as component,
    'ruche.sql?tab=1&action=update&id='||$id as action,
    'Mettre à jour' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset  where $tab='2';
    
    SELECT 'Numéro' AS label, 'numero' AS name, 1 as width, numero as value from colonie where id = $id and $tab='2';
    SELECT 'Rucher' AS label, 'rucher' AS name, 'select' as type, 4 as width, $rucher_edit::int as value, json_group_array(json_object("label" , nom, "value", id )) as options FROM (select * FROM rucher ORDER BY nom ASC) WHERE $tab='2';
    SELECT 'Rangée' AS label, 'rang' AS name, 'number' as type, 2 as width , rang as value from colonie where id = $id and $tab='2';
    SELECT 'couleur' AS name, 'select' as type, 2 as width, $couleur_edit::int as value, json_group_array(json_object("label", coloris, "value", id)) as options FROM (select * FROM couleur ORDER BY coloris ASC) WHERE  $tab='2';
    SELECT 'modele' AS name, 'select' as type, 3 as width, $modele_edit::int as value, json_group_array(json_object("label", type, "value", id)) as options FROM (select * FROM modele ORDER BY type ASC), (SELECT modele from colonie where id = $id) as value WHERE $tab='2';
    SELECT 'Date d''installation' AS label, 'début' AS name, 'date' as type, 4 as width , début as value from colonie where id = $id and $tab='2';
    SELECT 'Année de la reine' AS label, 'reine' AS name, 'number' as type, '[0-9]{4}' as pattern, 4 as width, reine as value from colonie where id = $id and $tab='2';
    SELECT 'souche' AS name, 'select' as type, 4 as width, $souche_edit::int as value,
    json_group_array(json_object("label" , numero, "value", id )) as options FROM (
  SELECT id, numero FROM colonie
  UNION ALL
  SELECT NULL, 'Inconnue'
) , (SELECT souche from colonie where id = $id) as value WHERE $tab='2';
    SELECT 'Caractères' AS label,'textarea' as type, 'caractere' AS name, 6 as width , caractere as value from colonie where id = $id and $tab='2';
    SELECT 'Remarques' AS label,'textarea' as type, 'info' AS name, 6 as width , info as value from colonie where id = $id and $tab='2';    

-- Titre : Ruche
SELECT 'table' as component,
	'Actions' as markdown,
	'Reine' as markdown,
	'Ruche' as markdown where $tab<>'2';
SELECT 
    numero as Num,
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
](ruche.sql?tab=1&id='||colonie.id||')[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.id||')[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.id||')' as Actions
	FROM colonie JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE colonie.id=$id and $tab<>'2';  

-- Onglets : Interventions
select 
    'timeline' as component where $tab='1';
select 
    CASE WHEN rucher_id is not NULL
    THEN 'grip-horizontal'
    ELSE 'home' 
    END as icon,
    CASE WHEN tracing='1' THEN 'green'
    WHEN tracing='2' THEN 'orange' 
    WHEN tracing='3' THEN 'red' 
    END as color,
    action as title,
    strftime('%d/%m/%Y',horodatage) as date,
    details as description
    FROM colvisite INNER JOIN intervention on colvisite.suivi=intervention.id WHERE ruche_id=$id and $tab='1';
    
--Onglets souche
SELECT 'table' as component
	where $tab='3';

WITH RECURSIVE ligne(souche, fille, caractere) AS (

  SELECT colonie.souche, colonie.numero, colonie.caractere
  FROM   colonie

UNION 

  SELECT ligne.souche, colonie.numero, ligne.caractere
  FROM   colonie, ligne
  WHERE  colonie.souche = ligne.fille
)
SELECT 
  ligne.souche as souche,
  strftime('%d/%m/%Y',(SELECT colonie.début FROM colonie WHERE colonie.numero=ligne.souche)) as Début, 
  (SELECT colonie.caractere FROM colonie WHERE colonie.numero=ligne.souche) as Caractère
 FROM ligne JOIN colonie on colonie.numero=ligne.souche WHERE ligne.fille=$id and $tab='3' ORDER BY ligne.souche;


