SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- ajouter un rucher
INSERT INTO rucher(nom, description, Lon, Lat, Alt)
SELECT $nom, $description, $Lon, $Lat, $alt where $nom IS NOT NULL;

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component,
TRUE as center;
select  'Liste des ruchers'  as title, 'home' as icon, 1  as active, 'ruchers.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Ajouter' as title, 'square-plus' as icon, 0 as active, 'ruchers.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Suivis' as title, 'chart-bar' as icon, 1 as active, 'ruchers.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Carte' as title, 'map' as icon, 1 as active, 'ruchers.sql?tab=4' as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color;
   

-- Liste des ruchers
SELECT 'table' as component,
	'Actions' as markdown
	where $tab='1';
SELECT 
	nom as Nom,
	alt as Altitude,
	description as Description,
	'[
    ![](./icons/home.svg)
](rucher.sql?tab=1&id='||id||')[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=2&id='||id||')[
    ![](./icons/tool.svg)
](intervention_rucher.sql?tab=4&id='||id||')[
    ![](./icons/milk.svg)
](production_rucher.sql?tab=5&id='||id||')' as Actions
	 FROM rucher where $tab='1'  ORDER by nom;


-- Nouveau rucher    
SELECT 
    'form' as component,
    'Nouveau rucher' as title,
    'Créer' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset
    where $tab='2';
    
    SELECT 'Nom' AS label, 'nom' AS name, 4 as width where $tab='2';
    SELECT 'Description' AS label, 'description' AS name, 8 as width where $tab='2';
    SELECT 'Altitude' AS label, 'alt' AS name, 4 as width where $tab='2';
    SELECT 'Latitude' AS label, 'Lat' AS name, 4 as width where $tab='2';
    SELECT 'Longitude' AS label, 'Lon' AS name, 4 as width where $tab='2';

-- onglet : Stats - nombre et état des colonies
SELECT 
    'datagrid' as component
    where $tab='3';
select 
    distinct nom as title,
    CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE rucher.id=colonie.rucher_id)<2
    	THEN (SELECT count(distinct numero)||' ruche' FROM colonie WHERE rucher.id=colonie.rucher_id)
    	ELSE (SELECT count(distinct numero)||' ruches' FROM colonie WHERE rucher.id=colonie.rucher_id) END   as description,
    CASE WHEN (SELECT count(distinct tracing) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id)<2
    	THEN (SELECT count(distinct tracing)||' ruche à surveiller' FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id) 
    	ELSE (SELECT count(distinct tracing)||' ruches à surveiller' FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id) END as footer,
    	CASE WHEN (SELECT count(distinct tracing) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id)>0
    	THEN 'alert-triangle-filled'              END    as icon,
    	'orange' as color,
    	'rucher.sql?tab=1&id='||rucher.id as link
    FROM rucher left join colonie on rucher.id=colonie.rucher_id where $tab='3' ;

-- Onglets : Stats - Production
select 
    'chart2'    as component,
    'Récoltes' as title,
    'bar'      as type,
    TRUE       as stacked,
    TRUE as labels
    where $tab='3';
select 
    categorie as series,
    annee   as x,
    coalesce(total, 0)   as value
    FROM production JOIN miel on production.produit=miel.id where $tab='3' ORDER BY rucher_id;
    
        
--Carte   
SET AVG_Lat = (SELECT AVG(Lat) FROM rucher);
SET AVG_Lon = (SELECT AVG(Lon) FROM rucher);

SELECT 
    'map' as component,
    13 as zoom,
    400 as height,
    $AVG_Lat as latitude,
    $AVG_Lon as longitude,
    'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png' as tile_source,
    ''    as attribution
    where $tab='4';

SELECT
    nom as title,
    Lat AS latitude, 
    Lon AS longitude,
    'home' as icon,
    'rucher.sql?id='||id as link
    FROM rucher
    where $tab='4';  
    

