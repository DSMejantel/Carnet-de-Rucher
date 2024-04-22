SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Enregistrer une intervention sur le rucher
INSERT INTO ruvisite(rucher_id, horodatage, details, registre_E, suivi)
SELECT 
    $id as rucher_id,
    $horodatage as horodatage,
    $details as details,
    coalesce($registre,0) as registre_E,
    $suivi as suivi
    WHERE $details IS NOT NULL; 

SET visite = (SELECT last_insert_rowid() FROM ruvisite);
-- Enregistrer une intervention sur les ruches
INSERT INTO colvisite(rucher_id, horodatage, details, suivi, ruche_id)
SELECT 
    ruvisite.rucher_id as rucher_id,
    ruvisite.horodatage as horodatage,
    ruvisite.details as details,
    ruvisite.suivi as suivi,
    colonie.numero as ruche_id
    FROM ruvisite INNER JOIN colonie WHERE colonie.rucher_id=$id and ruvisite.id=$visite and $action is not NULL and $details IS NOT NULL;  

-- Enregistrer une récolte sur le rucher
INSERT INTO production(annee, rucher_id, produit, total, lot)
SELECT 
    $annee as annee,
    $id as rucher_id,
    $produit as produit,
    $total as total,
    $lot as lot
    WHERE $total IS NOT NULL; 
    
--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Description'  as title, 'home' as icon, 1  as active, 'rucher.sql?tab=1&id='||$id as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Ruches' as title, 'archive' as icon, 0 as active, 'rucher.sql?tab=2&id='||$id as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Ajouter colonie' as title, 'square-plus' as icon, 0 as active, 'rucher.sql?tab=3&id='||$id as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Interventions' as title, 'tool' as icon, 1 as active, 'rucher.sql?tab=4&id='||$id as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color;
select  'Production' as title, 'flower' as icon, 1 as active, 'rucher.sql?tab=5&id='||$id as link, CASE WHEN $tab='5' THEN 'orange' ELSE 'green' END as color;

-- Ruches
-- Enregistrer la colonie dans la base
 INSERT INTO colonie(numero, rucher_id, rang, couleur, modele, début, reine, souche, caractere, info, disparition) SELECT $numero, $rucher, $rang, $couleur, $modele, $début, $reine, $souche, $caractere, $info, 0 WHERE $numero IS NOT NULL;

-- Formulaire d'ajout
    SELECT 
    'form' as component,
    'Créer une ruche' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset
     WHERE $tab='3';
    
    SELECT 'Numéro' AS label, 'numero' AS name, 'number' as prefix_icon, TRUE as required, 2 as width WHERE $tab='3';
    SELECT 'Rucher' AS label, 'rucher' AS name, 'select' as type, 3 as width, $id::integer as value,
    json_group_array(json_object("label" , nom, "value", id )) as options FROM (select * FROM rucher ORDER BY nom ASC) WHERE $tab='3';
    SELECT 'Rangée' AS label, 'rang' AS name, 'number' as type, 2 as width WHERE $tab='3';
    SELECT 'couleur' AS name, 'select' as type, 2 as width, json_group_array(json_object("label", coloris, "value", id)) as options FROM (select * FROM couleur ORDER BY coloris ASC) WHERE $tab='3';
    SELECT 'modele' AS name, 'select' as type, 3 as width, json_group_array(json_object("label", type, "value", id)) as options FROM (select * FROM modele ORDER BY type ASC) WHERE $tab='3';
    SELECT 'Date d''installation' AS label, 'début' AS name, 'date' as type, 4 as width WHERE $tab='3';
    SELECT 'Année de la reine' AS label, 'reine' AS name, 'number' as type, 'calendar-event' as prefix_icon, '2020' as value, '[0-9]{4}' as pattern, 4 as width WHERE $tab='3';
    SELECT 'souche' AS name, 'select' as type, 4 as width,
    json_group_array(json_object('label' , label, 'value', value )) as options FROM (
  SELECT 'colonie n°'||numero as label, numero as value FROM colonie
  UNION ALL
  SELECT origine as label, NULL as value FROM provenance ORDER BY origine asc
) WHERE $tab='3';
    SELECT 'Caractères' AS label,'textarea' as type, 'caractere' AS name, 6 as width WHERE $tab='3';
    SELECT 'Remarques' AS label,'textarea' as type, 'info' AS name, 6 as width WHERE $tab='3';

-- Description
SELECT 'table' as component,
	'Actions' as markdown;
SELECT 
	nom as Rucher,
	alt as altitude,
	description as description,
	'orange'   as _sqlpage_color,
	'[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=1&id='||id||')[
    ![](./icons/archive.svg)
](rucher.sql?tab=2&id='||id||')[
    ![](./icons/tool.svg)
](intervention_rucher.sql?tab=4&id='||id||')[
    ![](./icons/milk.svg)
](production_rucher.sql?tab=5&id='||id||')' as Actions
	 FROM rucher WHERE id=$id;

select 
    'tracking'       as component,
    'état du rucher : '||' '||(SELECT count(distinct numero)||' ruche(s)' FROM colonie WHERE colonie.rucher_id=$id) as title,
    'bottom'            as placement,
    12               as width
    WHERE $tab='1';
select 
    CASE WHEN colonie.tracing=2
    THEN 'warning'
    WHEN colonie.tracing=3
    THEN 'danger'
    ELSE 'success'
    END as color,
    'ruche n°'||numero||' (rangée '||rang||')' as title
    FROM colonie LEFT JOIN colvisite on colonie.numero=colvisite.ruche_id WHERE colonie.rucher_id=$id and $tab='1' GROUP BY colonie.numero  ORDER BY rang ;	 

-- Carte
select 
    'button' as component WHERE $tab='1';
select 
    'rucher.sql?tab=1&aire=1&id='||$id as link,
    'Afficher l''aire de butinage'            as title,
    'eye'  as icon,
    CASE WHEN $aire=1
    THEN TRUE
    ELSE FALSE
    END as disabled
    WHERE $tab='1';
select 
    'rucher.sql?tab=1&aire=0&id='||$id as link,     
    'Masquer l''aire de butinage' as title,
    'eye-off'  as icon,
    CASE WHEN $aire<>1 or $aire is Null
    THEN TRUE
    ELSE FALSE
    END as disabled
    WHERE $tab='1';
SELECT 
    'map' as component,
    13 as zoom,
    Lat as latitude,
    Lon as longitude,
    600 as height,
    'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png' as tile_source,
    ''    as attribution
    FROM rucher WHERE id=$id and $tab='1'; 

SELECT
    nom as title,
    Lat AS latitude, 
    Lon AS longitude,
    'home' as icon
    FROM rucher WHERE id=$id and $tab='1'; 
SELECT
    CASE WHEN $aire=1 and $tab=1
    THEN'red' 
    ELSE ''
    END as color,
    CASE WHEN $aire=1 and $tab=1
    THEN
'{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [
              '||Lon||', '||sum(Lat-0.023)||'
            ],
            [
              '||sum(Lon+0.023)||', '||sum(Lat-0.016)||'
            ],
            [
              '||sum(Lon+0.032)||', '||Lat||'
            ],
            [
              '||sum(Lon+0.023)||', '||sum(Lat+0.016)||'
            ],
            [
              '||Lon||', '||sum(Lat+0.023)||'
            ],
            [
              '||sum(Lon-0.023)||', '||sum(Lat+0.016)||'
            ],
            [
             '||sum(Lon-0.032)||', '||Lat||'
            ],
            [
              '||sum(Lon-0.023)||', '||sum(Lat-0.016)||'
            ],
            [
              '||Lon||', '||sum(Lat-0.023)||'
            ]
          ]
        ]
      }
    }
  ]
}' ELSE ''
    END as geojson
        FROM rucher WHERE id=$id and $tab=1 and $aire=1; 
    

-- Onglets : Interventions
select 
    'list' as component where $tab='4';
select 
    'grip-horizontal' as icon,
    strftime('%d/%m/%Y',horodatage)||' : '||action as title,
    details as description,
    '/intervention/intervention_ru_edit.sql?intervention='||ruvisite.id||'&id='||$id as edit_link
    FROM ruvisite INNER JOIN intervention on ruvisite.suivi=intervention.id WHERE rucher_id=$id and $tab='4' order by horodatage DESC;

-- Onglets : Production
SELECT 'table' as component,
	1 as sort,
	'Total' as align_right,
	'Actions' as markdown
	WHERE $tab='5';
SELECT 
    strftime('%Y',annee) as Année,
    strftime('%d/%m/%Y',annee)     as Récolte,
    categorie as Production,
    lot as Lot,
    total   as Total, 
    '[
    ![](./icons/pencil.svg)
    ](./production/production_edit.sql?production='||production.id||'&rucher='||$id||')'as Actions
    FROM production JOIN miel on production.produit=miel.id where rucher_id=$id and $tab='5' order by production.annee;

SET xticks = (SELECT count(distinct annee) FROM production where rucher_id=$id);
select 
    'chart'    as component,
    'Récoltes' as title,
    'bar'      as type,
    --TRUE       as time,
    TRUE as labels,
    TRUE       as toolbar,
    $xticks as xticks,
    "Années" as xtitle
     where $tab='5';
select 
    categorie as series,
    strftime('%Y',annee) as x,
    sum(total)  as y
    FROM production JOIN miel on production.produit=miel.id where rucher_id=$id and $tab='5' group by strftime('%Y',annee), categorie order by annee;

-- Ruches 
--Légende
select 
    'alert' as component,
    'Légende' as title,
    'green'             as color,
    TRUE              as important,
    TRUE              as dismissible,
   '![Alerte](./icons/alert-triangle-filled.svg)Niveaux d''alerte   ![Éditer](./icons/circle-green.svg)![Éditer](./icons/circle-orange.svg)![Éditer](./icons/circle-red.svg)Modifier le niveau d''alerte  ![Éditer](./icons/repeat.svg)Changer l''état de la colonie
' as description_md,
   '  ![Colonie](./icons/eye.svg)Fiche de la colonie   ![Éditer](./icons/pencil.svg)Éditer la colonie  ![Éditer](./icons/binary-tree.svg)Voir la généalogie  ![Éditer](./icons/tool.svg)Noter une intervention 
' as description_md
WHERE $tab='2';    
-- Liste
SELECT 'table' as component,
	1 as sort,
	'Alerte' as markdown,
	'Actions' as markdown,
	'État' as markdown,
	'Reine' as markdown,
	'Ruche' as markdown
	WHERE $tab='2';
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
    numero as Numero,
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
    ![](./icons/circle-green.svg)
](./alertes/tracing.sql?alerte=1&id='||colonie.numero||'&rucher='||$id||')
[
    ![](./icons/circle-orange.svg)
](./alertes/tracing.sql?alerte=2&id='||colonie.numero||'&rucher='||$id||')
[
    ![](./icons/circle-red.svg)
](./alertes/tracing.sql?alerte=3&id='||colonie.numero||'&rucher='||$id||')' as État,
        CASE WHEN disparition=1 THEN
    '[
    ![](./icons/repeat.svg)
](./mortalite/active_rucher.sql?tab='||$tab||'&id='||colonie.numero||'&rucher='||$id||')'
    ELSE '[
    ![](./icons/repeat.svg)
](./mortalite/disparue_rucher.sql?tab='||$tab||'&id='||colonie.numero||'&rucher='||$id||')'
     END as État,
    CASE WHEN disparition=1 THEN 'morte' ELSE 'active'
    END as État,
	'[
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||colonie.numero||')[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||')[
    ![](./icons/binary-tree.svg)
](ruche.sql?tab=3&id='||colonie.numero||')[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||')' as Actions
	 FROM colonie JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE rucher_id=$id and $tab='2' ORDER BY rang;




    



    

