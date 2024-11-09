SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Liste des produits

select 
    'divider' as component,
    'Lot : '||$lot as  contents;
SELECT 'table' as component,
    'Vente' as markdown
     FROM produits WHERE lot=$lot;
SELECT 
    produits as Liste,
    categorie as Miel,
    DDM as DDM,
    coalesce(reste-vendus,reste) as Dispo,
CASE WHEN vente=1
    THEN '[
    ![](./icons/select.svg)
](/catalogue/indisponible_lot.sql?id='||produits.id||'&lot='||$lot||')' 
ELSE '[
    ![](./icons/square.svg)
](/catalogue/disponible_lot.sql?id='||produits.id||'&lot='||$lot||')' 
END as Vente,
    prix as prix
 FROM produits LEFT JOIN gest_inventaire on produits.id=gest_inventaire.articles WHERE lot=$lot;
