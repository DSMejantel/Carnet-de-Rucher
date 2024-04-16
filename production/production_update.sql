SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

 UPDATE production 
 SET annee=$annee,
    produit=$produit,
    total=$total,
    lot=$lot WHERE id=$production
 RETURNING 
 'redirect' as component,
 '../rucher.sql?tab=5&id='||$rucher as link;
