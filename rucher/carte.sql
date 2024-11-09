SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SET aire=coalesce($aire,0);

select 
    'button' as component;
select 
    'rucher.sql?tab=1&aire=1&id='||$id as link,
    'Afficher l''aire de butinage'            as title,
    'eye'  as icon,
    CASE WHEN $aire=1
    THEN TRUE
    ELSE FALSE
    END as disabled;
select 
    'rucher.sql?tab=1&aire=0&id='||$id as link,     
    'Masquer l''aire de butinage' as title,
    'eye-off'  as icon,
    CASE WHEN $aire<>1 or $aire is Null
    THEN TRUE
    ELSE FALSE
    END as disabled;

SELECT 
    'map' as component,
    13 as zoom,
    Lat as latitude,
    Lon as longitude,
    600 as height,
    'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png' as tile_source,
    ''    as attribution
    FROM rucher WHERE id=$id; 

SELECT
    nom as title,
    Lat AS latitude, 
    Lon AS longitude,
    'home' as icon
    FROM rucher WHERE id=$id; 
SELECT
    CASE WHEN $aire=1 and $tab=1
    THEN'red' 
    ELSE ''
    END as color,
    CASE WHEN $aire=1
    THEN
'{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [
              '||Lon||', '||sum(Lat-0.023)||'
            ],
            [
              '||sum(Lon+0.023)||', '||sum(Lat-0.016)||'
            ],
            [
              '||sum(Lon+0.032)||', '||Lat||'
            ],
            [
              '||sum(Lon+0.023)||', '||sum(Lat+0.016)||'
            ],
            [
              '||Lon||', '||sum(Lat+0.023)||'
            ],
            [
              '||sum(Lon-0.023)||', '||sum(Lat+0.016)||'
            ],
            [
             '||sum(Lon-0.032)||', '||Lat||'
            ],
            [
              '||sum(Lon-0.023)||', '||sum(Lat-0.016)||'
            ],
            [
              '||Lon||', '||sum(Lat-0.023)||'
            ]
          ]
        ]
      }
    }
  ]
}' ELSE ''
    END as geojson
        FROM rucher WHERE id=$id and $aire=1; 

