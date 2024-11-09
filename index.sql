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

-- Menus avancés
select 
    'big_number'          as component,
    4 as columns;
select 
    'Ruchers' as title,
    (SELECT count(distinct id) from rucher) as value,
    'blue'    as color,
    json_group_array(json_object(
    'label', nom,
    'link', 'rucher.sql?id='||id))  as dropdown_item
    FROM (select nom, id from rucher union all select '- Tous' as label, '0' as link order by nom);
select 
    'Ruches' as title,
    (SELECT count(distinct numero) from colonie WHERE disparition <>1) as value,
    'green'    as color,
    json_group_array(json_object(
    'label', numero,
    'link', 'ruche.sql?id='||numero) ORDER BY numero)  as dropdown_item
    FROM (select numero, numero from colonie WHERE disparition <>1 union all select '- Toutes' as label, '- Toutes' as link order by numero ASC);
select 
    'La boutique' as title,
    count(distinct id)||' produits' as value,
    'orange'    as color,
    json_array(json_object(
    'label', 'catalogue',
    'link', '/miellerie.sql?tab=2'),
    json_object(
    'label', 'commander',
    'link', '/order_form.sql')
    ,json_object(
    'label', 'factures',
    'link', '/order.sql'))  as dropdown_item
    FROM produits WHERE vente=1;
select 
    'Documents' as title,
    '3 registres' as value,
    'red'    as color,
    json_array(json_object(
    'label', 'registre d''élevage',
    'link', '/elevage.sql?tab=2'),
    json_object(
    'label', 'registre de miellerie',
    'link', '/miellerie.sql')
    ,json_object(
    'label', 'registre de comptes',
    'link', '/compta.sql'))  as dropdown_item;

    
-- Boutons de page d'accueil
/*select 
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
*/    
-- onglet : Stats - nombre et état des ruchers
select 
    'columns' as component;
select 
    distinct nom as title,
    (SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id) as value,
    CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id)<2
    	THEN ' ruche' 
    	ELSE ' ruches'  END as small_text,
 
    'rucher.sql?tab=2&id='||rucher.id          as link,
    CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE tracing=3 and rucher.id=colonie.rucher_id and disparition<>1)>0
    	THEN 'red'
    	WHEN (SELECT count(distinct numero) FROM colonie WHERE tracing=2 and rucher.id=colonie.rucher_id and disparition<>1)>0
    	THEN 'orange'
    	ELSE 'green' 
    	END as value_color,
    	
    json_array(json_object('icon', 'alert-square', 'color','orange','description','Vigilance sur : '||(SELECT  coalesce(group_concat(numero, ' - '),'aucune') FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1))) as item,
     'Voir le rucher'     as button_text,
    'vk' as button_color
    FROM rucher left join colonie on rucher.id=colonie.rucher_id where (SELECT count(distinct numero) FROM colonie WHERE disparition<>1 and rucher.id=colonie.rucher_id)>0 and sqlpage.cookie('session') is not null GROUP BY rucher.id;
    
-- onglet : Stats - nombre et état des ruchers
/*select 
    'big_number' as component,
    2 as columns;
select 
    distinct nom as title,
    (SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id) as value,
    CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id)<2
    	THEN ' ruche' 
    	ELSE ' ruches'  END as unit,
    	
        CASE WHEN (SELECT count(numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and disparition::int<>1)=0
    	THEN 'aucune ruche à surveiller'
        WHEN (SELECT count(numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and disparition::int<>1)=1
    	THEN (SELECT count(numero)||' ruche à surveiller'||CHAR(10)||CHAR(10)|| ' : '||numero FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1) 
    	ELSE (SELECT count(distinct numero)||' ruches à surveiller'||CHAR(13)||CHAR(13)|| 'N° : '||group_concat(numero, ' - ') FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1) END as description,

    CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE tracing=3 and rucher.id=colonie.rucher_id and disparition::int<>1)>0
    	THEN 'red'
    	WHEN (SELECT count(distinct numero) FROM colonie WHERE tracing=2 and rucher.id=colonie.rucher_id and disparition::int<>1)>0
    	THEN 'orange'
    	ELSE 'green' 
    	END as color,
    	
    100*((SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id)-(SELECT count(distinct numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1))/(SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id) as progress_percent,

    CASE WHEN (100*((SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id)-(SELECT count(distinct numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1))/(SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id))>91
    THEN 'green'
    WHEN (100*((SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id)-(SELECT count(distinct numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1))/(SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id))>60
    THEN 'orange' 
    ELSE 'red' END as progress_color
    FROM rucher left join colonie on rucher.id=colonie.rucher_id where (SELECT count(distinct numero) FROM colonie WHERE disparition::int<>1 and rucher.id=colonie.rucher_id)>0 and sqlpage.cookie('session') is not null;
*/

/*SELECT 
    'datagrid' as component WHERE sqlpage.cookie('session') is not null;
select 
    distinct nom as title,
    CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id)<2
    	THEN (SELECT count(distinct numero)||' ruche' FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id)
    	ELSE (SELECT count(distinct numero)||' ruches' FROM colonie WHERE CAST(disparition as integer)<>1 and rucher.id=colonie.rucher_id) END   as description,
    CASE WHEN (SELECT count(numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1)<2
    	THEN (SELECT count(numero)||' ruche à surveiller' FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1) 
    	ELSE (SELECT count(distinct numero)||' ruches à surveiller' FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id  and CAST(disparition as integer)<>1) END as footer,
    	CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE tracing>1 and rucher.id=colonie.rucher_id and disparition::int<>1)>0
    	THEN 'alert-triangle'              
    	ELSE 'thumb-up'
    	END as icon,
    	CASE WHEN (SELECT count(distinct numero) FROM colonie WHERE tracing=3 and rucher.id=colonie.rucher_id and disparition::int<>1)>0
    	THEN 'red'
    	WHEN (SELECT count(distinct numero) FROM colonie WHERE tracing=2 and rucher.id=colonie.rucher_id and disparition::int<>1)>0
    	THEN 'orange'
    	ELSE 'green' 
    	END as color,
    	'rucher.sql?tab=1&id='||rucher.id as link
    FROM rucher left join colonie on rucher.id=colonie.rucher_id where (SELECT count(distinct numero) FROM colonie WHERE disparition::int<>1 and rucher.id=colonie.rucher_id)>0 and sqlpage.cookie('session') is not null;
*/
    
--Liste des ruches à surveiller
SELECT 'table' as component,
	TRUE as sort,
	'Pas de ruche sous surveillance' as empty_description,
	'Alerte' as markdown,
	'Actions' as markdown,
	'Reine' as markdown,
	'Rucher' as markdown,
	'Ruche' as markdown where sqlpage.cookie('session') is not null;
SELECT 
    CASE WHEN tracing=2
    THEN '[
    ![](./icons/alert-orange.svg)
](ruche.sql?tab=1&id='||colonie.numero||')'
    WHEN tracing=3
    THEN '[
    ![](./icons/alert-red.svg)
](ruche.sql?tab=1&id='||colonie.numero||')'
    END as Alerte,
    numero as Num,
    '[
    ![](./icons/grip-horizontal.svg)
](rucher.sql?tab=1&id='||colonie.rucher_id||')' as Rucher,
    nom as Rucher,
    rang as Rang,
    '[
    ![](./icons/archive_'||code||'.svg)
](ruche.sql?tab=1&id='||colonie.numero||')' as Ruche,
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
](ruche.sql?tab=1&id='||colonie.numero||' "Visualiser")[
    ![](./icons/pencil.svg)
](ruche.sql?tab=2&id='||colonie.numero||' "Mettre à jour")[
    ![](./icons/tool.svg)
](intervention_col.sql?id='||colonie.numero||' "Noter une intervention")' as Actions
	 FROM colonie INNER JOIN rucher on colonie.rucher_id=rucher.id JOIN couleur on colonie.couleur=couleur.id JOIN modele on colonie.modele=modele.id  where tracing>1 and disparition<>1 and sqlpage.cookie('session') is not null ORDER BY nom, rang;

/*select 
    'carousel'     as component,
    '' as title,
    12              as width,
    TRUE           as center,
    TRUE           as controls,
    TRUE           as auto;
select 
    image_url as image
    FROM image ORDER BY created_at DESC;
*/
-- Liste des dernières interventions
select 
    'button' as component,
    'sm'     as size,
    'center' as justify,
    'pill'   as shape
    WHERE sqlpage.cookie('session') is not null;
select 
    'Liste des dernières interventions' as title,
    'tool' as icon,
    'azure' as outline
    WHERE sqlpage.cookie('session') is not null;
    
   
select 
    'list' as component
    WHERE sqlpage.cookie('session') is not null;
select 
    CASE WHEN tracing='1' THEN 'green'
    WHEN tracing='2' THEN 'orange' 
    WHEN tracing='3' THEN 'red' 
    END as color,
    CASE WHEN tracing=1
    THEN FALSE
    ELSE TRUE
    END as active,
    'Colonie '||ruche_id||' - '||strftime('%d/%m/%Y',horodatage)||' : '||action as title,
    details as description,
    '/intervention/intervention_col_edit.sql?intervention='||colvisite.id||'&id='||ruche_id as edit_link,
    '/ruche.sql?tab=1&id='||ruche_id as view_link
    FROM colvisite INNER JOIN intervention on colvisite.suivi=intervention.id WHERE sqlpage.cookie('session') is not null order by horodatage DESC LIMIT 15;   

