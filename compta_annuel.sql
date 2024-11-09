SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--Titre
 select 
    'title'   as component,
    'Bilans annuels' as contents,
    TRUE as center,
    3         as level;

-- Livre de comptes
select 
    'datagrid' as component;
select 
    'Total des dépenses' as title,
    printf("%.2f", sum(prix)*(-1))||' €'  as description
    FROM finances where prix<0;
select 
    'Total des recettes' as title,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances where prix>0;

select 
    'Bilan financier' as title,
    CASE WHEN sum(prix)<0 Then 'red' ELSE 'green'
    END as color,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances;

--Onglets
SET tab=coalesce($tab,'5');
select 'tab' as component;
select  'Registre'  as title, 'pig-money' as icon, 1  as active, 'compta.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Enregistrer une dépense' as title, 'credit-card-pay' as icon, 0 as active, 'compta.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Enregistrer une recette' as title, 'credit-card-refund' as icon, 0 as active, 'compta.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Bilans annuels' as title, 'coins' as icon, 0 as active, 'compta_annuel.sql?tab=5' as link, CASE WHEN $tab='5' THEN 'orange' ELSE 'green' END as color WHERE $tab=5;

-- create a temporary table to preprocess the data
create temporary table if not exists Bilan_Annuel(annee,recettes, dépenses);
delete from Bilan_Annuel; 
insert into Bilan_Annuel(annee,recettes)
SELECT 
  strftime('%Y',date_created),prix from finances where prix>0;
insert into Bilan_Annuel(annee,dépenses)
SELECT 
  strftime('%Y',date_created),prix from finances where prix<0;  

select 
    'table' as component;
SELECT 
  annee as Année,
  printf("%.2f", sum(recettes))||' €' as Recettes,
  printf("%.2f", sum(dépenses)*(-1))||' €' as Dépenses,
  printf("%.2f", sum(recettes)+sum(dépenses))||' €'  as Bilan
    FROM Bilan_Annuel group by annee;
    
select 
    'chart' as component,
    'red' as color,
    TRUE as labels,
    'green' as color,
    'bar'      as type;
select 
    categorie as series,
    strftime('%Y',date_created) as x,
    CASE WHEN sum(prix)>0
    THEN  sum(prix)
    ELSE sum(prix)*(-1)
    END as y
    FROM finances group by strftime('%Y',date_created), categorie order by date_created;

select 
    'chart' as component,
    'Historique du solde' as title,
    'area'  as type,
    'red'   as color,
    1 as marker,
    TRUE as time,
    1000 as ymax;   
select 
    strftime('%Y-%m-%dT%H:%M:%fZ',date_created) as x,
    printf("%.2f",(SUM(prix) OVER(order by date_created))) as y
    FROM finances where prix<>0 ; 


