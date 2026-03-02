// NOTE: The following script syntax is valid for database version 5.0 and above.
:param {
  file_path_root: 'file:///',
  file_0: 'User.Listening.History.filtrado.csv',
  file_1: 'Music.Info.filtrado.csv'
};

/*  ===========================================================================
    CONSTRAINTS
===========================================================================  */
CREATE CONSTRAINT usuario_id_uniq IF NOT EXISTS
FOR (u:Usuario)
REQUIRE u.user_id IS UNIQUE;

CREATE CONSTRAINT musica_id_uniq IF NOT EXISTS
FOR (t:Musica)
REQUIRE t.track_id IS UNIQUE;

CREATE CONSTRAINT artista_name_uniq IF NOT EXISTS
FOR (a:Artista)
REQUIRE a.name IS UNIQUE;

CREATE CONSTRAINT genero_name_uniq IF NOT EXISTS
FOR (g:Genero)
REQUIRE g.name IS UNIQUE;


/*
// NODE load
// ---------
//
// Load nodes in batches, one node label at a time. Nodes will be created using a
MERGE statement to ensure a node with the same label and ID property remains unique.
Pre-existing nodes found by a MERGE statement will have their other properties set
to the latest values encountered in a load file.
//
*/
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`track_id` IS NULL
CALL (row) {
  MERGE (n: `Musica` { `track_id`: row.`track_id` })
  SET n.`track_id` = row.`track_id`
  SET n.`name` = row.`name`
  SET n.`spotify_preview_url` = row.`spotify_preview_url`
  SET n.`spotify_id` = row.`spotify_id`
  SET n.`tags` = row.`tags`
  SET n.`genre` = row.`genre`
  SET n.`year` = toInteger(trim(row.`year`))
  SET n.`duration_ms` = toInteger(trim(row.`duration_ms`))
  SET n.`danceability` = toFloat(trim(row.`danceability`))
  SET n.`energy` = toFloat(trim(row.`energy`))
  SET n.`key` = toInteger(trim(row.`key`))
  SET n.`loudness` = toFloat(trim(row.`loudness`))
  SET n.`mode` = toLower(trim(row.`mode`)) IN ['1','true','yes']
  SET n.`speechiness` = toFloat(trim(row.`speechiness`))
  SET n.`acousticness` = row.`acousticness`
  SET n.`instrumentalness` = row.`instrumentalness`
  SET n.`liveness` = toFloat(trim(row.`liveness`))
  SET n.`valence` = toFloat(trim(row.`valence`))
  SET n.`tempo` = toFloat(trim(row.`tempo`))
  SET n.`time_signature` = toInteger(trim(row.`time_signature`))
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`user_id` IS NULL
CALL (row) {
  MERGE (n: `Usuario` { `user_id`: row.`user_id` })
  SET n.`user_id` = row.`user_id`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`artist` IS NULL
CALL (row) {
  MERGE (n: `Artista` { `artist`: row.`artist` })
  SET n.`artist` = row.`artist`
} IN TRANSACTIONS OF 10000 ROWS;

/*
// RELATIONSHIP load
// -----------------
//
Load relationships in batches, one relationship type at a time.
Relationships are created using a MERGE statement, meaning only one
relationship of a given type will ever be created between a pair of nodes.
*/
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row 
CALL (row) {
  MATCH (source: `Usuario` { `user_id`: row.`user_id` })
  MATCH (target: `Musica` { `track_id`: row.`track_id` })
  MERGE (source)-[r: `Escutou`]->(target)
  SET r.`playcount` = toInteger(trim(row.`playcount`))
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row 
CALL (row) {
  MATCH (source: `Musica` { `track_id`: row.`track_id` })
  MATCH (target: `Artista` { `artist`: row.`artist` })
  MERGE (source)-[r: `CompostaPor`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;
