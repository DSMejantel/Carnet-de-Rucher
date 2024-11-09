SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        'ruchers.sql' AS link
 WHERE $id=0;

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Enregistrer une intervention sur le rucher
INSERT INTO ruvisite(rucher_id, horodatage, details, registre_E, suivi)
SELECT 
    $id as rucher_id,
    :horodatage as horodatage,
    :details as details,
    coalesce(:registre,0) as registre_E,
    :suivi as suivi
    WHERE :details IS NOT NULL; 

SET visite = (SELECT last_insert_rowid() FROM ruvisite);
-- Enregistrer une intervention sur les ruches
INSERT INTO colvisite(rucher_id, horodatage, details, suivi, ruche_id)
SELECT 
    ruvisite.rucher_id as rucher_id,
    ruvisite.horodatage as horodatage,
    ruvisite.details as details,
    ruvisite.suivi as suivi,
    colonie.numero as ruche_id
    FROM ruvisite INNER JOIN colonie WHERE colonie.rucher_id=$id and ruvisite.id=$visite and $action is not NULL and :details IS NOT NULL;  

-- Enregistrer une récolte sur le rucher
INSERT INTO production(annee, rucher_id, produit, total, lot)
SELECT 
    :annee as annee,
    $id as rucher_id,
    :produit as produit,
    :total as total,
    :lot as lot
    WHERE :total IS NOT NULL; 

-- Description / Titre de la page Rucher
SELECT 'card' as component,
	1 as columns;
SELECT 
	nom as title,
	'orange'   as background_color,
	'Altitude : '||Alt||'m. '||description as description,
	'[
    ![](./icons/eye.svg)
](rucher.sql?tab=1&id='||id||' "Détails du rucher")[
    ![](./icons/archive.svg)
](rucher.sql?tab=2&id='||id||' "Voir les colonies")[
    ![](./icons/tool.svg)
](intervention_rucher.sql?tab=4&id='||id||' "Noter une intervention")[
    ![](./icons/milk.svg)
](production_rucher.sql?tab=5&id='||id||' "Enregistrer une production")' as footer_md
	 FROM rucher WHERE id=$id;
-------------------------------------------
/*SELECT 'table' as component,
	'Actions' as markdown;
SELECT 
	nom as Rucher,
	alt as altitude,
	description as description,
	'orange'   as _sqlpage_color,
	'[
    ![](./icons/eye.svg)
](rucher.sql?tab=1&id='||id||' "Détails du rucher")[
    ![](./icons/archive.svg)
](rucher.sql?tab=2&id='||id||' "Voir les colonies")[
    ![](./icons/tool.svg)
](intervention_rucher.sql?tab=4&id='||id||' "Noter une intervention")[
    ![](./icons/milk.svg)
](production_rucher.sql?tab=5&id='||id||' "Enregistrer une production")' as Actions
	 FROM rucher WHERE id=$id;
*/   
--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Description'  as title, 'home' as icon, 1  as active, 'rucher.sql?tab=1&id='||$id as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Ruches' as title, 'archive' as icon, 0 as active, 'rucher.sql?tab=2&id='||$id as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Mortalité' as title, 'archive-off' as icon, 0 as active, 'rucher.sql?tab=6&id='||$id as link, CASE WHEN $tab='6' THEN 'orange' ELSE 'green' END as color;
select  'Ajouter colonie' as title, 'square-plus' as icon, 0 as active, 'rucher.sql?tab=3&id='||$id as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Interventions' as title, 'tool' as icon, 1 as active, 'rucher.sql?tab=4&id='||$id as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color;
select  'Production' as title, 'flower' as icon, 1 as active, 'rucher.sql?tab=5&id='||$id as link, CASE WHEN $tab='5' THEN 'orange' ELSE 'green' END as color;

-- Ruches
-- Enregistrer la colonie dans la base
 INSERT INTO colonie(numero, rucher_id, rang, position, couleur, modele, début, reine, souche, caractere, info, disparition) SELECT :numero, :rucher, :rang, :position, :couleur, :modele, :début, :reine, :souche, :caractere, :info, 0 WHERE :numero IS NOT NULL;

-- Formulaire d'ajout
    SELECT 
    'form' as component,
    'Créer une ruche' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset
     WHERE $tab='3';
    
    SELECT 'Numéro' AS label, 'numero' AS name, 'number' as prefix_icon, TRUE as required, 1 as width WHERE $tab='3';
    SELECT 'Rucher' AS label, 'rucher' AS name, 'select' as type, 2 as width, CAST($id as integer) as value,
    json_group_array(json_object("label" , nom, "value", id )) as options FROM (select * FROM rucher ORDER BY nom ASC) WHERE $tab='3';
    SELECT 'Rangée' AS label, 'rang' AS name, 'number' as type, 2 as width WHERE $tab='3';
    SELECT 'Position' AS label, 'position' AS name, 'number' as type, 2 as width WHERE $tab='3';
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



--Tableau de bord   
SET aire=coalesce($aire,0);

select 
    'card' as component,
     2      as columns
     where $tab='1';
select 
    '/rucher/tracing.sql?_sqlpage_embed&id='||$id as embed
    where $tab='1';
select 
    '/rucher/carte.sql?_sqlpage_embed&id='||$id||'&aire='||$aire  as embed
    where $tab='1';

-- Onglets : Interventions
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=4;
select 
    'circle-plus' as icon,
    'green' as outline,
    'Ajouter' as tooltip,
    'intervention_rucher.sql?tab=4&id='||id as link
    FROM rucher WHERE id=$id AND $tab=4;
    
select 
    'list' as component where $tab=4;
select 
    'grip-horizontal' as icon,
    strftime('%d/%m/%Y',horodatage)||' : '||coalesce(action,'-') as title,
    details as description,
    '/intervention/intervention_ru_edit.sql?intervention='||ruvisite.id||'&id='||$id as edit_link
    FROM ruvisite LEFT JOIN intervention on ruvisite.suivi=intervention.id WHERE rucher_id=$id and $tab=4 order by horodatage DESC;

-- Onglets : Production
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=5;
select 
    'circle-plus' as icon,
    'green' as outline,
    'Ajouter' as tooltip,
    'production_rucher.sql?tab=5&id='||id as link
    FROM rucher WHERE id=$id AND $tab=5;

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
    ](./production/production_edit.sql?production='||production.id||'&rucher='||$id||' "Éditer")'as Actions
    FROM production JOIN miel on production.produit=miel.id where rucher_id=$id and $tab='5' order by production.annee;

SET xticks = (SELECT count(distinct annee) FROM production where rucher_id=$id);
select 
    'chart'    as component,
    'Récoltes' as title,
    'bar'      as type,
    --TRUE       as time,
    TRUE as stacked,
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

-- Liste des ruches
select 
    'columns' as component where $tab=2;
select 
    distinct numero as value,
    'ruche.sql?tab=1&id='||numero          as link,
     CASE WHEN tracing=1
    	THEN 'thumb-up'
    	ELSE 'alert-triangle' 
    	END as icon,
    CASE WHEN tracing=2
    	THEN 'orange'
    	WHEN tracing=3
    	THEN 'red'
    	ELSE 'green' 
    	END as icon_color,
    CASE WHEN tracing=2
    	THEN 'orange'
    	WHEN tracing=3
    	THEN 'red'
    	ELSE 'green' 
    	END as value_color,
    	        type||'[
    ![](./icons/archive_'||code||'.svg)
](ruche.sql?tab=1&id='||colonie.numero||') '||CHAR(10)||CHAR(10) as description_md,

    'Reine '||reine||'[
    ![](./icons/circle-number-'||substr( reine, -1,1 )||'.svg)
]()'||CHAR(10)||CHAR(10) as description_md,
'[
    ![](./icons/circle-green.svg)
](./alertes/tracing2.sql?alerte=1&id='||colonie.numero||' "Noter en situation correcte")
[
    ![](./icons/circle-orange.svg)
](./alertes/tracing2.sql?alerte=2&id='||colonie.numero||' "Noter en situation de vigilance")
[
    ![](./icons/circle-red.svg)
](./alertes/tracing2.sql?alerte=3&id='||colonie.numero||' "Noter en situation d''alerte")' as description_md,
    			'[
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||colonie.numero||' "Visualiser")[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||' "Mettre à jour")[
    ![](./icons/binary-tree.svg)
](ruche.sql?tab=3&id='||colonie.numero||' "Généalogie de la colonie")[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||' "Noter une intervention")' as description_md,
    json_array(
    json_object('icon','hexagons','color','green','description',caractere),
    json_object('icon','info-circle','color','green','description',info)
    ) as item,

     'Voir la ruche'     as button_text,
    CASE WHEN tracing=2
    	THEN 'orange'
    	WHEN tracing=3
    	THEN 'red'
    	ELSE 'green' 
    	END as button_color
    
    FROM colonie JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE rucher_id=$id and CAST(disparition as integer)<>1 and $tab=2 ORDER BY rang,position;

-- Ruches 
--Légende
select 
    'foldable' as component WHERE $tab='2'; 
select
    'Légende' as title,
    '![Alerte](./icons/alert-triangle-filled.svg)Niveaux d''alerte   ![Éditer](./icons/circle-green.svg)![Éditer](./icons/circle-orange.svg)![Éditer](./icons/circle-red.svg)Modifier le niveau d''alerte  ![Éditer](./icons/repeat.svg)Changer l''état de la colonie
' as description_md,
   '  ![Colonie](./icons/eye.svg)Fiche de la colonie   ![Éditer](./icons/pencil.svg)Éditer la colonie  ![Éditer](./icons/binary-tree.svg)Voir la généalogie  ![Éditer](./icons/tool.svg)Noter une intervention 
' as description_md
WHERE $tab='2'; 
    
-- Liste
SELECT 'table' as component,
       'Aucune colonie sur ce rucher en ce moment' as empty_description,
	TRUE as sort,
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
](ruche.sql?tab=1&id='||colonie.numero||' "Visualiser")[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||' "Mettre à jour")[
    ![](./icons/binary-tree.svg)
](ruche.sql?tab=3&id='||colonie.numero||' "Généalogie de la colonie")[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||' "Noter une intervention")' as Actions
	 FROM colonie JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE rucher_id=$id and CAST(disparition as integer)<>1 and $tab='2' ORDER BY rang;

-- Mortalité / Ruches perdues 
-- Liste
SELECT 'table' as component,
	1 as sort,
	'Actions' as markdown,
	'Reine' as markdown,
	'Ruche' as markdown
	WHERE $tab='6';
SELECT 
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
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||colonie.numero||' "Visualiser")[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||' "Mettre à jour")[
    ![](./icons/binary-tree.svg)
](ruche.sql?tab=3&id='||colonie.numero||' "Généalogie de la colonie")[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||' "Noter une intervention")' as Actions
	 FROM colonie JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE rucher_id=$id and $tab='6' and CAST(disparition as integer)=1 ORDER BY rang;


    



    

