-- ============================================================
-- Query 1: Filter
-- Select all neighborhoods in Manhattan as a sanity check
-- that the data loaded correctly.
-- ============================================================
SELECT ntaname, boroname
FROM nyc_neighborhoods
WHERE boroname = 'Manhattan';

-- ============================================================
-- Query 2: Spatial Join
-- Match each hydrant to the neighborhood that contains it
-- using ST_Contains. Returns one row per matched hydrant.
-- 109,694 of 109,725 hydrants match a neighborhood polygon;
-- 31 fall on boundaries or in water areas.
-- ============================================================
SELECT n.ntaname, h.gid
FROM nyc_neighborhoods n
JOIN nyc_hydrants h ON ST_Contains(n.wkb_geometry, h.wkb_geometry)
LIMIT 10;

-- ============================================================
-- Query 3: Aggregate
-- Count hydrants per neighborhood using GROUP BY.
-- Results ordered by count descending. Raw counts favor large
-- outer-borough neighborhoods; area normalization follows in Q4.
-- ============================================================
SELECT n.ntaname, COUNT(*) AS hydrant_count
FROM nyc_neighborhoods n
JOIN nyc_hydrants h ON ST_Contains(n.wkb_geometry, h.wkb_geometry)
GROUP BY n.ntaname
ORDER BY hydrant_count DESC;

-- ============================================================
-- Query 4: Normalize by Area (Headline Result)
-- Divide hydrant count by neighborhood area in km² to get
-- density per km². Uses EPSG:2263 (NY State Plane, feet);
-- divisor 10763910.0 converts sq ft to km².
-- GROUP BY includes wkb_geometry to satisfy aggregate rules.
-- Top results are dense Manhattan neighborhoods, inverting
-- the raw-count ranking from Query 3.
-- ============================================================
SELECT n.ntaname,
       COUNT(*) AS hydrant_count,
       ST_Area(ST_Transform(n.wkb_geometry, 2263)) / 10763910.0 AS area_km2,
       COUNT(*) / (ST_Area(ST_Transform(n.wkb_geometry, 2263)) / 10763910.0) AS density_per_km2
FROM nyc_neighborhoods n
JOIN nyc_hydrants h ON ST_Contains(n.wkb_geometry, h.wkb_geometry)
GROUP BY n.ntaname, n.wkb_geometry
ORDER BY density_per_km2 DESC;
