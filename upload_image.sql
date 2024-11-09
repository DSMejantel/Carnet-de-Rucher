SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));



--
set file_path = sqlpage.uploaded_file_path('Image');
--set file_name = sqlpage.random_string(10)||'.png';
set file_name = './album/'||sqlpage.random_string(10)||'.jpg';
set mv_result = sqlpage.exec('mv', $file_path, $file_name);

-- ajouter une photo
insert or ignore into image (image_url)
values (
    $file_name
)
returning 
'redirect' AS component,
'album.sql' as link;

-- If the insert failed, warn the user
select 'alert' as component,
    'red' as color,
    'alert-triangle' as icon,
    'Failed to upload image' as title,
    'Please try again with a smaller picture. Maximum allowed file size is 500Kb.' as description;

