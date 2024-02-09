-- Description: This SQL script is used to process data from the "viewingactivity" table and separate the title into individual columns for season and episode.

-- Step 1: Get an overview of the "viewingactivity" table.
SELECT * FROM viewingactivity;

-- Step 2: Get an overview of relevant columns that will be used in the processing.
SELECT user_profile, title FROM viewingactivity;

-- Step 3: Add the 'season' column to the 'viewingactivity' table to store season information.
ALTER TABLE viewingactivity 
ADD COLUMN season VARCHAR(255) DEFAULT NULL;

-- Step 4: Add the 'episode' column to the 'viewingactivity' table to store episode information.
ALTER TABLE viewingactivity 
ADD COLUMN episode VARCHAR(255) DEFAULT NULL;

-- Step 5: Add the 'title_' column to the 'viewingactivity' table to store the processed title column.
ALTER TABLE viewingactivity 
ADD COLUMN title_ VARCHAR(255) DEFAULT NULL;

-- Step 6: Get an overview of relevant columns after adding the new ones.
SELECT title, title_, season, episode FROM viewingactivity;

-- Step 7: Process the 'title' column to extract relevant information.
UPDATE viewingactivity
SET title_ = 
    CASE 
		    -- Extracting the processed title_ based on various patterns
        WHEN title LIKE '%: Season%' THEN SUBSTRING_INDEX(title, ': Season', 1)
        WHEN title LIKE '%: Temporada%' THEN SUBSTRING_INDEX(title, ': Temporada', 1)
        WHEN title LIKE '%: Part%' THEN SUBSTRING_INDEX(title, ': Part', 1)
        WHEN title LIKE '% (Episode%' THEN SUBSTRING_INDEX(title, ' (Episode', 1)
        WHEN title LIKE '% Episode%' THEN SUBSTRING_INDEX(title, ' Episode', 1)
        WHEN title LIKE '% (Episodio%' THEN SUBSTRING_INDEX(title, ' (Episodio', 1)
        WHEN title LIKE 'Season %' THEN 
            SUBSTRING(title, LOCATE('Season ', title) + LENGTH('Season '), LENGTH(title))
        ELSE title 
    END,
		-- Extracting the episode information
    episode = 
    CASE 
        WHEN title LIKE '% (Episode %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, ' (Episode ', -1), ')', 1)
        WHEN title LIKE '%Episode %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, 'Episode ', -1), ')', 1)
        WHEN title LIKE '% (Episodio %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, ' (Episodio ', -1), ')', 1)
        ELSE NULL 
    END,
	  -- Extracting the season information
    season = 
    CASE 
        WHEN title LIKE '%: Season %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, ': Season ', -1), ':', 1)
        WHEN title LIKE '%: Temporada %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, ': Temporada ', -1), ':', 1)
        WHEN title LIKE 'Season %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, 'Season ', -1), ' ', 1)
        WHEN title LIKE 'Season % %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, 'Season ', -1), ' ', 1)
        WHEN title LIKE '%: Part %' THEN 
            SUBSTRING_INDEX(SUBSTRING_INDEX(title, ': Part ', -1), ':', 1)
        ELSE NULL 
    END;

-- Step 8: Process the 'title_' column to remove occurrences of "Limited Series".
UPDATE viewingactivity
SET title_ = REPLACE(title_, ' Limited Series', '')
WHERE title_ LIKE '% Limited Series%';

-- Step 9: Remove rows with incomplete data for season or episode
DELETE FROM viewingactivity
WHERE (season IS NULL AND episode IS NOT NULL)
   OR (season IS NOT NULL AND episode IS NULL);

-- Step 10: Remove the 'title' column
ALTER TABLE viewingactivity
DROP COLUMN title;

-- Step 11: Rename the 'title_' column to 'title'
ALTER TABLE viewingactivity
CHANGE COLUMN title_ title VARCHAR(255);

-- Step 12: Remove rows corresponding to trailers or hooks.
DELETE FROM viewingactivity
WHERE video_type IN ('HOOK', 'TRAILER');

-- Step 13: Add the 'format' column to the 'viewingactivity' table.
ALTER TABLE viewingactivity ADD COLUMN format VARCHAR(255) DEFAULT NULL;

-- Step 14: Update the 'format' column based on 'season' and 'episode' values.
UPDATE viewingactivity
SET format = 
    CASE
        WHEN season IS NULL AND episode IS NULL THEN 'film'
        WHEN season IS NOT NULL AND episode IS NOT NULL THEN 'series'
        ELSE NULL
    END;

-- Step 15: Visualize the final result
SELECT * FROM viewingactivity;

SELECT user_profile, duration, title, season, episode FROM viewingactivity;

SHOW COLUMNS FROM viewingactivity;

