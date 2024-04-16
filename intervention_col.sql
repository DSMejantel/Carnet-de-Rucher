SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

-- Titre : Ruche
SELECT 'table' as component;
SELECT 
    numero as Numero,
    nom as Rucher,
    rang as Rangée,
    code as _sqlpage_color,
    type as Ruche,
    début as Début,
    reine as Reine,
    caractere as Caractères,
    info as infos
	FROM colonie JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id WHERE colonie.numero=$id; 

-- Ajouter une intervention
    SELECT 
    'form' as component,
    'ruche.sql?id='||$id as action,
    --'Ajouter' as validate,
    'green'           as validate_color,
    'Recommencer'           as reset;
    
    SELECT 'Date' AS label, 'horodatage' AS name, 'date' as type, (select date('now')) as value, 3 as width;
    SELECT 'Bilan' AS name, 'select' as type, 1 as value, '[{"label": "Normal", "value": 1}, {"label": "Vigilance", "value": 2}, {"label": "Alerte", "value": 3}]' as options, TRUE as required, 3 as width;
    SELECT 'Intervention' AS label, 'suivi' AS name, 'select' as type, 3 as width, json_group_array(json_object("label" , action, "value", id )) as options FROM (select id, action FROM intervention  UNION ALL
  SELECT NULL, 'Aucune'
);
    SELECT 'Inscription au registre d''élevage' AS label, 'registre' AS name, 'checkbox' as type, 1 as value, 3 as width; 
    SELECT 'Détails' AS label, 'details' AS name, 'textarea' as type, 12 as width;



