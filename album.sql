SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

SET tag=coalesce($tag,'Tout');

-- Navigation via les tags
-- Solution 1 : Menu déroulant
select 
    'big_number'          as component;
select 
    'Recherche de photographies par mot-clé' as title,
    'blue'    as color,
    json_group_array(json_object(
    'label', tag_image,
    'link', 'album.sql?tag='||tag_image))  as dropdown_item
    FROM (SELECT tag_image, tag_image from image LEFT JOIN tag on image.id=tag.image_id group by tag_image union all select '- Tout' as label, 'Tout' as link  order by label);

-- Solution 2 : boutons
/* 
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    'Tout' as title,
    'album.sql?tag=' ||'Tout' as link,
    'green' as outline;
select 
    tag_image as title,
    'album.sql?tag=' || tag_image as link,
    'green' as outline
    FROM tag GROUP BY tag_image ORDER BY tag_image ASC;
*/

-- Vignettes    
select 
    'card'     as component;
select 
    image_url as top_image,
      '[
  ![](./icons/pencil.svg)
](album_tag.sql?id='||id||' "Éditer les étiquettes")' as footer_md,
    group_concat(tag_image) as footer,
    'album_vue.sql?id='||id||'&tag='||$tag as link,
    2 as width
    FROM tag LEFT JOIN image on image.id=tag.image_id WHERE tag_image=$tag GROUP BY image.id ORDER BY created_at DESC;
select 
    image_url as top_image,
        '[
  ![](./icons/pencil.svg)
](album_tag.sql?id='||id||' "Éditer les étiquettes")' as footer_md,
    group_concat(tag_image,' ') as description,
        'album_vue.sql?id='||id||'&tag='||$tag as link,
    2 as width
    FROM image LEFT JOIN tag on image.id=tag.image_id WHERE $tag='Tout' GROUP BY image.id ORDER BY created_at DESC;
    



