SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

 SET annee=coalesce($annee, CAST (strftime('%Y',current_date) as integer));
 
 -- create a temporary table to preprocess the data
create temporary table if not exists Exercices(annee);
delete from Exercices; 
insert into Exercices(annee)
SELECT 
  strftime('%Y',date_created) from finances where prix>0;
 
 -- Formulaire pour choisir l'année
 SELECT 
    'form' as component,
    ''   as validate,
    'An'      as id;
    SELECT 'annee' AS name, 'Année' as label, 'select' as type, 6 as width, $annee as value, json_group_array(json_object('label', annee, 'value', annee )) as options FROM (select distinct annee FROM Exercices ORDER BY annee);


