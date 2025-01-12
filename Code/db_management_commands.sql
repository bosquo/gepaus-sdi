CREATE TABLE gepaus_geometries (
    id SERIAL PRIMARY KEY, -- Auto-incrementing ID for each row
    name VARCHAR(255) NOT NULL, -- University name
    location GEOMETRY(Point, 4326) -- Point geometry column with SRID 4326 (WGS84)
);

/* The Leaflet package expects all point, line, and shape data to be specified 
in latitude and longitude using WGS 84 (a.k.a. EPSG:4326). By default, 
when displaying this data it projects everything to EPSG:3857 and expects that 
any map tiles are also displayed in EPSG:3857. */

-- INSERT INTO gepaus_geometries (name, geom)
-- VALUES 
--     ('University of Vienna', ST_GeomFromText('POINT(48.213232 16.359846)', 4326)), -- University of Vienna
--     ('University of Graz', ST_GeomFromText('POINT(47.07767177562355 15.449525144655508)', 4326)),
--     ('University of Innsbruck', ST_GeomFromText('POINT(47.26422744191816 11.3837576253876)', 4326)),  
--     ('University of Salzburg', ST_GeomFromText('POINT(47.79787246771694 13.048055525992314)', 4326)),
--     ('Vienna University of Technology', ST_GeomFromText('POINT(48.19925484804127 16.368505457140596 )', 4326)),
--     ('Graz University Of Technology', ST_GeomFromText('POINT(47.065298187905064 15.45294397270957)', 4326)),
--     ('University of Leoben', ST_GeomFromText('POINT(47.38602514058598 15.093224411553344)', 4326)),
--     ('University of Natural Resources and Life Sciences Vienna', ST_GeomFromText('POINT(48.23720177110948 16.337664772529042)', 4326)),
--     ('University of Veterinary Medicine Vienna', ST_GeomFromText('POINT(48.255704038602126 16.431499726514822)', 4326)),
--     ('Vienna University of Economics and Business', ST_GeomFromText('POINT(48.214098009502194 16.408549969316265)', 4326)),
--     ('Johannes Kepler University (JKU) Linz', ST_GeomFromText('POINT(48.21052414416441 16.38067808465919)', 4326)),
--     ('University of Klagenfurt', ST_GeomFromText('POINT(46.616239005764605 14.265380884659185)', 4326)),
--     ('Medical University of Vienna', ST_GeomFromText('POINT(48.2198091123559 16.347522171164798)', 4326));

INSERT INTO gepaus_geometries (name, geom)
VALUES 
    ('University of Vienna', ST_GeomFromText('POINT(16.359846 48.213232)', 4326)), -- University of Vienna
    ('University of Graz', ST_GeomFromText('POINT(15.449525144655508 47.07767177562355)', 4326)),
    ('University of Innsbruck', ST_GeomFromText('POINT(11.3837576253876 47.26422744191816)', 4326)),  
    ('University of Salzburg', ST_GeomFromText('POINT(13.048055525992314 47.79787246771694)', 4326)),
    ('Vienna University of Technology', ST_GeomFromText('POINT(16.368505457140596 48.19925484804127)', 4326)),
    ('Graz University Of Technology', ST_GeomFromText('POINT(15.45294397270957 47.065298187905064)', 4326)),
    ('University of Leoben', ST_GeomFromText('POINT(15.093224411553344 47.38602514058598)', 4326)),
    ('University of Natural Resources and Life Sciences Vienna', ST_GeomFromText('POINT(16.337664772529042 48.23720177110948)', 4326)),
    ('University of Veterinary Medicine Vienna', ST_GeomFromText('POINT(16.431499726514822 48.255704038602126)', 4326)),
    ('Vienna University of Economics and Business', ST_GeomFromText('POINT(16.408549969316265 48.214098009502194)', 4326)),
    ('Johannes Kepler University (JKU) Linz', ST_GeomFromText('POINT(14.312224 48.336302)', 4326)),
    ('University of Klagenfurt', ST_GeomFromText('POINT(14.265380884659185 46.616239005764605)', 4326)),
    ('Medical University of Vienna', ST_GeomFromText('POINT(16.347522171164798 48.2198091123559)', 4326));


-- rename columns with white spaces

ALTER TABLE gepaus RENAME COLUMN "field of study" TO field_of_study;
ALTER TABLE gepaus RENAME COLUMN "number of male students" TO male_students;
ALTER TABLE gepaus RENAME COLUMN "number of female students" TO female_students;
ALTER TABLE gepaus_geometries RENAME COLUMN name TO university;

/*-----------------------------------------------------------------------------------------------------------------------
GeoServer doesn't natively handle relational logic across multiple tables (e.g., automatically joining tables)
A view in PostgreSQL/PostGIS is the most common approach for relational data. 
Views allow you to predefine the logic (joins, filters, etc.) for combining multiple tables into a single, queryable "virtual table."
*/

CREATE VIEW gepaus_wfs AS
SELECT
    gs.geom,
    gs.university,
    g.male_students,
    g.female_students,
    g.semester,
    g.field_of_study
FROM
    gepaus_geometries gs
JOIN
    gepaus g
ON
    g.university = gs.university;


SELECT DISTINCT semester from gepaus; 

"winter semester 2013/14"
"winter semester 2003/04"
"winter semester 2023/24"

select * from gepaus where semester = "winter semester 2013/14"
-- ############################################################################################################################################################################
-- Create separate table (layer) for each semester, without redundancy of universities
CREATE TABLE sem_W_2013_2014_test AS
SELECT 
    university,
    -- Total male and female students across all fields of study
    SUM(male_students) :: INTEGER AS all_studies_m,
    SUM(female_students) :: INTEGER AS all_studies_f,
    -- Get male and female student counts for each field of study
    SUM(CASE WHEN field_of_study = '072 Manufacturing and processing' THEN male_students ELSE 0 END) :: INTEGER AS manufacturing_and_processing_m,
    SUM(CASE WHEN field_of_study = '072 Manufacturing and processing' THEN female_students ELSE 0 END) :: INTEGER AS manufacturing_and_processing_f,
    SUM(CASE WHEN field_of_study = '0613 Software and applications development and analysis' THEN male_students ELSE 0 END) :: INTEGER AS software_and_applications_development_m,
    SUM(CASE WHEN field_of_study = '0613 Software and applications development and analysis' THEN female_students ELSE 0 END) :: INTEGER AS software_and_applications_development_f,
    SUM(CASE WHEN field_of_study = '051 Biological and related sciences' THEN male_students ELSE 0 END) :: INTEGER AS biological_sciences_m,
    SUM(CASE WHEN field_of_study = '051 Biological and related sciences' THEN female_students ELSE 0 END) :: INTEGER AS biological_sciences_f,
    SUM(CASE WHEN field_of_study = '053 Physical sciences' THEN male_students ELSE 0 END) :: INTEGER AS physical_sciences_m,
    SUM(CASE WHEN field_of_study = '053 Physical sciences' THEN female_students ELSE 0 END) :: INTEGER AS physical_sciences_f,
    SUM(CASE WHEN field_of_study = '05 Natural sciences, mathematics and statistics' THEN male_students ELSE 0 END) :: INTEGER AS natural_methematics_statistics_m,
    SUM(CASE WHEN field_of_study = '05 Natural sciences, mathematics and statistics' THEN female_students ELSE 0 END) :: INTEGER AS natural_methematics_statistics_f,
    SUM(CASE WHEN field_of_study = '073 Architecture and construction' THEN male_students ELSE 0 END) :: INTEGER AS architecture_m,
    SUM(CASE WHEN field_of_study = '073 Architecture and construction' THEN female_students ELSE 0 END) :: INTEGER AS architecture_f,
    SUM(CASE WHEN field_of_study = '052 Environment' THEN male_students ELSE 0 END) :: INTEGER AS environment_m,
    SUM(CASE WHEN field_of_study = '052 Environment' THEN female_students ELSE 0 END) :: INTEGER AS environment_f
    
FROM 
    gepaus
WHERE
    semester = 'winter semester 2013/14'  -- Add your desired semester here
GROUP BY 
    university;

-- ############################################################################################################################################################################
CREATE INDEX sp_index ON gepaus_geometries USING GIST (geom);

-- ############################################################################################################################################################################

CREATE VIEW sem_w_2013_2014_wfs AS
SELECT 
    w13.*,
    gg.geom
FROM 
    sem_w_2013_2014_test w13
JOIN 
    gepaus_geometries gg
ON
    w13.university = gg.university

-- ############################################################################################################################################################################



// Define the WFS URL
const wfsUrl = 'https://geoserver22s.zgis.at/geoserver/IPSDI_WT24/wfs';

// Set the WFS request parameters
const wfsParams = {
    service: 'WFS',
    version: '1.1.0',
    request: 'GetFeature',
    typeName: 'IPSDI_WT24:sem_w_2013_2014_wfs',
    outputFormat: 'application/json', // Request GeoJSON format
};

// Make the WFS request and handle the response
fetch(`${wfsUrl}?${new URLSearchParams(wfsParams).toString()}`)
    .then(response => response.json())
    .then(data => {
        // Convert the WFS response (GeoJSON) into a Leaflet layer
        const wfsLayer = L.geoJSON(data);
        
        // Add the layer to the map
        wfsLayer.addTo(map);
    })
    .catch(error => console.error('Error fetching WFS data:', error));