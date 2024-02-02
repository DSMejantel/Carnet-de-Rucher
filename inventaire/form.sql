SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


-- Formulaire pour ajouter un élément de ruche
SELECT 
    'form' as component,
    'Mettre à jour' as validate,
    'ruche.sql?tab=4&inv=1&id='||$id as action,    
    'orange'           as validate_color;
    
SELECT 'element[]' as name, 'nouvelle situation' as label, 6 as width, 'select' as type, TRUE as multiple,
     'Les éléments en place sur la ruche sont déjà sélectionnés. La touche ''CTRL'' permet une sélection multiple.' as description,
     json_group_array(json_object("label", element, 
     "value", materiel.id,
     'selected', inventaire.element_id is not null
     )) as options  
     FROM materiel
     Left Join inventaire on inventaire.element_id=materiel.id 
     AND inventaire.ruche_id=$id;
