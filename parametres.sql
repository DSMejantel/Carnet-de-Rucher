SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- ajouter un modèle de ruche
INSERT INTO modele(type)
SELECT $type WHERE $type IS NOT NULL;

-- ajouter une couleur de ruche
INSERT INTO couleur(coloris, code)
SELECT $couleur, $couleur WHERE $couleur IS NOT NULL;

UPDATE couleur SET coloris='bleu azur' WHERE coloris='azure' and $couleur is not null
UPDATE couleur SET coloris='bleu clair' WHERE coloris='indigo' and $couleur is not null
UPDATE couleur SET coloris='bleu foncé' WHERE coloris='blue' and $couleur is not null
UPDATE couleur SET coloris='violet' WHERE coloris='purple' and $couleur is not null
UPDATE couleur SET coloris='rouge' WHERE coloris='red' and $couleur is not null
UPDATE couleur SET coloris='jaune' WHERE coloris='yellow' and $couleur is not null
UPDATE couleur SET coloris='vert clair' WHERE coloris='lime' and $couleur is not null
UPDATE couleur SET coloris='vert' WHERE coloris='green' and $couleur is not null
UPDATE couleur SET coloris='gris' WHERE coloris='vk' and $couleur is not null

-- ajouter une categorie de miel
INSERT INTO miel(categorie)
SELECT $categorie WHERE $categorie IS NOT NULL;

-- ajouter un type d'intervention
INSERT INTO intervention(action)
SELECT $action WHERE $action IS NOT NULL;

-- ajouter un élément de ruche

INSERT INTO materiel(element)
SELECT $element WHERE $element IS NOT NULL;

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component,
TRUE as center;
select  'Type de Ruche'  as title, 'home' as icon, 1  as active, 'parametres.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Couleurs' as title, 'palette' as icon, 0 as active, 'parametres.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Interventions' as title, 'tool' as icon, 1 as active, 'parametres.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Élément de ruche' as title, 'box-align-top-filled' as icon, 1 as active, 'parametres.sql?tab=4' as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color;
select  'Variété de Miels' as title, 'flower' as icon, 1 as active, 'parametres.sql?tab=5' as link, CASE WHEN $tab='5' THEN 'orange' ELSE 'green' END as color;
/*
-- Formulaire pour ajouter un modèle de ruche
SELECT 'form' as component, 
'Ajouter un modèle' as title, 
'parametres.sql?tab=1' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset
    where $tab='1';

SELECT 'Modèle' AS 'label', 'text' as type, 'type' AS name, 6 as width      where $tab='1';

-- Liste des modèles
SELECT 'list' as component  where $tab='1';
SELECT type as description
 FROM modele where $tab='1'  ORDER by type;
*/
--Modèle de ruche   
select 
    'card' as component,
     2      as columns
     where $tab='1';
select 
    '/modele/liste.sql?_sqlpage_embed' as embed
    where $tab='1';
select 
    '/modele/form.sql?_sqlpage_embed' as embed
    where $tab='1';


/*-- Formulaire pour ajouter une couleur
SELECT 'form' as component, 
'Ajouter une couleur' as title, 
'parametres.sql?tab=2' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset
     where $tab='2';

select 
    'couleur'  as name,
    'select' as type,
    1        as value,
    '[{"label": "Non définie", "value": "white"},{"label": "Bleu azur", "value": "azure"},{"label": "Bleu clair", "value": "indigo"}, {"label": "Bleu foncé", "value": "blue"},{"label": "Gris", "value": "vk"},{"label": "Jaune", "value": "yellow"},{"label": "Orange", "value": "orange"},{"label": "Rouge", "value": "red"},{"label": "Vert clair", "value": "lime"},{"label": "Vert", "value": "green"},{"label": "Violet", "value": "purple"}]' as options where $tab='2';

-- Liste des couleurs
select 
    'card'                     as component,
    6                          as columns   where $tab='2';
select 
    coloris  as title,
    'home'                as icon,
    code                    as color
     FROM couleur where $tab='2';
*/ 
--Couleur de ruche   
select 
    'card' as component,
     2      as columns
     where $tab='2';
select 
    '/couleur/liste.sql?_sqlpage_embed' as embed
    where $tab='2';
select 
    '/couleur/form.sql?_sqlpage_embed' as embed
    where $tab='2';
/*
 -- Formulaire pour ajouter un type d'intervention
SELECT 'form' as component, 
'Ajouter un type d''intervention' as title, 
'parametres.sql?tab=3' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset
     where $tab='3';

SELECT 'Actions' AS 'label', 'text' as type, 'action' AS name, 6 as width      where $tab='3';

-- Liste des actions
SELECT 'list' as component  where $tab='3';
SELECT action as description
 FROM intervention where $tab='3'  ORDER by action;
*/ 
--Couleur de ruche   
select 
    'card' as component,
     2      as columns
     where $tab='3';
select 
    '/intervention/liste.sql?_sqlpage_embed' as embed
    where $tab='3';
select 
    '/intervention/form.sql?_sqlpage_embed' as embed
    where $tab='3';



 --Élément de ruche
select 
    'card' as component,
     2      as columns
     where $tab='4';
select 
    '/materiel/liste.sql?_sqlpage_embed' as embed
    where $tab='4';
select 
    '/materiel/form.sql?_sqlpage_embed' as embed
    where $tab='4';
 
/* -- Formulaire pour ajouter un type de miel
SELECT 'form' as component, 
'Ajouter un type de miel' as title, 
'parametres.sql?tab=5' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset
     where $tab='5';

SELECT 'Catégorie' AS 'label', 'text' as type, 'categorie' AS name, 6 as width      where $tab='5';

-- Liste des miels
SELECT 'list' as component where $tab='5';
SELECT categorie as description
 FROM miel where $tab='5'  ORDER by categorie;
 */
 --Catégorie de miel  
select 
    'card' as component,
     2      as columns
     where $tab='5';
select 
    '/miel/liste.sql?_sqlpage_embed' as embed
    where $tab='5';
select 
    '/miel/form.sql?_sqlpage_embed' as embed
    where $tab='5';
