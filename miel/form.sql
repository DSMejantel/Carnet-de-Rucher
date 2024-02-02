SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


 -- Formulaire pour ajouter un type de miel
SELECT 'form' as component, 
'Ajouter un type de miel' as title, 
'parametres.sql?tab=5' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset;

SELECT 'Catégorie' AS 'label', 'text' as type, 'categorie' AS name, 6 as width;
