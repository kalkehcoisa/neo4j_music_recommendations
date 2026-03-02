/*  ===========================================================================
    Geração dos nós Gênero a partir de Musica.genre e Musica.tags.
===========================================================================  */

MATCH (m:Musica)
WHERE m.genre IS NOT NULL AND trim(m.genre) <> ""
WITH m, toLower(trim(m.genre)) AS genero
MERGE (g:Genero {name: genero})
MERGE (m)-[:TEM_GENERO]->(g);

MATCH (m:Musica)
WHERE m.tags IS NOT NULL AND trim(m.tags) <> ""
WITH m, split(m.tags, ",") AS tags
UNWIND tags AS tag
WITH m, toLower(trim(tag)) AS genero
WHERE genero <> ""
MERGE (g:Genero {name: genero})
MERGE (m)-[:TEM_GENERO]->(g);

// elimina as propriedades tags e genre que não tem mais uso
MATCH (m:Musica)
REMOVE m.tags, m.genre;

//calcula o total de vezes que cada Musica foi reproduzida
MATCH (u:Usuario)-[e:Escutou]->(m:Musica)
WITH m, sum(e.playcount) AS total_plays
SET m.plays = total_plays
RETURN m.track_id, m.plays
ORDER BY m.plays DESC;
