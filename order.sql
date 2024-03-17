SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Mettre à jour le total de la facture 
SET  facture_total=(SELECT SUM(quantity * prix)
FROM order_items
INNER JOIN produits ON produits.id = order_items.product_id
WHERE order_id = $id and $tab=3);

UPDATE orders SET customer_total=$facture_total where id=$id and $tab=3;

-- Enregistrer la facture dans la base de données finances
INSERT INTO finances (facture_id, categorie, operation, prix, moyen)
SELECT
$id,
'Recette', 
'Vente de Miel à  '||customer_name, 
$facture_total,
customer_mode
FROM orders WHERE id=$id;

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Factures'  as title, 'pig-money' as icon, 1  as active, 'order.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Caisse' as title, 'receipt-2' as icon, 0 as active, 'order_form.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Dernière Commande' as title, 'receipt-2' as icon, 0 as active, 'order.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color where $tab=3;
select  'Facture sélectionnée' as title, 'receipt-2' as icon, 0 as active, 'order.sql?tab=4' as link, CASE WHEN $tab='4' THEN 'orange' ELSE 'green' END as color where $tab=4;

--- Dernière commande
SELECT 'alert' as component,
    'analyze' as icon,
    'teal' as color,
    'La commande a bien été prise en compte.' as description
     where $tab=3;

SELECT 'list' AS component,
    'Résumé de la commande' AS title where $tab=3;
SELECT 
    quantity || ' x ' || produits || ' de ' || categorie || ' (Lot :  ' || lot || ' ) ' AS title,
    'Sous-total: ' || quantity || ' x ' || prix || ' € = ' || (quantity * prix) || ' €' AS description
FROM order_items
INNER JOIN produits ON produits.id = order_items.product_id
WHERE order_id = $id and $tab=3;
SELECT 
    'Total: ' || SUM(quantity * prix) || ' €' AS title,
    'red' AS color,
    TRUE AS active
FROM order_items
INNER JOIN produits ON produits.id = order_items.product_id
WHERE order_id = $id and $tab=3;

--- Détails facture sélectionée
SELECT 'list' AS component,
    'Récapitulatif de la facture n°'||id|| ' pour ' || customer_name AS title 
    FROM orders
WHERE id = $facture and $tab=4;
SELECT 
    quantity || ' x ' || produits || ' de ' || categorie || ' (Lot :  ' || lot || ' ) ' AS title,
    'Sous-total: ' || quantity || ' x ' || prix || ' € = ' || (quantity * prix) || ' €' AS description
FROM order_items
INNER JOIN produits ON produits.id = order_items.product_id
WHERE order_id = $facture and $tab=4;
SELECT 
    'Total: ' ||SUM(quantity * prix) || ' €' AS title,
    TRUE AS active
FROM order_items
INNER JOIN produits ON produits.id = order_items.product_id
WHERE order_id = $facture and $tab=4;

-- Factures : Liste des commandes
select 
    'table' as component,
    TRUE as hover,
    TRUE as small,
    TRUE    as sort,
    TRUE    as search,
    'Total' as align_right,
    'Facture' as markdown
    where $tab='1';
    
select 
    id as N°,
        '[
    ![](./icons/receipt-2.svg)
](order.sql?facture='||id||'&tab=4)' as Facture,
    strftime('%d/%m/%Y',date_created) as Date,
    customer_name as Client,
    CASE WHEN customer_mode=1 THEN 'Espèces'
    WHEN customer_mode=2 THEN 'Chèque'
    ELSE 'Virement' 
    END as Paiement,
    printf("%.2f", customer_total) as "Total"
    FROM orders WHERE $tab='1' ORDER BY date_created;






