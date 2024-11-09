SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;
--Titre
 select 
    'title'   as component,
    'Registre de comptes' as contents,
    TRUE as center,
    3         as level;
    
-- Enregistrer une recette dans la base
INSERT INTO finances (categorie, operation, prix, date_created, moyen)
SELECT
'Recette' as categorie, 
:OPrec as operation, 
:recette as prix,
:DateRec as date_created, 
:paiementR as moyen 
WHERE :recette is not null and $rec=1;

-- Enregistrer une dépense dans la base
INSERT INTO finances  (categorie, operation, prix, date_created, moyen)
SELECT
'Dépense' as categorie, 
:OPdep as operation, 
(:depense)*(-1) as prix, 
:DateDep as date_created,
:paiementD as moyen  
WHERE :depense is not null and $dep=1;



--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component;
select  'Registre'  as title, 'pig-money' as icon, 1  as active, 'compta.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'orange' ELSE 'green' END as color;
select  'Enregistrer une dépense' as title, 'credit-card-pay' as icon, 0 as active, 'compta.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'orange' ELSE 'green' END as color;
select  'Enregistrer une recette' as title, 'credit-card-refund' as icon, 0 as active, 'compta.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'orange' ELSE 'green' END as color;
select  'Bilans annuels' as title, 'coins' as icon, 0 as active, 'compta.sql?tab=4' as link, CASE WHEN $tab=4 THEN 'orange' ELSE 'green' END as color;
--select  'Opérations neutralisées' as title, 'coin-off' as icon, 0 as active, 'compta.sql?tab=5' as link, CASE WHEN $tab=5 THEN 'orange' ELSE 'green' END as color;


-- Bilan annuels
/*select 
    'title'   as component,
    'Bilans pluri-annuels' as contents,
    TRUE as center,
    3         as level
        where $tab=4; 
           
select 
    'datagrid' as component  where $tab=4;
select 
    'Total des recettes pour '||strftime('%Y',date_created) as title,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances where prix>0 and strftime('%Y',date_created) = strftime('%Y',CURRENT_DATE)  and $tab=4;
select 
    'Total des dépenses pour '||strftime('%Y',date_created) as title,
    printf("%.2f", sum(prix)*(-1))||' €'  as description
    FROM finances where prix<0 and strftime('%Y',date_created) = strftime('%Y',CURRENT_DATE)  and $tab=4;
select 
    'Bilan financier pour '||strftime('%Y',date_created) as title,
    CASE WHEN sum(prix)<0 Then 'red' ELSE 'green'
    END as color,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances WHERE strftime('%Y',date_created) = strftime('%Y',CURRENT_DATE)  and $tab=4;

select 
    'datagrid' as component  where $tab=4;
select 
    'Total des recettes pour '||strftime('%Y',date_created) as title,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances where prix>0 and CAST(strftime('%Y',date_created) as integer)+1 = CAST(strftime('%Y',CURRENT_DATE) as integer)  and $tab=4;
select 
    'Total des dépenses pour '||strftime('%Y',date_created) as title,
    printf("%.2f", sum(prix)*(-1))||' €'  as description
    FROM finances where prix<0 and CAST(strftime('%Y',date_created) as integer)+1 = CAST(strftime('%Y',CURRENT_DATE) as integer)  and $tab=4;
select 
    'Bilan financier pour '||strftime('%Y',date_created) as title,
    CASE WHEN sum(prix)<0 Then 'red' ELSE 'green'
    END as color,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances WHERE CAST(strftime('%Y',date_created) as integer)+1 = CAST(strftime('%Y',CURRENT_DATE) as integer)  and $tab=4;

-- Livre de comptes
select 
    'datagrid' as component,
    'coins' as icon,
    'Bilan général' as title,
    'total des années' as description where $tab=4; 
select 
    'Total des recettes' as title,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances where prix>0 and $tab=4; 
select 
    'Total des dépenses' as title,
    printf("%.2f", sum(prix)*(-1))||' €'  as description
    FROM finances where prix<0  and $tab=4; 
select 
    'Bilan financier' as title,
    CASE WHEN sum(prix)<0 Then 'red' ELSE 'green'
    END as color,
    printf("%.2f", sum(prix))||' €'   as description
    FROM finances  where $tab=4; 
*/   
-- Tableau pluri-annuel
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
    'table' as component where $tab=4;
SELECT 
  annee as Année,
  printf("%.2f", sum(recettes))||' €' as Recettes,
  printf("%.2f", sum(dépenses)*(-1))||' €' as Dépenses,
  printf("%.2f", sum(recettes)+sum(dépenses))||' €'  as Bilan
    FROM Bilan_Annuel where $tab=4 group by annee;
SELECT 
  'Total' as Année,
  'github' as _sqlpage_color,
  printf("%.2f", sum(recettes))||' €' as Recettes,
  printf("%.2f", sum(dépenses)*(-1))||' €' as Dépenses,
  printf("%.2f", sum(recettes)+sum(dépenses))||' €'  as Bilan
    FROM Bilan_Annuel where $tab=4;

select 
    'chart' as component,
    'red' as color,
    'green' as color,
    TRUE as labels,
    'bar'      as type
    where $tab=4;

select 
    categorie as series,
    strftime('%Y',date_created) as x,
    CASE WHEN sum(prix)>0
    THEN  sum(prix)
    ELSE sum(prix)*(-1)
    END as y
    FROM finances where $tab=4 group by strftime('%Y',date_created), categorie order by date_created; 
   
select 
    'chart' as component,
    'Historique du solde' as title,
    'area'  as type,
    'red'   as color,
    2 as marker,
    TRUE as time,
    TRUE as toolbar,
    1000 as ymax
    where $tab=4;   
select 
    strftime('%Y-%m-%dT%H:%M:%fZ',date_created) as x,
    printf("%.2f",(SUM(prix) OVER(order by date_created))) as y
    FROM finances where prix<>0  and $tab=4; 

-- Enregistrer une recette
SELECT 'form' as component,
    --'Enregistrer une recette' as title,
    'recette' as id,
    '' as validate
     where $tab=3;

SELECT 'OPrec' as name, 'Opération' as label, 'Description de la recette' AS placeholder, 9 as width where $tab=3;
SELECT 'recette' as name, 'Montant' as label, 'number' AS type, 0.01 as step, 0 as min, TRUE as required, 3 as width where $tab=3;
SELECT 'Date' AS label, 'DateRec' AS name, (select date('now')) as value, 'date' as type, 3 as width where $tab=3;
select 
    'paiementR' as name,
    'radio' as type,
    1       as value,
    'Espèces' as label,
    3 as width
    where $tab='3';
select 
    'paiementR'  as name,
    'radio'  as type,
    2        as value,
    'Chèque' as label,
    3 as width
    where $tab='3';
select 
    'paiementR'  as name,
    'radio'  as type,
    3        as value,
    'Virement ou CB' as label,
    3 as width
    where $tab='3';

select 
    'button' as component
     where $tab='3';
select 
    'compta.sql?tab=1&rec=1' as link,
    'recette'         as form,
    'green'      as color,
    'Enregistrer et retour' as title
    where $tab='3';
select 
    'compta.sql?tab=3&rec=1' as link,
    'recette'            as form,
    'orange'          as color,
    'Enregistrer et nouveau' as title
    where $tab='3';

-- Enregistrer une dépense
SELECT 'form' as component,
    --'Enregistrer une dépense' as title,
    'depense' as id,
    '' as validate
     where $tab=2;

SELECT 'OPdep' as name, 'Opération' as label, 'Description de la dépense' AS placeholder, 9 as width where $tab=2;
SELECT 'depense' as name, 'Montant' as label, 'number' AS type, 0.01 as step, 0 as min,TRUE as required, 3 as width where $tab=2;
SELECT 'Date' AS label, 'DateDep' AS name, (select date('now')) as value, 'date' as type, 3 as width where $tab=2;
select 
    'paiementD' as name,
    'radio' as type,
    1       as value,
    'Espèces' as label,
    3 as width
    where $tab='2';
select 
    'paiementD'  as name,
    'radio'  as type,
    2        as value,
    'Chèque' as label,
    3 as width
    where $tab='2';
select 
    'paiementD'  as name,
    'radio'  as type,
    3        as value,
    'Virement ou CB' as label,
    3 as width
    where $tab='2';

select 
    'button' as component
     where $tab='2';
select 
    'compta.sql?tab=1&dep=1' as link,
    'depense'         as form,
    'green'      as color,
    'Enregistrer et retour' as title
    where $tab='2';
select 
    'compta.sql?tab=2&dep=1' as link,
    'depense'            as form,
    'orange'          as color,
    'Enregistrer et nouveau' as title
    where $tab='2';




--Titre
 SET annee=coalesce((SELECT $annee WHERE $annee<>'Années'), (CAST (strftime('%Y',current_date)as integer)));
-- Choix de l'année pour le registre
select 
    'big_number'          as component where $tab='1';
select 
    'Année' as title,
    $annee as value,
    'black'    as color,
    'Rentabilité par rapport aux dépenses :' as description,
    (SELECT printf("%.2f", (sum(recettes)+sum(dépenses))/sum(dépenses)*(-100)) FROM Bilan_Annuel WHERE annee=$annee) as change_percent,
    CASE WHEN (SELECT sum(recettes)+sum(dépenses) FROM Bilan_Annuel WHERE annee=$annee)>0
    THEN (SELECT printf("%.2f", (sum(recettes)+sum(dépenses))/sum(dépenses)*(-100)) FROM Bilan_Annuel WHERE annee=$annee)
    ELSE 100+(SELECT printf("%.2f", (sum(recettes)+sum(dépenses))/sum(dépenses)*(-100)) FROM Bilan_Annuel WHERE annee=$annee)              
    END as progress_percent,
    CASE WHEN (SELECT sum(recettes)+sum(dépenses) FROM Bilan_Annuel WHERE annee=$annee)>0
    THEN 'green' 
    ELSE 'red'          
    END as progress_color,
    json_group_array(json_object(
    'label', annee,
    'link', 'compta.sql?annee='||annee))  as dropdown_item
    FROM (select distinct annee,annee FROM Bilan_Annuel union all select 'Années' as label, '0' as link  order by label DESC)  where $tab='1';

/*
 SELECT 
    'form' as component,
    'An' as id,
    ''   as validate
     where $tab='1';   
    SELECT 'annee' AS name, 'Année' as label, 'select' as type, 6 as width, $annee as value, json_group_array(json_object('label', annee, 'value', annee )) as options FROM (select distinct annee FROM Bilan_Annuel ORDER BY annee)  where $tab='1';
        
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape
    where $tab='1';
select 
    'button' as component  where $tab='1';
select 
    'compta.sql?tab=1&annee=' || $annee  as link,
    'An'         as form,
    'green'      as color,
    'Sélectionner'         as title
    where $tab='1';
select 
    'Opérations annulées' as title,
    'compta.sql?tab=4' as link,
    'coin-off' as icon,
    'red' as outline
    where $tab='1'; 
*/
/*
-- Choix de l"année : ancienne méthode
select 
    'card' as component,
     2      as columns
     where $tab='1';
select 
    '/compta/form.sql?_sqlpage_embed&annee=' || $annee as embed
    where $tab='1';
select 
    '/compta/liste.sql?_sqlpage_embed&annee=' || $annee as embed
    where $tab='1';
*/
 select 
    'title'   as component,
    'Historique des opérations pour '||$annee as contents,
    TRUE as center,
    3         as level
        where $tab='1'; 
select 
    'table' as component,
    TRUE as hover,
    TRUE as small,
    TRUE    as sort,
    TRUE    as search,
    TRUE as striped_rows,
    'Montant' as align_right,
    'Solde' as align_right,    
    'Paiement' as icon,
    'Annuler' as align_right,
    'Annuler' as markdown,
    'Facture' as markdown
    where $tab='1';
    
select 
    strftime('%d/%m/%Y',date_created) as Date,
    CASE WHEN prix=0
    THEN 'vk'
    ELSE 'gray-700'
    END as _sqlpage_color,
    --categorie as Nature,
    CASE WHEN moyen=1 THEN 'coins'
    WHEN moyen=2 THEN 'writing-sign'
    ELSE 'credit-card-pay' 
    END as Paiement,
    CASE WHEN facture_id is not null
    THEN    '[
    ![](./icons/receipt-2.svg)
](order.sql?facture='||facture_id||'&tab=4)' 
    ELSE '' 
    END as Facture,
    facture_id as N°,
    operation as Opération,
    printf("%.2f", prix) as Montant,
    printf("%.2f",(SUM(prix) OVER(order by date_created))) as Solde,
    CASE WHEN $group_id=3 and prix<>0
    THEN '[
    ![](./icons/coin-off.svg)
](./compta/compta_annulation.sql?id='||id||')' 
    END as Annuler
    FROM finances WHERE CAST(strftime('%Y',date_created) as integer)=$annee and $tab='1' ORDER BY date_created DESC;
    
-- Opérations annulées
select 
    'table' as component,
    TRUE as hover,
    TRUE as small,
    TRUE    as sort,
    TRUE    as search,
    'Montant' as align_right,
    'Paiement' as icon,
    'Facture' as markdown
    where $tab=5;
    
select 
    strftime('%d/%m/%Y',date_created) as Date,
    CASE WHEN categorie='Recette'
    THEN 'green'
    ELSE 'red'
    END as _sqlpage_color,
    --categorie as Nature,
    CASE WHEN moyen=1 THEN 'coins'
    WHEN moyen=2 THEN 'writing-sign'
    ELSE 'credit-card-pay' 
    END as Paiement,
    CASE WHEN facture_id is not null
    THEN    '[
    ![](./icons/receipt-2.svg)
](order.sql?facture='||facture_id||'&tab=4)' 
    ELSE '' 
    END as Facture,
    facture_id as N°,
    operation as Opération,
    printf("%.2f", prix) as Montant
    FROM finances WHERE prix=0 and $tab=5 ORDER BY date_created DESC;


