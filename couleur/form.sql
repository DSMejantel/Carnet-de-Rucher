SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


-- Formulaire pour ajouter une couleur
SELECT 'form' as component, 
'parametres.sql?tab=2' as action,
'Ajouter' as validate,
    'green'           as validate_color,
    'Effacer'           as reset;
select 
    'couleur'  as name,
    'select' as type,
    1        as value,
    '[{"label": "Non définie", "value": "white"},{"label": "Bleu azur", "value": "azure"},{"label": "Bleu clair", "value": "indigo"}, {"label": "Bleu foncé", "value": "blue"},{"label": "Gris", "value": "vk"},{"label": "Jaune", "value": "yellow"},{"label": "Orange", "value": "orange"},{"label": "Rouge", "value": "red"},{"label": "Vert clair", "value": "lime"},{"label": "Vert", "value": "green"},{"label": "Violet", "value": "purple"}]' as options;
