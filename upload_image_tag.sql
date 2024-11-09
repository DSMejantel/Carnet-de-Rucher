SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Supprime les anciens tags
DELETE FROM tag WHERE image_id=$id;
-- Insère l'affectation à un dispositif
-- ajouter un tag
insert  into tag (image_id, tag_image)
SELECT
    $id as image_id,
    CAST(value AS text) as tag_image from json_each(:tag) WHERE :tag IS NOT NULL

returning 
'redirect' AS component,
'album_gestion.sql' as link;



