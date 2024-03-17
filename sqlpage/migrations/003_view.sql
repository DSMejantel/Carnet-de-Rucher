DROP VIEW IF EXISTS gest_inventaire;
CREATE VIEW gest_inventaire AS
SELECT produits.id AS articles,
    sum(quantity) AS vendus
FROM order_items JOIN produits on produits.id=order_items.product_id Group by produits.id;
