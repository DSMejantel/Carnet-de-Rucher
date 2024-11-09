SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


select 'dynamic' as component,
  '[' ||
    json_object(
          'component', 'tracking',
          'title', 'Rangée ' || rang,
          'width', 12
    ) || ',' ||
    group_concat(json_object(
        'title', 'Ruche '||numero,
        'color', case tracing when 3 then 'red' when 2 then 'orange' else 'green' end ) ORDER BY position) ||
  ']' as properties
from colonie WHERE colonie.rucher_id=$id and disparition<>1 GROUP BY rang ORDER BY rang;

