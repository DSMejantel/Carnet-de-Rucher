SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

--Onglets
SET tab=coalesce($tab,'2');
select 'tab' as component;
select  'Factures'  as title, 'pig-money' as icon, 1  as active, 'order.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Caisse' as title, 'receipt-2' as icon, 0 as active, 'order.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;

-- Caisse :  enregistrer une vente
SELECT 'form' as component,
    'Commande' as title,
    'Valider' as validate,
    'green' as validate_color,
    'order_insert.sql' as action;

SELECT 'Name' as name, 'Nom' as label, TRUE as required, 'Nom du client' AS placeholder where $tab=2;
select 
    'paiement' as name,
    'radio' as type,
    1       as value,
    'Espèces' as label,
    4 as width;
select 
    'paiement'  as name,
    'radio'  as type,
    2        as value,
    'Chèque' as label,
    4 as width;
select 
    'paiement'  as name,
    'radio'  as type,
    3        as value,
    'Virement' as label,
    4 as width;
SELECT 'product_quantity[]' AS name,
    categorie || ' en pots de '||produits AS label,
    coalesce(reste-vendus,reste) ||' en stock. ' || printf("%.2f", prix) || ' € l''unité.' as description,
    'number' AS type,
    1 AS step,
    0 as min,
    coalesce(reste-vendus,reste) as max,
    0 as value
FROM produits LEFT JOIN gest_inventaire on produits.id=gest_inventaire.articles WHERE vente=1 and nombre-coalesce(vendus,0)>0 ORDER BY id;

-- We include the product ids in the form as hidden fields, so that we can use them for the insertion.
SELECT 'product_id[]' AS name, '' AS label, 'hidden' AS type, id as value
FROM produits LEFT JOIN gest_inventaire on produits.id=gest_inventaire.articles WHERE vente=1  and nombre-coalesce(vendus,0)>0 ORDER BY id;


