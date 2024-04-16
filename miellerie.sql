SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--Titre
 select 
    'title'   as component,
    'Registre de miellerie' as contents,
    TRUE as center,
    3         as level;
    
-- Enregistrer un miel provenant d'un lot
INSERT INTO produits(lot, produits, categorie, nombre, reste, vente, prix, DDM)
SELECT 
    $lot as lot,
    $produits as produits,
    $categorie as categorie,
    $nombre as nombre,  
        $nombre as reste,   
    coalesce($vente,0) as vente,
    $prix as prix,
    $DDM as DDM
    WHERE $produits IS NOT NULL and $tab IN (2,3); 
    
       
--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Lots'  as title, 'barcode' as icon, 1  as active, 'miellerie.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Catalogue' as title, 'milk' as icon, 0 as active, 'miellerie.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Ajouter en lien avec un lot' as title, 'square-plus' as icon, 0 as active, 'miellerie.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color where $lot is not null;
select  'Ajouter des produits divers' as title, 'square-plus' as icon, 0 as active, 'miellerie.sql?tab=4' as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color;
select  'Traçabilité' as title, 'basket-search' as icon, 0 as active, 'miellerie.sql?tab=5' as link, CASE WHEN $tab='5' THEN 'orange' ELSE 'green' END as color where $tab=5;
  

-- Onglets : Historique des lots
select 
    'table' as component,
    TRUE as hover,
    TRUE as small,
    TRUE    as sort,
    TRUE    as search,
    'Produits' as markdown
    where $tab='1';
    
select 
    annee as Année,
    lot as Lot,
    nom as Rucher,
    produit as Miel,
    total as Quantité,
    '[
    ![](./icons/milk.svg)
](miellerie.sql?tab=3&lot='||lot||')[
    ![](./icons/basket-search.svg)
](miellerie.sql?tab=5&lotn='||lot||')' as Produits
    FROM production JOIN rucher on production.rucher_id=rucher.id WHERE $tab='1' ORDER BY annee, lot;
    
-- Liste des produits
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape
            where $tab='2';
select 
    'Ajouter un produit' as title,
    'miellerie.sql?tab=4' as link,
    'square-rounded-plus' as icon,
    'green' as outline
            where $tab='2';
            
SELECT 'table' as component,
    TRUE    as sort,
    TRUE    as search,
    'Prix (€)' as align_right,
    'Produits' as markdown,
    'Dispo' as markdown
            where $tab='2';
SELECT 
    lot as Lot,
    produits as Liste,
    categorie as Miel,
    DDM as DDM,
    nombre as Total,
    coalesce(reste-vendus,reste) as Quantité,
    CASE WHEN vente::int=1
    THEN '[
    ![](./icons/select.svg)
](/catalogue/indisponible.sql?id='||produits.id||')' 
ELSE '[
    ![](./icons/square.svg)
](/catalogue/disponible.sql?id='||produits.id||')' 
END as Dispo,
    '[
    ![](./icons/milk.svg)
](miellerie.sql?tab=3&lot='||lot||')
     [
    ![](./icons/triangle.svg)
](/catalogue/ajouter_produit.sql?id='||produits.id||')
     [
    ![](./icons/triangle-inverted.svg)
](/catalogue/enlever_produit.sql?id='||produits.id||')' as Produits,
    printf("%.2f", prix) as Prix
 FROM produits LEFT JOIN gest_inventaire on produits.id=gest_inventaire.articles WHERE $tab='2';   
    
--Onglet : ajouter des produits à un lot
select 
    'card' as component,
     2      as columns
     where $tab='3';
select 
    '/catalogue/liste.sql?lot='||lot||'&_sqlpage_embed' as embed
    FROM production WHERE lot=$lot and $tab='3';
select 
    '/catalogue/form.sql?lot='||lot||'&_sqlpage_embed' as embed
    FROM production WHERE lot=$lot and $tab='3';
    
--Onglet : ajouter des produits à un lot
select 
    'card' as component,
     2      as columns
     where $tab='4';
select 
    '/catalogue/liste_divers.sql?_sqlpage_embed' as embed
    WHERE $tab='4';
select 
    '/catalogue/form_divers.sql?_sqlpage_embed' as embed
    WHERE $tab='4';

-- Onglets : Traçabilité
select 
    'table' as component,
    TRUE as hover,
    TRUE as small,
    TRUE    as sort,
    TRUE    as search
    where $tab='5';
    
select 
    production.annee as Année,
    production.lot as Lot,
    categorie as Miel,
    group_concat(distinct customer_name) as Clients
    FROM production JOIN produits on production.lot=produits.lot JOIN order_items on produits.id=order_items.product_id JOIN orders on orders.id=order_items.order_id WHERE production.lot=$lotn and $tab='5';


