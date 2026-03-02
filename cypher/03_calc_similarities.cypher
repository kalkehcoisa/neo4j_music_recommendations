/*  ===========================================================================
    Cálculo de similaridades (usando kNN).
===========================================================================  */

// CALL gds.graph.drop('musicasGraph');

//projeta o grafo em memória para usar o GDS
CALL gds.graph.project(
  'musicasGraph',
  {
    Musica: {
      properties: [
        'energy_norm',
        'danceability_norm',
        'valence_norm',
        'tempo_norm',
        'loudness_norm'
      ]
    }
  },
  '*'
);

//aplica kkn no grafo em memória e gera as relações Similar
CALL gds.nodeSimilarity.write(
  'musicasGraph',
  {
    nodeLabels: ['Musica'],
    similarityCutoff: 0.2,
    writeRelationshipType: 'SIMILAR',
    writeProperty: 'dist'
  }
)
YIELD nodesCompared, relationshipsWritten, computeMillis;

// elimina a projeção
CALL gds.graph.drop('musicasGraph');
