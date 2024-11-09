SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;


-- Bouton
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour' as title,
    'album_gestion.sql' as link,
    'arrow-back-up' as icon,
    'green' as outline; 

-- formulaire pour insérer tag
SELECT 
    'form' as component,
    'Mettre à jour' as validate,
    'upload_image_tag.sql?id='||$id as action,    
    'orange'           as validate_color;
    
SELECT 'tag[]' as name, 'Tags' as label, 6 as width, 'select' as type, TRUE as multiple, TRUE as dropdown, TRUE as create_new,
     'Les tags connus sont déjà sélectionnés.' as description,
     json_group_array(json_object(
     "label", tag_image, 
     "value", tag_image,
     'selected', tag.image_id=$id
     )) as options  
     FROM tag
     Left Join image on tag.image_id=image.id 
     AND tag.image_id=$id;
     
-- Aperçu    
select 
    'card'     as component,
    '' as title,
    2 as columns,
    6              as width;
select 
    image_url as top_image
    FROM image WHERE image.id=$id;




