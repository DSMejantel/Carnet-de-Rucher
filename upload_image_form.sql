SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

  


    
-- Formulaire pour ajouter un emploi du temps
select 'form' as component, 'Choisir une photographie' as title, 'Publier' as validate, 'upload_image.sql' as action;
select 'file' as type, 'Image' as name;


    


