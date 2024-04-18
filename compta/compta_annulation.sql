SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        './/index.sql?restriction' AS link
        WHERE $group_id<'3';

    -- Mettre à jour l'opération dans la base
    -- l'opération n'est pas supprimée mais le montant passe à zéro
    
 UPDATE finances SET prix=0

 
 WHERE id=$id
 RETURNING
   'redirect' AS component,
   '../compta.sql?tab=1' as link;

