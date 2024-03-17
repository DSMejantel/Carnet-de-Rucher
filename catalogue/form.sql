SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


 -- Formulaire pour ajouter un produit
SELECT 'form' as component, 
    'Ajouter un produit' as title, 
    'miellerie.sql?lot='||$lot||'&tab=3' as action,
    'Ajouter' as validate,
    'green'   as validate_color;

     SELECT 'Pot de : ' AS 'label', TRUE as required, 'text' as type, 'milk' as prefix_icon, 'produits' AS name, 6 as width;
    SELECT 'Miel de : ' AS 'label', 'text' as type, TRUE as autocomplete, (SELECT categorie FROM miel JOIN production on miel.id=production.produit WHERE lot=$lot) as value, 'flower' as prefix_icon, 'categorie' AS name, 6 as width;
    SELECT 'DDM' AS 'label', 'text' as type, TRUE as autocomplete, (SELECT annee FROM production WHERE lot=$lot)+2 as value, 'calendar-cancel' as prefix_icon, 'DDM' AS name, 6 as width;
    SELECT 'number' as type, 1 as step, 'Quantité' AS 'label', TRUE as required, 'shopping-cart' as prefix_icon,  'nombre' AS name, 6 as width;
    SELECT 'number' as type, 0.5 as step, 'Prix' AS 'label', TRUE as required, 'coin-euro' as prefix_icon,  'prix' AS name, 6 as width;
    SELECT 'En vente' AS label, 'vente' AS name, 'checkbox' as type, 1 as value, 6 as width; 
 


