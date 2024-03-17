--Menu
SELECT 'dynamic' AS component, 
CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN sqlpage.read_file_as_text('home.json')
        ELSE sqlpage.read_file_as_text('menu.json')
    END AS properties;

/*SELECT 'shell' AS component,
    'Suivi de rucher' as title,
    'fr-FR'   as language,
    'flower' as icon,
    '/' as link,
    TRUE as norobot,
        CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN '["login"]'
        ELSE '["ruchers", "ruches", "suivis", "parametres", "logout"]'
    END AS menu_item;
*/   
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));    

---- Ligne d'identification de l'utilisateur et de son mode de connexion
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'Connexion'
        ELSE 'Mon profil' 
        END as title,
    CASE COALESCE(sqlpage.cookie('session'), '')
        WHEN '' THEN 'signin.sql'
        ELSE 'parametres.sql?tab=1' 
        END as link,
    'user-circle' as icon,
    'orange' as outline; 
SELECT 'text' AS component;
SELECT
'orange' as color,
COALESCE((SELECT
    format('Connecté en tant que %s %s',
            user_info.prenom,
            user_info.nom)
    FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')
), 'L''accès aux informations de cette application nécessite d''être identifié.') AS contents;
  
-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;

-- Boutons de page d'accueil
select 
    'button' as component,
    'lg'     as size,
    'center' as justify,
    'pill'   as shape;

SELECT 
    'Commande' as title,
    'order_form.sql' as link,
    'receipt-2' as icon,  
    'green' as outline; 
    
select 
    'Mes ruchers' as title,
    'ruchers.sql' as link,
    'grip-horizontal' as icon,
    'green' as outline;    

SELECT 
    'Mes ruches' as title,
    'ruches.sql' as link,
    'archive' as icon,  
    'green' as outline; 

select 
    'Paramètres' as title,
    'parametres.sql' as link,
    'tool' as icon,
    'green' as outline;


    

