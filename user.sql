SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

---- Ligne d'identification de l'utilisateur et de son mode de connexion
SELECT 'text' AS component;
SELECT
'green' as color,
COALESCE((SELECT
    format('Connecté en tant que %s %s (mode : %s)',
            user_info.prenom,
            user_info.nom,
           CASE groupe
                WHEN 1 THEN 'Consultation'
                WHEN 2 THEN 'Édition'
                WHEN 3 THEN 'Administration'
            END)
    FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')
), 'Non connecté') AS contents;

 -- Boutons administration du profil
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'start' as justify;
select 
    'Éditer mon Compte' as title,
    'comptes_user.sql' as link,
    'pencil' as icon,
    'green' as outline;
select 
    'Changer mon mot de passe' as title,
    'comptes_user_password.sql' as link,
    'lock' as icon,
    'green' as outline;
select 
    'Administration des utilisateurs' as title,
    './comptes/comptes.sql' as link,
    'user' as icon,
    'orange' as outline
    where $group_id=3;
   
-- Profil
SET user_edit = (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));
SELECT 'table' as component,
    'nom' as Nom,
    'prenom' as Prénom,
    'tel' as Téléphone,
    'courriel' as courriel;
SELECT 
  username as Identifiant,
  nom AS Nom,
  prenom AS Prénom,
  tel as Téléphone,
  courriel as courriel
FROM user_info WHERE username=$user_edit;
