SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Mettre à jour la colonie dans la base
UPDATE colonie SET rucher_id=$rucher, rang=$rang, couleur=$couleur, modele=$modele, début=$début, reine=$reine, caractere=$caractere, info=$info, disparition=$mort WHERE colonie.numero=$id and $action is not NULL;

-- Enregistrer une intervention sur la ruche
INSERT INTO colvisite(ruche_id, horodatage, details, registre_E, suivi, tracing)
SELECT 
    $id as ruche_id,
    $horodatage as horodatage,
    $details as details,
    coalesce($registre,0) as registre_E,
    $suivi as suivi,
    $Bilan as tracing
    WHERE $Bilan IS NOT NULL; 
    
-- Enregistrer le niveau d'alerte de la ruche
UPDATE colonie SET tracing=$Bilan WHERE colonie.numero=$id and $Bilan is not NULL;

-- Supprime l'inventaire
DELETE FROM inventaire WHERE ruche_id=$id and $inv is not null;
-- Mise à jour de l'inventaire du matériel
INSERT INTO inventaire(ruche_id, element_id)
SELECT
$id as ruche_id,
CAST(value AS integer) as element_id from json_each($element) WHERE :element IS NOT NULL and $inv is not null;

-- Mettre à jour la colonie dans les tables après changement de ruche (colonie et souche + visite de colonie)
UPDATE colonie SET numero=$numero_Div, rucher_id=$rucher_Div, rang=$rang_Div, couleur=$couleur, modele=$modele WHERE colonie.numero=$id and $division is not NULL;
UPDATE colonie SET souche=$numero_Div WHERE colonie.souche=$id and $division is not NULL;
UPDATE colvisite SET ruche_id=$numero_Div WHERE ruche_id=$id and $division is not NULL;
SELECT 'redirect' AS component, 'ruche.sql?id='||$numero_Div AS link
WHERE $division is not NULL;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Colonie'  as title, 'archive' as icon, 1  as active, 'ruche.sql?tab=1&id='||$id as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Éditer' as title, 'pencil' as icon, 0 as active, 'ruche.sql?tab=2&id='||$id as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Souche' as title, 'binary-tree' as icon, 1 as active, 'ruche.sql?tab=3&id='||$id as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Matériel' as title, 'box-align-top-filled' as icon, 1 as active, 'ruche.sql?tab=4&id='||$id as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color;

-- Titre : Ruche
SELECT 'table' as component,
	'Actions' as markdown,
	'Reine' as markdown,
	'Rucher' as markdown,
	'Ruche' as markdown where $tab='2';
SELECT 
    numero as Num,
    '[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=1&id='||colonie.rucher_id||')' as Rucher,
    nom as Rucher,
    rang as Rang,
    '[
    ![](./icons/archive_'||code||'.svg)
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
	FROM colonie JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE colonie.numero=$id and $tab='2';  
	
-- Modifier les infos de la ruche
SET rucher_edit=(SELECT rucher_id from colonie where numero = $id);
SET couleur_edit=(SELECT couleur from colonie where numero = $id);
SET modele_edit=(SELECT modele from colonie where numero = $id);
SET souche_edit=(SELECT souche from colonie where numero = $id);
--SELECT 'text' AS component, $souche_edit AS contents; 

    SELECT 
    'form' as component,
    'ruche.sql?tab=1&action=update&id='||$id as action,
    'Mettre à jour' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset  where $tab='2';
    
    
    SELECT 'Rucher' AS label, 'rucher' AS name, 'select' as type, 4 as width, $rucher_edit::int as value, json_group_array(json_object("label" , nom, "value", id )) as options FROM (select * FROM rucher ORDER BY nom ASC) WHERE $tab='2';
    SELECT 'Rangée' AS label, 'rang' AS name, 'number' as type, 3 as width , rang as value from colonie where numero = $id and $tab='2';
    SELECT 'couleur' AS name, 'select' as type, 2 as width, $couleur_edit::int as value, json_group_array(json_object("label", coloris, "value", id)) as options FROM (select * FROM couleur ORDER BY coloris ASC) WHERE  $tab='2';
    SELECT 'modele' AS name, 'select' as type, 3 as width, $modele_edit::int as value, json_group_array(json_object("label", type, "value", id)) as options FROM (select * FROM modele ORDER BY type ASC), (SELECT modele from colonie where numero = $id) as value WHERE $tab='2';
    SELECT 'Date d''installation' AS label, 'début' AS name, 'date' as type, 4 as width , début as value from colonie where numero = $id and $tab='2';
    SELECT 'Année de la reine' AS label, 'reine' AS name, 'number' as type, '[0-9]{4}' as pattern, 4 as width, reine as value from colonie where numero = $id and $tab='2';
    SELECT 'Mort de la colonie' AS label, 'mort' AS name, CASE WHEN disparition=1 THEN TRUE ELSE '' END as checked, 'checkbox' as type, 1 as value, 4 as width from colonie where numero = $id and $tab='2'; 
 
    SELECT 'Caractères' AS label,'textarea' as type, 'caractere' AS name, 6 as width , caractere as value from colonie where numero = $id and $tab='2';
    SELECT 'Remarques' AS label,'textarea' as type, 'info' AS name, 6 as width , info as value from colonie where numero = $id and $tab='2';    

-- Titre : Ruche
SELECT 'table' as component,
	'Actions' as markdown,
	'État' as markdown,
	'Reine' as markdown,
	'Rucher' as markdown,
	'Ruche' as markdown where $tab<>'2';
SELECT 
    numero as Num,
    '[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=1&id='||colonie.rucher_id||')' as Rucher,
    nom as Rucher,
    rang as Rang,
    '[
    ![](./icons/archive_'||code||'.svg)
]()' as Ruche,
    type as Ruche,
    strftime('%d/%m/%Y',début) as Début,
    '[
    ![](./icons/circle-number-'||substr( reine, -1,1 )||'.svg)
]()' as Reine,
    reine as Reine,
    caractere as Caractères,
    info as infos,
    CASE WHEN disparition=1 THEN
    '[
    ![](./icons/repeat.svg)
](./mortalite/active.sql?tab='||$tab||'&id='||colonie.numero||')'
    ELSE '[
    ![](./icons/repeat.svg)
](./mortalite/disparue.sql?tab='||$tab||'&id='||colonie.numero||')'
     END as État,
    CASE WHEN disparition=1 THEN 'morte' ELSE 'active'
    END as État,
	'[
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||colonie.numero||')[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||')[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||')[
    ![](./icons/status-change.svg)
](ruche_changement.sql?id='||colonie.numero||')' as Actions
	FROM colonie JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE colonie.numero=$id and $tab<>'2';  

-- Onglets : Interventions
select 
    'timeline' as component where $tab='1';
select 
    CASE WHEN rucher_id is not NULL
    THEN 'grip-horizontal'
    ELSE 'archive' 
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
select 
    'divider' as component,
    'Ascendance de la colonie'   as contents
where $tab='3';

SELECT 'table' as component,
       'Actions' as markdown
	where $tab='3';

WITH RECURSIVE ligne(souche, numero, caractere, début, generation) AS (
  SELECT colonie.souche, colonie.numero, colonie.caractere, colonie.début, 0
  FROM   colonie
  WHERE  colonie.numero = $id
UNION
  SELECT colonie.souche, colonie.numero, colonie.caractere, colonie.début, ligne.generation + 1
  FROM   colonie
  INNER JOIN ligne ON ligne.souche = colonie.numero
)
SELECT 
  numero,
  strftime('%d/%m/%Y',début) as Début, 
  caractere as Caractère,
  '[
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||ligne.numero||')' as Actions
FROM ligne
WHERE generation > 0 and $tab='3'
ORDER BY generation DESC;

--
select 
    'divider' as component,
    'Descendance de la colonie'   as contents
where $tab='3';

SELECT 'table' as component,
       'Actions' as markdown
	where $tab='3';
	
WITH RECURSIVE descendance(souche, numero, caractere, début, generation) AS (
    SELECT colonie.souche, colonie.numero, colonie.caractere, colonie.début, 0
  FROM   colonie
  WHERE  colonie.numero = $id
   UNION ALL
  SELECT colonie.souche, colonie.numero, colonie.caractere, colonie.début, descendance.generation + 1
  FROM   colonie
  INNER JOIN descendance ON descendance.numero = colonie.souche
)
 
SELECT 
  descendance.numero,
  strftime('%d/%m/%Y',descendance.début) as Début, 
  descendance.caractere as Caractère,
  '[
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||descendance.numero||')' as Actions
FROM descendance
WHERE generation > 0 and $tab='3'
ORDER BY generation DESC;

 --Élément de ruche
select 
    'card' as component,
     2      as columns
     where $tab='4';
select 
    '/inventaire/liste.sql?id='||$id||'&_sqlpage_embed' as embed
    where $tab='4';
select 
    '/inventaire/form.sql?id='||$id||'&_sqlpage_embed' as embed
    where $tab='4';

