echo "Importando dados..."
docker exec -i neo4j cypher-shell \
  -u neo4j -p neo4j123 \
  --param 'file_path_root => "file:///"' \
  --param 'file_0 => "User.Listening.History.filtrado.csv"' \
  --param 'file_1 => "Music.Info.filtrado.csv"' \
  < ./cypher/00_import_data.cypher
echo "Importação finalizada."

echo "Extraindo Generos..."
docker exec -i neo4j cypher-shell \
  -u neo4j -p neo4j123 \
  < ./cypher/01_genres_tags.cypher
echo "Generos extraidos."

echo "Limpeza e normalização dos dados..."
docker exec -i neo4j cypher-shell \
  -u neo4j -p neo4j123 \
  < ./cypher/02_clean_normalize.cypher
echo "Dados normalizados."

echo "Calculando similaridades..."
docker exec -i neo4j cypher-shell \
  -u neo4j -p neo4j123 \
  < ./cypher/03_calc_similarities.cypher
echo "Similaridades calculadas."

echo "Obter sugestões de músicas..."
docker exec -i neo4j cypher-shell \
  -u neo4j -p neo4j123 \
  < ./cypher/04_return_similar_songs.cypher
