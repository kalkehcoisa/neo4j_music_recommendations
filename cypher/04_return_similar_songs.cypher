/*  ===========================================================================
    Verificação dos dados auxiliares gerados.
===========================================================================  */
MATCH ()-[r:SIMILAR]->()
RETURN count(r);
// retornou 145359


// min, max e média das distâncias
MATCH ()-[r:SIMILAR]->()
RETURN min(r.dist), max(r.dist), avg(r.dist);
// 0.0005369597413131058, 0.1999994568652953, 0.11494575929448535


// Distribuição de grau (o quão conectadas as músicas estão entre si)
MATCH (a:Musica)
RETURN
  avg(COUNT { (a)-[:SIMILAR]->() }) AS media,
  max(COUNT { (a)-[:SIMILAR]->() }) AS max;
// 9.393757270259858, 2396


// Exportar top 20 similares com informações legíveis
CALL apoc.export.csv.query("
MATCH (m:Musica)
WITH m
ORDER BY m.plays DESC
CALL(m) {
    WITH m
    MATCH (m)-[r:SIMILAR]->(rec:Musica)
    WHERE r.dist <= 0.5
    RETURN rec, r
    ORDER BY r.dist ASC
    LIMIT 20
}
OPTIONAL MATCH (m)-[:CompostaPor]->(m_artist:Artista)
OPTIONAL MATCH (rec)-[:CompostaPor]->(rec_artist:Artista)
RETURN 
  coalesce(m.name,'') AS musica_nome,
  coalesce(m_artist.artist,'') AS artista_nome,
  coalesce(rec.name,'') AS similar_nome,
  coalesce(rec_artist.artist,'') AS similar_artista,
  r.dist AS dist
",
"musicas_similares.csv",
{writeHeader:true, delimiter:','})
YIELD file
RETURN file;
