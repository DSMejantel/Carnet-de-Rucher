SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Liste des modèles
SELECT 'list' as component,
'Matériel en place sur la ruche' as title;
SELECT group_concat(Distinct element) as description
 FROM materiel
     Join inventaire on inventaire.element_id=materiel.id 
     AND inventaire.ruche_id=$id ORDER by element;
