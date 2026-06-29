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
