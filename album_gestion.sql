SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

 
    
select 
    'list'     as component,
    'Aucune photo' as empty_title,
    TRUE as compact,
    'Liste des photographies' as title;
select 
    image_url as image_url,
    group_concat(tag_image) as description,
    'album_tag.sql?id='||id as edit_link,
    'album_corbeille.sql?id='||id as delete_link,
    'album_vue.sql?id='||id as view_link,
    image_url as title
    FROM image LEFT JOIN tag on image.id=tag.image_id GROUP BY image.id ORDER BY created_at DESC;


