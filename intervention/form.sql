SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


 -- Formulaire pour ajouter un type d'intervention
SELECT 'form' as component, 
'parametres.sql?tab=3' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset;

SELECT 'Actions' AS 'label', 'text' as type, 'tool' as prefix_icon, 'action' AS name, 8 as width;


