SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SELECT 'dynamic' AS component, sqlpage.read_file_as_text('menu.json') AS properties;

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


-- Enregistrer une recette
SELECT 'form' as component,
    'Enregistrer une recette' as title,
    'recette' as id,
    '' as validate
     where $tab=3;

SELECT 'OPrec' as name, 'Opération' as label, 'Description de la recette' AS placeholder, 9 as width where $tab=3;
SELECT 'recette' as name, 'Montant' as label, 'number' AS type, TRUE as required, 3 as width where $tab=3;
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
    'Virement' as label,
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
    'Enregistrer une dépense' as title,
    'depense' as id,
    '' as validate
     where $tab=2;

SELECT 'OPdep' as name, 'Opération' as label, 'Description de la dépense' AS placeholder, 9 as width where $tab=2;
SELECT 'depense' as name, 'Montant' as label, 'number' AS type, TRUE as required, 3 as width where $tab=2;
SELECT 'Date' AS label, 'DateDep' AS name, 'date' as type, 3 as width where $tab=3;
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
    'Virement' as label,
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
    'compta.sql?tab=3&dep=1' as link,
    'depense'            as form,
    'orange'          as color,
    'Enregistrer et nouveau' as title
    where $tab='2';


-- Livre de comptes
select 
    'datagrid' as component,
    'Livre de compte' as title,
    'coins' as icon
     WHERE  $tab='1';
select 
    'Total des dépenses' as title,
    sum(prix)  as description
    FROM finances where prix<0  and  $tab='1';
select 
    'Total des recettes' as title,
    sum(prix)  as description
    FROM finances where prix>0  and  $tab='1';

select 
    'Bilan financier' as title,
    sum(prix)  as description
    FROM finances WHERE  $tab='1';


select 
    'table' as component,
    TRUE as hover,
    TRUE as small,
    TRUE    as sort,
    TRUE    as search,
    'Montant  (€)' as align_right,
    'Paiement' as icon,
    'Facture' as markdown
    where $tab='1';
    
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
    FROM finances WHERE $tab='1' ORDER BY date_created;






