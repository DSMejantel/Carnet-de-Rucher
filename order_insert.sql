SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

INSERT INTO orders(customer_name, customer_mode) 
VALUES (:Name, :paiement);

INSERT INTO order_items(order_id, quantity, product_id)
SELECT
    last_insert_rowid(),
    CAST(quantity.value AS INTEGER),
    CAST(product.value AS INTEGER)
FROM JSON_EACH(:product_quantity) quantity
INNER JOIN JSON_EACH(:product_id) product USING (key)
WHERE CAST(quantity.value AS INTEGER) > 0

RETURNING
    'order.sql?id=' || order_id || '&tab=3' as link,
    'redirect' as component;
