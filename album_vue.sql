SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

 
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;

-- Boutons retour
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Retour' as title,
    CASE WHEN $tag is Null THEN 'album_gestion.sql' 
    ELSE 'album.sql?tag='||$tag END as link,
    'arrow-back-up' as icon,
    'green' as outline; 

    
        
select 
    'card'     as component,
    '' as title,
    1 as columns,
    12              as width;
select 
    image_url as top_image
    FROM image WHERE image.id=$id;




