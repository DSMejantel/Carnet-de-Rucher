SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- ajouter un modèle de ruche
INSERT INTO modele(type)
SELECT :type WHERE :type IS NOT NULL;

-- ajouter une couleur de ruche
INSERT INTO couleur(coloris, code)
SELECT :couleur, :couleur WHERE :couleur IS NOT NULL;

UPDATE couleur SET coloris='bleu azur' WHERE coloris='azure' and :couleur is not null
UPDATE couleur SET coloris='bleu clair' WHERE coloris='indigo' and :couleur is not null
UPDATE couleur SET coloris='bleu foncé' WHERE coloris='blue' and :couleur is not null
UPDATE couleur SET coloris='violet' WHERE coloris='purple' and :couleur is not null
UPDATE couleur SET coloris='rouge' WHERE coloris='red' and :couleur is not null
UPDATE couleur SET coloris='jaune' WHERE coloris='yellow' and :couleur is not null
UPDATE couleur SET coloris='vert clair' WHERE coloris='lime' and :couleur is not null
UPDATE couleur SET coloris='vert' WHERE coloris='green' and :couleur is not null
UPDATE couleur SET coloris='gris' WHERE coloris='vk' and :couleur is not null

-- ajouter une categorie de miel
INSERT INTO miel(categorie)
SELECT :categorie WHERE :categorie IS NOT NULL;

-- ajouter un type d'intervention
INSERT INTO intervention(action)
SELECT :action WHERE :action IS NOT NULL;

-- ajouter une origine d''essaim
INSERT INTO provenance(origine)
SELECT :origine WHERE :origine IS NOT NULL;


-- ajouter un élément de ruche

INSERT INTO materiel(element)
SELECT :element WHERE :element IS NOT NULL;

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component,
TRUE as center;
select  'Type de Ruche'  as title, 'home' as icon, 1  as active, 'parametres.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Couleurs' as title, 'palette' as icon, 0 as active, 'parametres.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Interventions' as title, 'tool' as icon, 1 as active, 'parametres.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Élément de ruche' as title, 'box-align-top-filled' as icon, 1 as active, 'parametres.sql?tab=4' as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color;
select  'Produits de la ruche' as title, 'flower' as icon, 1 as active, 'parametres.sql?tab=5' as link, CASE WHEN $tab='5' THEN 'orange' ELSE 'green' END as color;
select  'Origine des essaims' as title, 'arrow-big-down-lines' as icon, 1 as active, 'parametres.sql?tab=6' as link, CASE WHEN $tab='6' THEN 'orange' ELSE 'green' END as color;

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

--Type d'intervention sur une ruche   
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
 

 --Catégorie de miel  et autres produits de la ruche
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
    
 --Provenance des essaims
select 
    'card' as component,
     2      as columns
     where $tab='6';
select 
    '/origine/liste.sql?_sqlpage_embed' as embed
    where $tab='6';
select 
    '/origine/form.sql?_sqlpage_embed' as embed
    where $tab='6';
