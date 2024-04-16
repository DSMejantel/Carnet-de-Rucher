SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

-- Mettre à jour le compte modifié dans la base
 UPDATE user_info SET nom=$nom, prenom=$prenom, tel=$tel, courriel=$courriel WHERE username=$user_edit and $nom is not null
  RETURNING
   'redirect' AS component,
   'user.sql' as link; 



