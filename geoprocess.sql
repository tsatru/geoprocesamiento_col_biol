--Elimina la tabla de la cosecha anterior
Drop table if exists ccud_data_work.biodiversity_work_coord;
--Importa la nueva tabla. Hay que modificar cada vez el nombre de la tabla con la fecha de inicio de proceso
BEGIN;
------
SELECT *
INTO ccud_data_work.biodiversity_work_coord
FROM dblink('dbname=collections_work hostaddr=0.0.0.0 user=user password=passwor',
            'select id_biodiversity_work, specimen_id, occurrenceid, 
            verbatimlatitude, verbatimlongitude, decimallatitude, decimallongitude, country_o, stateprovince_o, county_o,
            country, stateprovince, county, locality, verbatimlocality, verbatimelevation, minimumelevationinmeters,
            created, created_user, lastmodified, lastmodified_user from biodiversity.biodiversity_work where decimallatitude is not null')
       as t1(
  id_biodiversity_work bigint,
  specimen_id bigint,
  occurrenceid text,
  verbatimlatitude text,
  verbatimlongitude text,
  decimallatitude double precision,
  decimallongitude double precision,
  country_o text,
  stateprovince_o text,
  county_o text,
  country text,
  stateprovince text,
  county text,
  locality text,
  verbatimlocality text,
  verbatimelevation text,
  minimumelevationinmeters numeric,
  created timestamp(6) without time zone,
  created_user text,
  lastmodified timestamp(6) without time zone,
  lastmodified_user text
  );
COMMIT;

ALTER TABLE ccud_data_work.biodiversity_work_coord ADD COLUMN coords text;
ALTER TABLE ccud_data_work.biodiversity_work_coord ADD COLUMN geom geometry;
ALTER TABLE ccud_data_work.biodiversity_work_coord ADD COLUMN buffer_geom geometry;


UPDATE ccud_data_work.biodiversity_work_coord SET "coords" = decimallatitude||'|'||decimallongitude;

UPDATE ccud_data_work.biodiversity_work_coord SET "geom" = ST_SetSRID(ST_MakePoint(decimallongitude, decimallatitude),4326);

UPDATE ccud_data_work.biodiversity_work_coord SET "buffer_geom" = ST_Buffer (geom, 0.02); 



/*
  �ste dblink se ejecuta desde el servidor de Tanis
*/

--Elimina la cosecha anterior.
Drop table if exists biodiversity_geo.geo_new;
--Importa la nueva tabla. Hay que modificar cada vez el nombre de la tabla con la fecha de inicio de proceso
BEGIN;
------
SELECT *
INTO biodiversity_geo.geo_new
FROM dblink('dbname=alphatole hostaddr=0.0.0.0 user=user password=password',
            'select * from ccud_data_work.biodiversity_work_coord')
       as t1(
  id_biodiversity_work bigint,
  specimen_id bigint,
  occurrenceid text,
  verbatimlatitude text,
  verbatimlongitude text,
  decimallatitude double precision,
  decimallongitude double precision,
  country_o text,
  stateprovince_o text,
  county_o text,
  country text,
  stateprovince text,
  county text,
  locality text,
  verbatimlocality text,
  verbatimelevation text,
  minimumelevationinmeters numeric,
  created timestamp(6) without time zone,
  created_user text,
  lastmodified timestamp(6) without time zone,
  lastmodified_user text,
  coords text,
  geom geometry,
  buffer_geom geometry
  );
COMMIT;



BEGIN;
DROP TABLE IF EXISTS biodiversity_geo.new_cosecha;
CREATE TABLE biodiversity_geo.new_cosecha as
SELECT
biodiversity_geo.geo_new.id_biodiversity_work,
biodiversity_geo.geo_new.specimen_id,
biodiversity_geo.geo_new.occurrenceid,
biodiversity_geo.geo_new.verbatimlatitude,
biodiversity_geo.geo_new.verbatimlongitude,
biodiversity_geo.geo_new.decimallatitude,
biodiversity_geo.geo_new.decimallongitude,
biodiversity_geo.geo_new.country_o,
biodiversity_geo.geo_new.stateprovince_o,
biodiversity_geo.geo_new.county_o,
biodiversity_geo.geo_new.country,
biodiversity_geo.geo_new.stateprovince,
biodiversity_geo.geo_new.county,
biodiversity_geo.geo_new.locality,
biodiversity_geo.geo_new.verbatimlocality,
biodiversity_geo.geo_new.verbatimelevation,
biodiversity_geo.geo_new.minimumelevationinmeters,
biodiversity_geo.geo_new.created,
biodiversity_geo.geo_new.created_user,
biodiversity_geo.geo_new.lastmodified,
biodiversity_geo.geo_new.lastmodified_user,
biodiversity_geo.geo_new.coords,
biodiversity_geo.geo_new.geom,
biodiversity_geo.geo_new.buffer_geom
FROM
biodiversity_geo.geo_new
LEFT OUTER JOIN biodiversity_geo.distintos_qi_coord ON biodiversity_geo.distintos_qi_coord.id_biodiversity_work = biodiversity_geo.geo_new.id_biodiversity_work
WHERE biodiversity_geo.distintos_qi_coord.id_biodiversity_work IS NULL
order by biodiversity_geo.geo_new.id_biodiversity_work asc; 
COMMIT;


alter table biodiversity_geo.new_cosecha add primary key (id_biodiversity_work);

alter table biodiversity_geo.new_cosecha add column "marca_origen" varchar(50);

update biodiversity_geo.new_cosecha set "marca_origen" = 'nuevos ejemplares';



insert into biodiversity_geo.new_cosecha 
(
  id_biodiversity_work,
  specimen_id,
  occurrenceid,
  verbatimlatitude,
  verbatimlongitude,
  decimallatitude,
  decimallongitude,
  country_o,
  stateprovince_o,
  county_o,
  country,
  stateprovince,
  county,
  locality,
  verbatimlocality,
  verbatimelevation,
  minimumelevationinmeters,
  created,
  created_user,
  lastmodified,
  lastmodified_user,
  coords,
  geom,
  buffer_geom
)
SELECT
biodiversity_geo.geo_new.id_biodiversity_work,
biodiversity_geo.geo_new.specimen_id,
biodiversity_geo.geo_new.occurrenceid,
biodiversity_geo.geo_new.verbatimlatitude,
biodiversity_geo.geo_new.verbatimlongitude,
biodiversity_geo.geo_new.decimallatitude,
biodiversity_geo.geo_new.decimallongitude,
biodiversity_geo.geo_new.country_o,
biodiversity_geo.geo_new.stateprovince_o,
biodiversity_geo.geo_new.county_o,
biodiversity_geo.geo_new.country,
biodiversity_geo.geo_new.stateprovince,
biodiversity_geo.geo_new.county,
biodiversity_geo.geo_new.locality,
biodiversity_geo.geo_new.verbatimlocality,
biodiversity_geo.geo_new.verbatimelevation,
biodiversity_geo.geo_new.minimumelevationinmeters,
biodiversity_geo.geo_new.created,
biodiversity_geo.geo_new.created_user,
biodiversity_geo.geo_new.lastmodified,
biodiversity_geo.geo_new.lastmodified_user,
biodiversity_geo.geo_new.coords,
biodiversity_geo.geo_new.geom,
biodiversity_geo.geo_new.buffer_geom
FROM
biodiversity_geo.geo_new
INNER JOIN biodiversity_geo.distintos_qi_coord ON biodiversity_geo.distintos_qi_coord.id_biodiversity_work = biodiversity_geo.geo_new.id_biodiversity_work
WHERE biodiversity_geo.distintos_qi_coord.coords <> biodiversity_geo.geo_new.coords 
order by biodiversity_geo.geo_new.id_biodiversity_work asc; 



CREATE TABLE biodiversity_geo.join_faltantes as   
SELECT DISTINCT ON(biodiversity_geo.new_cosecha.id_biodiversity_work)
biodiversity_geo.new_cosecha.id_biodiversity_work,
biodiversity_geo.new_cosecha.specimen_id,
biodiversity_geo.new_cosecha.occurrenceid,
biodiversity_geo.new_cosecha.decimallatitude,
biodiversity_geo.new_cosecha.decimallongitude,
biodiversity_geo.new_cosecha.coords,
biodiversity_geo.new_cosecha.country_o,
biodiversity_geo.new_cosecha.stateprovince_o,
biodiversity_geo.new_cosecha.county_o,
biodiversity_geo.new_cosecha.country,
biodiversity_geo.new_cosecha.stateprovince,
biodiversity_geo.new_cosecha.county,
biodiversity_geo.distintos_qi_coord.country_o_qi,
biodiversity_geo.distintos_qi_coord.stateprovince_o_qi,
biodiversity_geo.distintos_qi_coord.county_o_qi,
biodiversity_geo.distintos_qi_coord.country_qi,
biodiversity_geo.distintos_qi_coord.stateprovince_qi,
biodiversity_geo.distintos_qi_coord.county_qi,
biodiversity_geo.distintos_qi_coord.country_intersects as country_point,
biodiversity_geo.distintos_qi_coord.stateprovince_intersects as stateprovince_point,
biodiversity_geo.distintos_qi_coord.county_intersects as county_point,
biodiversity_geo.distintos_qi_coord.country_buffer as pais_intersects,
biodiversity_geo.distintos_qi_coord.stateprovince_buffer as prov_intersects,
biodiversity_geo.distintos_qi_coord.county_buffer as mun_intersects,
biodiversity_geo.distintos_qi_coord.country_nn as country_c,
biodiversity_geo.distintos_qi_coord.stateprovince_nn as stateprovince_c,
biodiversity_geo.distintos_qi_coord.county_nn as county_c
FROM
biodiversity_geo.distintos_qi_coord
INNER JOIN biodiversity_geo.new_cosecha ON biodiversity_geo.distintos_qi_coord.coords = biodiversity_geo.new_cosecha.coords;




alter table biodiversity_geo.join_faltantes add column country_catalogo text; 
alter table biodiversity_geo.join_faltantes add column stateprovince_catalogo text; 
alter table biodiversity_geo.join_faltantes add column county_catalogo text; 
alter table biodiversity_geo.join_faltantes add column intersects_gadm boolean; 
alter table biodiversity_geo.join_faltantes add column intersects_inegi boolean; 
alter table biodiversity_geo.join_faltantes add column buffer_intersects_gadm boolean; 
alter table biodiversity_geo.join_faltantes add column buffer_intersects_inegi boolean;
alter table biodiversity_geo.join_faltantes add column country_to_update text; 


update biodiversity_geo.join_faltantes 
set country_o_qi = NULL, stateprovince_o_qi = NULL, county_o_qi = NULL,
country_qi = NULL, stateprovince_qi = NULL, county_qi = NULL; 


update biodiversity_geo.join_faltantes 
set country_o = NULL
where country_o = '@'; 

update biodiversity_geo.join_faltantes 
set stateprovince_o = NULL
where stateprovince_o = '@'; 

update biodiversity_geo.join_faltantes 
set county_o = NULL
where county_o = '@'; 




UPDATE biodiversity_geo.join_faltantes SET
country_catalogo = array_catalogo.country_catalogo
, stateprovince_catalogo = array_catalogo.stateprovince_catalogo
, county_catalogo = array_catalogo.county_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.join_faltantes.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.join_faltantes.stateprovince = biodiversity_geo.array_catalogo.stateprovince_catalogo
AND biodiversity_geo.join_faltantes.county = ANY(biodiversity_geo.array_catalogo.county);


UPDATE biodiversity_geo.join_faltantes SET
country_catalogo = array_catalogo.country_catalogo
, stateprovince_catalogo = array_catalogo.stateprovince_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.join_faltantes.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.join_faltantes.stateprovince = biodiversity_geo.array_catalogo.stateprovince_catalogo
AND biodiversity_geo.join_faltantes.county is null
AND biodiversity_geo.join_faltantes.country_catalogo is null
AND biodiversity_geo.join_faltantes.stateprovince_catalogo is null; 



UPDATE biodiversity_geo.join_faltantes SET
country_catalogo = array_catalogo.country_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.join_faltantes.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.join_faltantes.country_catalogo is null
AND biodiversity_geo.join_faltantes.stateprovince_catalogo is null
AND biodiversity_geo.join_faltantes.county_catalogo is null;


UPDATE biodiversity_geo.join_faltantes SET
stateprovince_catalogo = array_catalogo.stateprovince_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.join_faltantes.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.join_faltantes.stateprovince = biodiversity_geo.array_catalogo.stateprovince_catalogo
AND biodiversity_geo.join_faltantes.county is not null
AND biodiversity_geo.join_faltantes.country_catalogo is not null
AND biodiversity_geo.join_faltantes.stateprovince_catalogo is null; 



UPDATE biodiversity_geo.join_faltantes as u
SET intersects_gadm = f.intersects_gadm
, intersects_inegi = f.intersects_inegi
, buffer_intersects_gadm = f.buffer_intersects_gadm
, buffer_intersects_inegi = f.buffer_intersects_inegi
FROM biodiversity_geo._unique_coords_17abril2018 as f
WHERE u.coords = f.coords and u.intersects_gadm is null;


CREATE TRIGGER qi_geowork
  BEFORE UPDATE
  ON biodiversity_geo.join_faltantes
  FOR EACH ROW
  WHEN ((old.country_to_update IS DISTINCT FROM new.country_to_update))
  EXECUTE PROCEDURE biodiversity_geo.f_geowork_qi();



 UPDATE biodiversity_geo.join_faltantes SET country_to_update = 'update'
 WHERE country_to_update IS NULL; 



CREATE TABLE biodiversity_geo.faltantes_12abril2018 as   
SELECT DISTINCT ON (biodiversity_geo.new_cosecha12042018.id_biodiversity_work)
biodiversity_geo.new_cosecha12042018.id_biodiversity_work,
biodiversity_geo.new_cosecha12042018.specimen_id,
biodiversity_geo.new_cosecha12042018.occurrenceid,
biodiversity_geo.new_cosecha12042018.decimallatitude,
biodiversity_geo.new_cosecha12042018.decimallongitude,
biodiversity_geo.new_cosecha12042018.country_o,
biodiversity_geo.new_cosecha12042018.stateprovince_o,
biodiversity_geo.new_cosecha12042018.county_o,
biodiversity_geo.new_cosecha12042018.country,
biodiversity_geo.new_cosecha12042018.stateprovince,
biodiversity_geo.new_cosecha12042018.county,
biodiversity_geo.new_cosecha12042018.coords
FROM
biodiversity_geo.new_cosecha12042018
LEFT OUTER JOIN biodiversity_geo.distintos_qi_coord ON biodiversity_geo.new_cosecha12042018.coords = biodiversity_geo.distintos_qi_coord.coords
WHERE biodiversity_geo.distintos_qi_coord.id_biodiversity_work IS NULL; 


update biodiversity_geo.faltantes_12abril2018 
set country_o = NULL
where country_o = '@'; 

update biodiversity_geo.faltantes_12abril2018 
set stateprovince_o = NULL
where stateprovince_o = '@'; 

update biodiversity_geo.faltantes_12abril2018 
set county_o = NULL
where county_o = '@'; 


alter table biodiversity_geo.faltantes_12abril2018 add column country_o_qi numeric; 
alter table biodiversity_geo.faltantes_12abril2018 add column stateprovince_o_qi numeric; 
alter table biodiversity_geo.faltantes_12abril2018 add column county_o_qi numeric; 
alter table biodiversity_geo.faltantes_12abril2018 add column country_qi numeric; 
alter table biodiversity_geo.faltantes_12abril2018 add column stateprovince_qi numeric; 
alter table biodiversity_geo.faltantes_12abril2018 add column county_qi numeric; 
alter table biodiversity_geo.faltantes_12abril2018 add column country_point text; 
alter table biodiversity_geo.faltantes_12abril2018 add column stateprovince_point text; 
alter table biodiversity_geo.faltantes_12abril2018 add column county_point text; 
alter table biodiversity_geo.faltantes_12abril2018 add column pais_intersects text[]; 
alter table biodiversity_geo.faltantes_12abril2018 add column prov_intersects text[]; 
alter table biodiversity_geo.faltantes_12abril2018 add column mun_intersects text[]; 
alter table biodiversity_geo.faltantes_12abril2018 add column country_c text; 
alter table biodiversity_geo.faltantes_12abril2018 add column stateprovince_c text; 
alter table biodiversity_geo.faltantes_12abril2018 add column county_c text; 
alter table biodiversity_geo.faltantes_12abril2018 add column country_catalogo text; 
alter table biodiversity_geo.faltantes_12abril2018 add column stateprovince_catalogo text; 
alter table biodiversity_geo.faltantes_12abril2018 add column county_catalogo text; 
alter table biodiversity_geo.faltantes_12abril2018 add column country_to_update text; 
alter table biodiversity_geo.faltantes_12abril2018 add column intersects_gadm boolean;
alter table biodiversity_geo.faltantes_12abril2018 add column intersects_inegi boolean;
alter table biodiversity_geo.faltantes_12abril2018 add column buffer_intersects_gadm boolean;
alter table biodiversity_geo.faltantes_12abril2018 add column buffer_intersects_inegi boolean;




CREATE TABLE biodiversity_geo.unique_faltantes_12abril2018 as
SELECT DISTINCT
  faltantes_12abril2018.coords, 
  array_agg(faltantes_12abril2018.id_biodiversity_work) as array_id_bw,
  array_agg(faltantes_12abril2018.specimen_id) as array_specimen_id, 
  array_agg(faltantes_12abril2018.occurrenceid) as array_occurrenceid, 
  faltantes_12abril2018.decimallatitude as lat, 
  faltantes_12abril2018.decimallongitude as long, 
  faltantes_12abril2018.country_o, 
  faltantes_12abril2018.stateprovince_o, 
  faltantes_12abril2018.county_o, 
  faltantes_12abril2018.country, 
  faltantes_12abril2018.stateprovince, 
  faltantes_12abril2018.county
FROM 
  biodiversity_geo.faltantes_12abril2018
GROUP BY
  faltantes_12abril2018.coords,
  faltantes_12abril2018.decimallatitude, 
  faltantes_12abril2018.decimallongitude, 
  faltantes_12abril2018.country_o, 
  faltantes_12abril2018.stateprovince_o, 
  faltantes_12abril2018.county_o, 
  faltantes_12abril2018.country, 
  faltantes_12abril2018.stateprovince, 
  faltantes_12abril2018.county; 





alter table biodiversity_geo.unique_faltantes_12abril2018 add column "geom" geometry; 
alter table biodiversity_geo.unique_faltantes_12abril2018 add column "buffer_geom" geometry; 
alter table biodiversity_geo.unique_faltantes_12abril2018 add column "intersects_gadm" boolean; 
alter table biodiversity_geo.unique_faltantes_12abril2018 add column "intersects_inegi" boolean; 
alter table biodiversity_geo.unique_faltantes_12abril2018 add column "buffer_intersects_gadm" boolean; 
alter table biodiversity_geo.unique_faltantes_12abril2018 add column "buffer_intersects_inegi" boolean; 
alter table biodiversity_geo.unique_faltantes_12abril2018 add column "marca" text; 
alter table biodiversity_geo.unique_faltantes_12abril2018 add column "id_unique" SERIAL PRIMARY KEY; 



UPDATE biodiversity_geo.unique_faltantes_12abril2018 SET "geom" = ST_SetSRID(ST_MakePoint(long, lat),4326);

UPDATE biodiversity_geo.unique_faltantes_12abril2018 SET "buffer_geom" = ST_Buffer (geom, 0.02); 



-- DROP INDEX biodiversity_geo.idx_geom_f;
CREATE INDEX idx_geom_f
  ON biodiversity_geo.unique_faltantes_12abril2018
  USING gist
  (geom);

-- DROP INDEX biodiversity_geo.idx_buffer_geom_f;
CREATE INDEX idx_buffer_geom_f
  ON biodiversity_geo.unique_faltantes_12abril2018
  USING gist
  (buffer_geom);

update biodiversity_geo.unique_faltantes_12abril2018 set marca = 'get_function'






   



DROP FUNCTION biodiversity_geo.get_intersects_gadm_false(text, integer, integer);

CREATE OR REPLACE FUNCTION biodiversity_geo.get_intersects_gadm_false(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, intersects_gadm boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON(d.id_unique) 
				d.id_unique, 
				ST_Intersects(d.geom, c.geom) as intersects_gadm
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, geographic.gadm28_adm0 as c
				--ON d.geom && c.geom
				WHERE ST_Intersects(d.geom, c.geom) = 'false'
				AND d.marca = get_intersects_gadm_false.marca
        		AND d.id_unique BETWEEN get_intersects_gadm_false.id1 AND get_intersects_gadm_false.id2)
 
     LOOP
        id_unique := var_r.id_unique;     
        intersects_gadm := var_r.intersects_gadm; 
       
      
              RETURN NEXT;
            END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION biodiversity_geo.get_intersects_gadm_false(text, integer, integer)
  OWNER TO tania;


DROP TABLE IF EXISTS biodiversity_geo.get_intersects_gadm_false;

CREATE TABLE biodiversity_geo.get_intersects_gadm_false AS
SELECT * FROM biodiversity_geo.get_intersects_gadm_false('get_function', 1, 251);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET intersects_gadm = get_intersects_gadm_false.intersects_gadm
FROM biodiversity_geo.get_intersects_gadm_false
WHERE get_intersects_gadm_false.id_unique = unique_faltantes_12abril2018.id_unique;











CREATE OR REPLACE FUNCTION biodiversity_geo.get_buffer_gadm_false(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, buffer_intersects_gadm boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON(d.id_unique) 
				  d.id_unique
				, ST_Intersects(d.buffer_geom, c.geom) as buffer_intersects_gadm
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, geographic.gadm28_adm0 as c
				--ON d.buffer_geom && c.geom
				WHERE ST_Intersects(d.buffer_geom, c.geom) = 'false'
				AND d.marca = get_buffer_gadm_false.marca
        AND d.id_unique BETWEEN get_buffer_gadm_false.id1 AND get_buffer_gadm_false.id2
--				AND d.buffer_intersects_gadm IS NULL
				GROUP BY d.id_unique, d.buffer_geom, c.geom)		
 
     LOOP
        id_unique := var_r.id_unique;     
        buffer_intersects_gadm := var_r.buffer_intersects_gadm; 
      
              RETURN NEXT;
            END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;





CREATE TABLE biodiversity_geo.get_buffer_gadm_false AS
SELECT * FROM biodiversity_geo.get_buffer_gadm_false('get_function', 1, 251);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET buffer_intersects_gadm = get_buffer_gadm_false.buffer_intersects_gadm
FROM biodiversity_geo.get_buffer_gadm_false
WHERE get_buffer_gadm_false.id_unique = unique_faltantes_12abril2018.id_unique;


DROP TABLE IF EXISTS biodiversity_geo.get_buffer_gadm_false;














CREATE OR REPLACE FUNCTION biodiversity_geo.get_intersects_inegi_false(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, intersects_inegi boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON(d.id_unique) 
				d.id_unique,
				ST_Intersects(d.geom, c.geom) as intersects_inegi
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, catalogos_inegi.agm_2016 as c
				--ON d.geom && c.geom
				WHERE ST_Intersects(d.geom, c.geom) = 'false'
				AND d.marca = get_intersects_inegi_false.marca
        		AND d.id_unique BETWEEN get_intersects_inegi_false.id1 AND get_intersects_inegi_false.id2)
 
     LOOP
        id_unique := var_r.id_unique;     
        intersects_inegi := var_r.intersects_inegi; 
   
       
      
              RETURN NEXT;
            END LOOP;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION biodiversity_geo.get_intersects_inegi_false(text, integer, integer)
  OWNER TO tania;



CREATE TABLE biodiversity_geo.get_intersects_inegi_false AS
SELECT * FROM biodiversity_geo.get_intersects_inegi_false('get_function', 1, 187);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET intersects_inegi = get_intersects_inegi_false.intersects_inegi
FROM biodiversity_geo.get_intersects_inegi_false
WHERE get_intersects_inegi_false.id_unique = unique_faltantes_12abril2018.id_unique;


DROP TABLE IF EXISTS biodiversity_geo.get_intersects_inegi_false;















CREATE OR REPLACE FUNCTION biodiversity_geo.get_buffer_inegi_false(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, buffer_intersects_inegi boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON (d."id_unique")
				d.id_unique
				, ST_Intersects(d.buffer_geom, c.geom) as buffer_intersects_inegi
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, catalogos_inegi.agm_2016 as c
				--ON d.buffer_geom && c.geom
				WHERE ST_Intersects(d.buffer_geom, c.geom) = 'false'
				AND d.marca = get_buffer_inegi_false.marca
				AND d.id_unique BETWEEN get_buffer_inegi_false.id1 AND get_buffer_inegi_false.id2
				GROUP BY d.id_unique, d.buffer_geom, c.geom)
 
     LOOP
     	id_unique := var_r.id_unique;    
        buffer_intersects_inegi := var_r.buffer_intersects_inegi;     
        
       
      
               RETURN NEXT;
            END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION biodiversity_geo.get_buffer_inegi_false(text, integer, integer)
  OWNER TO tania;



CREATE TABLE biodiversity_geo.get_buffer_inegi_false AS
SELECT * FROM biodiversity_geo.get_buffer_inegi_false('get_function', 1, 251);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET buffer_intersects_inegi = get_buffer_inegi_false.buffer_intersects_inegi
FROM biodiversity_geo.get_buffer_inegi_false
WHERE get_buffer_inegi_false.id_unique = unique_faltantes_12abril2018.id_unique;


DROP TABLE IF EXISTS biodiversity_geo.get_buffer_inegi_false;








CREATE OR REPLACE FUNCTION biodiversity_geo.get_intersects_inegi(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, intersects_inegi boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON(d.id_unique) 
				d.id_unique,
				ST_Intersects(d.geom, c.geom) as intersects_inegi
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, catalogos_inegi.agm_2016 as c
				--ON d.geom && c.geom
				WHERE ST_Intersects(d.geom, c.geom) = 'true'
				AND d.marca = get_intersects_inegi.marca
        		AND d.id_unique BETWEEN get_intersects_inegi.id1 AND get_intersects_inegi.id2)
 
     LOOP
        id_unique := var_r.id_unique;     
        intersects_inegi := var_r.intersects_inegi; 
      
       
      
               RETURN NEXT;
            END LOOP;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION biodiversity_geo.get_intersects_inegi(text, integer, integer)
  OWNER TO tania;


CREATE TABLE biodiversity_geo.get_intersects_inegi AS
SELECT * FROM biodiversity_geo.get_intersects_inegi('get_function', 1, 251);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET intersects_inegi = get_intersects_inegi.intersects_inegi
FROM biodiversity_geo.get_intersects_inegi
WHERE get_intersects_inegi.id_unique = unique_faltantes_12abril2018.id_unique;

DROP TABLE IF EXISTS biodiversity_geo.get_intersects_inegi;





CREATE OR REPLACE FUNCTION biodiversity_geo.get_buffer_inegi(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, buffer_intersects_inegi boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON (d."id_unique")
				d.id_unique
				, ST_Intersects(d.buffer_geom, c.geom) as buffer_intersects_inegi
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, catalogos_inegi.agm_2016 as c
				--ON d.buffer_geom && c.geom
				WHERE ST_Intersects(d.buffer_geom, c.geom) = 'true'
				AND d.marca = get_buffer_inegi.marca
				AND d.id_unique BETWEEN get_buffer_inegi.id1 AND get_buffer_inegi.id2
				GROUP BY d.id_unique, d.buffer_geom, c.geom)
 
     LOOP
     	id_unique := var_r.id_unique;     
        buffer_intersects_inegi := var_r.buffer_intersects_inegi;     
        
       
      
              RETURN NEXT;
            END LOOP;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION biodiversity_geo.get_buffer_inegi(text, integer, integer)
  OWNER TO tania;


CREATE TABLE biodiversity_geo.get_buffer_inegi AS
SELECT * FROM biodiversity_geo.get_buffer_inegi('get_function', 1, 251);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET buffer_intersects_inegi = get_buffer_inegi.buffer_intersects_inegi
FROM biodiversity_geo.get_buffer_inegi
WHERE get_buffer_inegi.id_unique = unique_faltantes_12abril2018.id_unique;


DROP TABLE IF EXISTS biodiversity_geo.get_buffer_inegi;





CREATE OR REPLACE FUNCTION biodiversity_geo.get_intersects_gadm(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, intersects_gadm boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON(d.id_unique) 
				d.id_unique, 
				ST_Intersects(d.geom, c.geom) as intersects_gadm
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, geographic.gadm28_adm0 as c
				--ON d.geom && c.geom
				WHERE ST_Intersects(d.geom, c.geom) = 'true'
				AND d.marca = get_intersects_gadm.marca
        		AND d.id_unique BETWEEN get_intersects_gadm.id1 AND get_intersects_gadm.id2)
 
     LOOP
        id_unique := var_r.id_unique;     
        intersects_gadm := var_r.intersects_gadm; 
       
      
              RETURN NEXT;
            END LOOP;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION biodiversity_geo.get_intersects_gadm(text, integer, integer)
  OWNER TO tania;



CREATE TABLE biodiversity_geo.get_intersects_gadm AS
SELECT * FROM biodiversity_geo.get_intersects_gadm('get_function', 1, 251);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET intersects_gadm = get_intersects_gadm.intersects_gadm
FROM biodiversity_geo.get_intersects_gadm
WHERE get_intersects_gadm.id_unique = unique_faltantes_12abril2018.id_unique;


DROP TABLE IF EXISTS biodiversity_geo.get_intersects_gadm; 



CREATE OR REPLACE FUNCTION biodiversity_geo.get_buffer_gadm(
    IN marca text,
    IN id1 integer,
    IN id2 integer)
  RETURNS TABLE(id_unique integer, buffer_intersects_gadm boolean) AS
$BODY$	
DECLARE 
    var_r record;
BEGIN
   FOR var_r IN(
   				SELECT DISTINCT ON(d.id_unique) 
				  d.id_unique
				, ST_Intersects(d.buffer_geom, c.geom) as buffer_intersects_gadm
				FROM biodiversity_geo.unique_faltantes_12abril2018 as d
				, geographic.gadm28_adm0 as c
				--ON d.buffer_geom && c.geom
				WHERE ST_Intersects(d.buffer_geom, c.geom) = 'true'
				AND d.marca = get_buffer_gadm.marca
        AND d.id_unique BETWEEN get_buffer_gadm.id1 AND get_buffer_gadm.id2
--				AND d.buffer_intersects_gadm IS NULL
				GROUP BY d.id_unique, d.buffer_geom, c.geom)		
 
     LOOP
        id_unique := var_r.id_unique;     
        buffer_intersects_gadm := var_r.buffer_intersects_gadm; 
       
      
              RETURN NEXT;
            END LOOP;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION biodiversity_geo.get_buffer_gadm(text, integer, integer)
  OWNER TO tania;



DROP TABLE IF EXISTS biodiversity_geo.get_buffer_gadm;

CREATE TABLE biodiversity_geo.get_buffer_gadm AS
SELECT * FROM biodiversity_geo.get_buffer_gadm('get_function', 1, 251);


UPDATE biodiversity_geo.unique_faltantes_12abril2018
SET buffer_intersects_gadm = get_buffer_gadm.buffer_intersects_gadm
FROM biodiversity_geo.get_buffer_gadm
WHERE get_buffer_gadm.id_unique = unique_faltantes_12abril2018.id_unique;










  DROP TABLE IF EXISTS biodiversity_geo.buffer_false_intersects;
CREATE TABLE biodiversity_geo.buffer_false_intersects
( 
  "id_unique" int PRIMARY KEY,
  "coords" text,
  "array_id_bw" text[],
  "array_specimen_id" text[],
  "array_occurrenceid" text[],
  "geom" "geometry",
  "buffer_geom" "geometry",
  "intersects_gadm" boolean,
  "intersects_inegi" boolean,
  "buffer_intersects_gadm" boolean,
  "buffer_intersects_inegi" boolean,
  "country_c" text,
  "stateprovince_c" text,
  "county_c" text,
  "geo_tuple" text,
  "dist" float8,
  "geo_tuple_inegi" text,
  "dist_km" float8,
  "marca" text
  );
	
	
	
	
	

INSERT INTO biodiversity_geo.buffer_false_intersects
(id_unique, coords, array_id_bw, array_specimen_id, array_occurrenceid, geom, buffer_geom, intersects_gadm, intersects_inegi, buffer_intersects_gadm, buffer_intersects_inegi, marca)
SELECT DISTINCT
id_unique, coords, array_id_bw, array_specimen_id, array_occurrenceid, geom, buffer_geom, intersects_gadm, intersects_inegi, buffer_intersects_gadm, buffer_intersects_inegi, 'get_function'
FROM biodiversity_geo.unique_faltantes_12abril2018 as f 
WHERE f.buffer_intersects_gadm = 'false' AND f.buffer_intersects_inegi = 'false' AND f.buffer_intersects_gadm = 'false' AND f.buffer_intersects_inegi = 'false'
ORDER BY f.id_unique;





CREATE INDEX idx_geom_false
  ON biodiversity_geo.buffer_false_intersects
  USING gist
  (geom);


CREATE INDEX idx_buffer_false
  ON biodiversity_geo.buffer_false_intersects
  USING gist
  (buffer_geom);




DROP TABLE IF EXISTS biodiversity_geo.get_nn;
CREATE TABLE biodiversity_geo.get_nn AS
SELECT * FROM biodiversity_geo.get_nn(1, 340, 'get_function');



UPDATE biodiversity_geo.buffer_false_intersects SET geo_tuple = get_nn.geo_tuple, dist = get_nn.dist
FROM biodiversity_geo.get_nn
WHERE biodiversity_geo.buffer_false_intersects.id_unique = get_nn.id_unique;




DROP TABLE IF EXISTS biodiversity_geo.get_nn_inegi;
CREATE TABLE biodiversity_geo.get_nn_inegi AS
SELECT * FROM biodiversity_geo.get_nn_inegi(1, 340, 'get_function');



UPDATE biodiversity_geo.buffer_false_intersects SET geo_tuple_inegi = get_nn_inegi.geo_tuple, dist_km = get_nn_inegi.dist
FROM biodiversity_geo.get_nn_inegi
WHERE biodiversity_geo.buffer_false_intersects.id_unique = get_nn_inegi.id_unique;



UPDATE biodiversity_geo.buffer_false_intersects SET country_c = split_part(geo_tuple, '|', 1); 


UPDATE biodiversity_geo.buffer_false_intersects SET 
stateprovince_c =  split_part(geo_tuple_inegi, '|', 2), county_c = split_part(geo_tuple_inegi, '|', 3)
WHERE country_c = 'M�xico';



UPDATE biodiversity_geo.buffer_false_intersects SET
stateprovince_c =  split_part(geo_tuple, '|', 2), county_c = split_part(geo_tuple, '|', 3)
WHERE stateprovince_c IS NULL AND county_c IS NULL; 






DROP TABLE IF EXISTS biodiversity_geo.buffer_true_intersects; 
CREATE TABLE biodiversity_geo.buffer_true_intersects
( 
  "id_unique" int PRIMARY KEY,
  "coords" text,
  "lat" float8,
  "long" float8,
  "array_id_bw" text[],
  "array_specimen_id" text[],
  "array_occurrenceid" text[],
  "geom" "public"."geometry",
  "buffer_geom" "geometry",
  "intersects_gadm" boolean,
  "intersects_inegi" boolean,
  "buffer_intersects_gadm" boolean,
  "buffer_intersects_inegi" boolean,
  "country_point" text,
  "stateprovince_point" text,
  "county_point" text,
  "pais_intersects" text[],
  "prov_intersects" text[],
  "mun_intersects" text[],
  "marca" text);



INSERT INTO biodiversity_geo.buffer_true_intersects
(id_unique, coords, lat, long, array_id_bw, array_specimen_id, array_occurrenceid, geom, buffer_geom, intersects_gadm, intersects_inegi, buffer_intersects_gadm, buffer_intersects_inegi, marca)
SELECT DISTINCT
id_unique, coords, lat, long, array_id_bw, array_specimen_id, array_occurrenceid, geom, buffer_geom, intersects_gadm, intersects_inegi, buffer_intersects_gadm, buffer_intersects_inegi, 'get_function'
FROM biodiversity_geo.unique_faltantes_12abril2018 as t
WHERE t.intersects_gadm = 'true'
OR t.intersects_gadm = 'true'
OR t.buffer_intersects_gadm = 'true'
OR t.buffer_intersects_inegi = 'true'
ORDER BY t.id_unique; 





CREATE INDEX idx_geom_true
  ON biodiversity_geo.buffer_true_intersects
  USING gist
  (geom);


CREATE INDEX idx_buffer_true
  ON biodiversity_geo.buffer_true_intersects
  USING gist
  (buffer_geom);






DROP TABLE IF EXISTS biodiversity_geo.point_gadm0;

CREATE TABLE biodiversity_geo.point_gadm0 AS 
SELECT DISTINCT ON(d."id_unique") d.id_unique, c.name_spani
FROM biodiversity_geo.buffer_true_intersects AS d
,geographic.gadm28_adm0  AS c
WHERE ST_Intersects(d.geom, c.geom) = 'true'
ORDER BY d.id_unique;



UPDATE biodiversity_geo.buffer_true_intersects 
SET country_point = point_gadm0.name_spani
FROM biodiversity_geo.point_gadm0
WHERE point_gadm0.id_unique = biodiversity_geo.buffer_true_intersects.id_unique
AND country_point IS NULL;



DROP TABLE IF EXISTS biodiversity_geo.point_inegi; 

CREATE TABLE biodiversity_geo.point_inegi AS 
SELECT DISTINCT ON(d."id_unique") d.id_unique, c.pais, c.nom_ent, c.nom_mun
FROM biodiversity_geo.buffer_true_intersects AS d
,catalogos_inegi.agm_2016  AS c
WHERE ST_Intersects(d.geom, c.geom) = 'true'
ORDER BY d.id_unique;



UPDATE biodiversity_geo.buffer_true_intersects 
SET stateprovince_point = point_inegi.nom_ent, county_point = point_inegi.nom_mun
FROM biodiversity_geo.point_inegi
WHERE biodiversity_geo.point_inegi.id_unique = biodiversity_geo.buffer_true_intersects.id_unique
AND country_point IS NOT NULL 
AND stateprovince_point IS NULL 
AND county_point IS NULL;





DROP TABLE IF EXISTS biodiversity_geo.point_gadm2;

CREATE TABLE biodiversity_geo.point_gadm2 AS 
SELECT DISTINCT ON(d."id_unique") d.id_unique, c.name_1, c.name_2
FROM biodiversity_geo.buffer_true_intersects AS d
,geographic.gadm28_adm2  AS c
WHERE ST_Intersects(d.geom, c.geom) = 'true'
ORDER BY d.id_unique;



UPDATE biodiversity_geo.buffer_true_intersects 
SET stateprovince_point = point_gadm2.name_1, county_point = point_gadm2.name_2
FROM biodiversity_geo.point_gadm2
WHERE point_gadm2.id_unique = biodiversity_geo.buffer_true_intersects.id_unique
AND country_point IS NOT NULL 
AND stateprovince_point IS NULL 
AND county_point IS NULL; 




--gadm1

DROP TABLE IF EXISTS biodiversity_geo.point_gadm1;

CREATE TABLE biodiversity_geo.point_gadm1 AS 
SELECT DISTINCT ON(d."id_unique") d.id_unique, c.name_1
FROM biodiversity_geo.buffer_true_intersects AS d
,geographic.gadm28_adm1  AS c
WHERE ST_Intersects(d.geom, c.geom) = 'true'
ORDER BY d.id_unique;


UPDATE biodiversity_geo.buffer_true_intersects 
SET stateprovince_point = point_gadm1.name_1
FROM biodiversity_geo.point_gadm1
WHERE point_gadm1.id_unique = biodiversity_geo.buffer_true_intersects.id_unique
AND country_point IS NOT NULL 
AND stateprovince_point IS NULL
AND county_point IS NULL;




--gadm0
DROP TABLE IF EXISTS biodiversity_geo.intersects_gadm0;

CREATE TABLE biodiversity_geo.intersects_gadm0 AS
SELECT DISTINCT ON (d."id_unique")
d.id_unique
, array_agg(distinct c.name_spani) as pais_intersects
FROM biodiversity_geo.buffer_true_intersects as d
, geographic.gadm28_adm0 as c
WHERE  ST_Intersects(d.buffer_geom, c.geom) = 'true'
GROUP BY d.id_unique;


UPDATE biodiversity_geo.buffer_true_intersects 
SET pais_intersects = intersects_gadm0.pais_intersects
FROM biodiversity_geo.intersects_gadm0
WHERE biodiversity_geo.intersects_gadm0.id_unique = biodiversity_geo.buffer_true_intersects.id_unique
AND buffer_true_intersects.pais_intersects IS NULL;




--intersects_inegi

DROP TABLE IF EXISTS biodiversity_geo.intersects_inegi;

CREATE TABLE biodiversity_geo.intersects_inegi AS
SELECT DISTINCT ON (d."id_unique")
d.id_unique
, array_agg(distinct c.pais) as pais_intersects
, array_agg(distinct c.nom_ent) as prov_intersects
, array_agg(distinct c.nom_mun) as mun_intersects
FROM biodiversity_geo.buffer_true_intersects as d
, catalogos_inegi.agm_2016 as c
WHERE  ST_Intersects(d.buffer_geom, c.geom) = 'true'
GROUP BY d.id_unique;



UPDATE biodiversity_geo.buffer_true_intersects 
SET  prov_intersects = intersects_inegi.prov_intersects, mun_intersects = intersects_inegi.mun_intersects
FROM biodiversity_geo.intersects_inegi
WHERE biodiversity_geo.intersects_inegi.id_unique = biodiversity_geo.buffer_true_intersects.id_unique;






--gadm2 

DROP TABLE IF EXISTS biodiversity_geo.intersects_gadm2;

CREATE TABLE biodiversity_geo.intersects_gadm2 AS
SELECT DISTINCT ON (d."id_unique")
d.id_unique
, array_agg(distinct c.name_spani) as pais_intersects
, array_agg(distinct c.name_1) as prov_intersects
, array_agg(distinct c.name_2) as mun_intersects
FROM biodiversity_geo.buffer_true_intersects as d
, geographic.gadm28_adm2 as c
WHERE  ST_Intersects(d.buffer_geom, c.geom) = 'true'
GROUP BY d.id_unique;


UPDATE biodiversity_geo.buffer_true_intersects 
SET prov_intersects = intersects_gadm2.prov_intersects, mun_intersects = intersects_gadm2.mun_intersects
FROM biodiversity_geo.intersects_gadm2
WHERE biodiversity_geo.intersects_gadm2.id_unique = biodiversity_geo.buffer_true_intersects.id_unique
AND buffer_true_intersects.pais_intersects IS NOT NULL
AND buffer_true_intersects.prov_intersects IS NULL
AND buffer_true_intersects.mun_intersects IS NULL;




--gadm1

DROP TABLE IF EXISTS biodiversity_geo.intersects_gadm1;

CREATE TABLE biodiversity_geo.intersects_gadm1 AS
SELECT DISTINCT ON (d."id_unique")
d.id_unique
, array_agg(distinct c.name_1) as prov_intersects
FROM biodiversity_geo.buffer_true_intersects as d
, geographic.gadm28_adm1 as c
WHERE  ST_Intersects(d.buffer_geom, c.geom) = 'true'
GROUP BY d.id_unique;


UPDATE biodiversity_geo.buffer_true_intersects 
SET prov_intersects = intersects_gadm1.prov_intersects
FROM biodiversity_geo.intersects_gadm1
WHERE biodiversity_geo.intersects_gadm1.id_unique = biodiversity_geo.buffer_true_intersects.id_unique
AND buffer_true_intersects.pais_intersects IS NOT NULL
AND buffer_true_intersects.prov_intersects IS NULL
AND buffer_true_intersects.mun_intersects IS NULL;











--cat�logo

UPDATE biodiversity_geo.faltantes_12abril2018 SET
country_catalogo = array_catalogo.country_catalogo
, stateprovince_catalogo = array_catalogo.stateprovince_catalogo
, county_catalogo = array_catalogo.county_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.faltantes_12abril2018.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.faltantes_12abril2018.stateprovince = biodiversity_geo.array_catalogo.stateprovince_catalogo
AND biodiversity_geo.faltantes_12abril2018.county = ANY(biodiversity_geo.array_catalogo.county);


UPDATE biodiversity_geo.faltantes_12abril2018 SET
country_catalogo = array_catalogo.country_catalogo
, stateprovince_catalogo = array_catalogo.stateprovince_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.faltantes_12abril2018.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.faltantes_12abril2018.stateprovince = biodiversity_geo.array_catalogo.stateprovince_catalogo
AND biodiversity_geo.faltantes_12abril2018.county is null
AND biodiversity_geo.faltantes_12abril2018.country_catalogo is null
AND biodiversity_geo.faltantes_12abril2018.stateprovince_catalogo is null; 



UPDATE biodiversity_geo.faltantes_12abril2018 SET
country_catalogo = array_catalogo.country_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.faltantes_12abril2018.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.faltantes_12abril2018.country_catalogo is null
AND biodiversity_geo.faltantes_12abril2018.stateprovince_catalogo is null
AND biodiversity_geo.faltantes_12abril2018.county_catalogo is null;


UPDATE biodiversity_geo.faltantes_12abril2018 SET
stateprovince_catalogo = array_catalogo.stateprovince_catalogo
FROM biodiversity_geo.array_catalogo
WHERE biodiversity_geo.faltantes_12abril2018.country = biodiversity_geo.array_catalogo.country_catalogo
AND biodiversity_geo.faltantes_12abril2018.stateprovince = biodiversity_geo.array_catalogo.stateprovince_catalogo
AND biodiversity_geo.faltantes_12abril2018.county is not null
AND biodiversity_geo.faltantes_12abril2018.country_catalogo is not null
AND biodiversity_geo.faltantes_12abril2018.stateprovince_catalogo is null; 




drop table if exists biodiversity_geo.unnest_true_intersects;
create table biodiversity_geo.unnest_true_intersects as
select distinct
  unnest(array_id_bw) as id_biodiversity_work,
  unnest(array_specimen_id) as specimen_id,
  unnest(array_occurrenceid) as occurrenceid,
  coords,
  intersects_gadm,
  intersects_inegi,
  buffer_intersects_gadm,
  buffer_intersects_inegi,
  country_point,
  stateprovince_point,
  county_point,
  pais_intersects,
  prov_intersects,
  mun_intersects
 from biodiversity_geo.buffer_true_intersects; 



UPDATE biodiversity_geo.faltantes_18abril2018 as u
SET intersects_gadm = d.intersects_gadm
, intersects_inegi = d.intersects_inegi
, buffer_intersects_gadm = d.buffer_intersects_gadm
, buffer_intersects_inegi = d.buffer_intersects_inegi
, country_point = d.country_point
, stateprovince_point = d.stateprovince_point
, county_point = d.county_point
, pais_intersects = d.pais_intersects
, prov_intersects = d.prov_intersects
, mun_intersects = d.mun_intersects
FROM biodiversity_geo.unnest_true_intersects as d
WHERE u.id_biodiversity_work = d.id_biodiversity_work::INT;




drop table if exists biodiversity_geo.unnest_false_intersects;  
create table biodiversity_geo.unnest_false_intersects as
select distinct
  unnest(array_id_bw) as id_biodiversity_work,
  unnest(array_specimen_id) as specimen_id,
  unnest(array_occurrenceid) as occurrenceid,
  coords,
  intersects_gadm,
  intersects_inegi,
  buffer_intersects_gadm,
  buffer_intersects_inegi,
  country_c,
  stateprovince_c,
  county_c
 from biodiversity_geo.buffer_false_intersects; 



UPDATE biodiversity_geo.faltantes_18abril2018 as u
SET intersects_gadm = f.intersects_gadm
, intersects_inegi = f.intersects_inegi
, buffer_intersects_gadm = f.buffer_intersects_gadm
, buffer_intersects_inegi = f.buffer_intersects_inegi
, country_c = f.country_c
, stateprovince_c = f.stateprovince_c
, county_c = f.county_c
FROM unnest_false_intersects as f
WHERE u.id_biodiversity_work = f.id_biodiversity_work::INT;



CREATE TRIGGER qi_geowork
  BEFORE UPDATE
  ON biodiversity_geo.faltantes_12abril2018
  FOR EACH ROW
  WHEN ((old.country_to_update IS DISTINCT FROM new.country_to_update))
  EXECUTE PROCEDURE biodiversity_geo.f_geowork_qi();



 UPDATE biodiversity_geo.faltantes_12abril2018 SET country_to_update = 'update'
 WHERE country_to_update IS NULL; 






INSERT INTO biodiversity_geo.distintos_qi_coord 
(
id_biodiversity_work,
  specimen_id,
  occurrenceid,
  decimallatitude,
  decimallongitude,
  coords,
  country_o,
  stateprovince_o,
  county_o,
  country,
  stateprovince,
  county,
  country_o_qi,
  stateprovince_o_qi,
  county_o_qi,
  country_qi,
  stateprovince_qi,
  county_qi,
  country_intersects,
  stateprovince_intersects,
  county_intersects,
  country_buffer,
  stateprovince_buffer,
  county_buffer,
  country_nn,
  stateprovince_nn,
  county_nn
)
SELECT 
  id_biodiversity_work,
  specimen_id,
  occurrenceid,
  decimallatitude,
  decimallongitude,
  coords,
  country_o,
  stateprovince_o,
  county_o,
  country,
  stateprovince,
  county,
  country_o_qi,
  stateprovince_o_qi,
  county_o_qi,
  country_qi,
  stateprovince_qi,
  county_qi,
  country_point,
  stateprovince_point,
  county_point,
  pais_intersects,
  prov_intersects,
  mun_intersects,
  country_c,
  stateprovince_c,
  county_c
  FROM biodiversity_geo.join_faltantes_12abril2018;







INSERT INTO biodiversity_geo.distintos_qi_coord 
(
id_biodiversity_work,
  specimen_id,
  occurrenceid,
  decimallatitude,
  decimallongitude,
  coords,
  country_o,
  stateprovince_o,
  county_o,
  country,
  stateprovince,
  county,
  country_o_qi,
  stateprovince_o_qi,
  county_o_qi,
  country_qi,
  stateprovince_qi,
  county_qi,
  country_intersects,
  stateprovince_intersects,
  county_intersects,
  country_buffer,
  stateprovince_buffer,
  county_buffer,
  country_nn,
  stateprovince_nn,
  county_nn
)
SELECT 
  id_biodiversity_work,
  specimen_id,
  occurrenceid,
  decimallatitude,
  decimallongitude,
  coords,
  country_o,
  stateprovince_o,
  county_o,
  country,
  stateprovince,
  county,
  country_o_qi,
  stateprovince_o_qi,
  county_o_qi,
  country_qi,
  stateprovince_qi,
  county_qi,
  country_point,
  stateprovince_point,
  county_point,
  pais_intersects,
  prov_intersects,
  mun_intersects,
  country_c,
  stateprovince_c,
  county_c
  FROM biodiversity_geo.faltantes_12abril2018;






update biodiversity_geo.join_faltantes_16abril2018
  set country_point = biodiversity_geo._unique_coords.country_intersects
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;

update biodiversity_geo.join_faltantes_16abril2018
  set stateprovince_point = biodiversity_geo._unique_coords.stateprovince_intersects
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;

update biodiversity_geo.join_faltantes_16abril2018
  set county_point = biodiversity_geo._unique_coords.county_intersects
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;




update biodiversity_geo.join_faltantes_16abril2018
  set pais_intersects = biodiversity_geo._unique_coords.country_buffer
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;

update biodiversity_geo.join_faltantes_16abril2018
  set prov_intersects = biodiversity_geo._unique_coords.stateprovince_buffer
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;

update biodiversity_geo.join_faltantes_16abril2018
  set mun_intersects = biodiversity_geo._unique_coords.county_buffer
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;






update biodiversity_geo.join_faltantes_16abril2018
  set country_c = biodiversity_geo._unique_coords.country_nn
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;

update biodiversity_geo.join_faltantes_16abril2018
  set stateprovince_c = biodiversity_geo._unique_coords.stateprovince_nn
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;

update biodiversity_geo.join_faltantes_16abril2018
  set county_c = biodiversity_geo._unique_coords.county_nn
  from biodiversity_geo._unique_coords
  where ST_Intersects(biodiversity_geo."_unique_coords".geom, biodiversity_geo.join_faltantes_16abril2018.geom) = TRUE;

