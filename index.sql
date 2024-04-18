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
/*select 
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
        ELSE 'user.sql' 
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
*/  
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

select 
    'Utilisateurs' as title,
    './comptes/comptes.sql' as link,
    'user' as icon,
    'orange' as outline
    where $group_id=3;

-- onglet : Stats - nombre et état des colonies
SELECT 
    'datagrid' as component WHERE sqlpage.cookie('session') is not null;
select 
    distinct nom as title,
    CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE disparition::int<>1 and rucher.id=colonie.rucher_id)<2
    	THEN (SELECT count(distinct numero)||' ruche' FROM colonie WHERE disparition::int<>1 and rucher.id=colonie.rucher_id)
    	ELSE (SELECT count(distinct numero)||' ruches' FROM colonie WHERE disparition::int<>1 and rucher.id=colonie.rucher_id) END   as description,
    CASE WHEN (SELECT count(numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and disparition::int<>1)<2
    	THEN (SELECT count(numero)||' ruche à surveiller' FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and disparition::int<>1) 
    	ELSE (SELECT count(distinct numero)||' ruches à surveiller' FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and disparition::int<>1) END as footer,
    	CASE WHEN (SELECT count(distinct tracing) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id)>0
    	THEN 'alert-triangle-filled'              END    as icon,
    	'orange' as color,
    	'rucher.sql?tab=1&id='||rucher.id as link
    FROM rucher left join colonie on rucher.id=colonie.rucher_id where (SELECT count(distinct numero) FROM colonie WHERE disparition::int<>1 and rucher.id=colonie.rucher_id)>0 and sqlpage.cookie('session') is not null;

    
--Liste des ruches à surveiller
SELECT 'table' as component,
	1 as sort,
	'Alerte' as markdown,
	'Actions' as markdown,
	'Reine' as markdown,
	'Rucher' as markdown,
	'Ruche' as markdown where sqlpage.cookie('session') is not null;
SELECT 
    CASE WHEN tracing=2
    THEN '[
    ![](./icons/alert-orange.svg)
]()'
    WHEN tracing=3
    THEN '[
    ![](./icons/alert-red.svg)
]()'
    ELSE '[
    ![](./icons/alert-green.svg)
]()'
    END as Alerte,
    numero as Num,
    '[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=1&id='||colonie.rucher_id||')' as Rucher,
    nom as Rucher,
    rang as Rang,
    '[
    ![](./icons/archive_'||code||'.svg)
]()' as Ruche,
    type as Ruche,
    strftime('%d/%m/%Y',début) as Début,
    '[
    ![](./icons/circle-number-'||substr( reine, -1,1 )||'.svg)
]()' as Reine,
    reine as Reine,
    caractere as Caractères,
    info as infos,
'[
    ![](./icons/eye.svg)
](ruche.sql?tab=1&id='||colonie.numero||')[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||')[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||')' as Actions
	 FROM colonie INNER JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id  where tracing>1 and sqlpage.cookie('session') is not null ORDER BY nom, rang;

    

