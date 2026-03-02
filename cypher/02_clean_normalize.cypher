/*  ===========================================================================
    Limpeza e tipagem dos dados.
===========================================================================  */

// floats
MATCH (m:Musica)
SET
  m.acousticness      = toFloat(m.acousticness),
  m.danceability      = toFloat(m.danceability),
  m.energy            = toFloat(m.energy),
  m.instrumentalness  = toFloat(m.instrumentalness),
  m.liveness          = toFloat(m.liveness),
  m.speechiness       = toFloat(m.speechiness),
  m.valence           = toFloat(m.valence),
  m.tempo             = toFloat(m.tempo),
  m.loudness          = toFloat(m.loudness);

// integers
MATCH (m:Musica)
SET
  m.duration_ms    = toInteger(m.duration_ms),
  m.key            = toInteger(m.key),
  m.time_signature = toInteger(m.time_signature),
  m.year           = toInteger(m.year);

// booleans
MATCH (m:Musica)
SET m.mode =
  CASE
    WHEN m.mode IN [true, 'true', 'True', 1, '1'] THEN true
    ELSE false
  END;

// teste para ver se não tem dados inválidos no meio
MATCH (m:Musica)
RETURN
  count(m) AS total,
  count(m.acousticness) AS acousticness_ok,
  count(m.instrumentalness) AS instrumentalness_ok;


/*  ===========================================================================
    Normalização dos dados.
===========================================================================  */

// nó utilitário para guardar os valores mínimos e máximos para a normalização
MATCH (m:Musica)
WITH
  min(m.energy)        AS min_energy, max(m.energy)        AS max_energy,
  min(m.danceability)  AS min_dance,  max(m.danceability)  AS max_dance,
  min(m.valence)       AS min_valence,max(m.valence)       AS max_valence,
  min(m.tempo)         AS min_tempo,  max(m.tempo)         AS max_tempo,
  min(m.loudness)      AS min_loud,   max(m.loudness)      AS max_loud
MERGE (s:StatusMusica {scope: "global"})
SET
  s.min_energy  = min_energy,
  s.max_energy  = max_energy,
  s.min_dance   = min_dance,
  s.max_dance   = max_dance,
  s.min_valence = min_valence,
  s.max_valence = max_valence,
  s.min_tempo   = min_tempo,
  s.max_tempo   = max_tempo,
  s.min_loud    = min_loud,
  s.max_loud    = max_loud,
  s.updatedAt   = datetime();

// normalização das músicas
MATCH (s:StatusMusica {scope: "global"})
MATCH (m:Musica)
SET
  m.energy_norm        = (m.energy        - s.min_energy)  / (s.max_energy  - s.min_energy),
  m.danceability_norm  = (m.danceability  - s.min_dance)   / (s.max_dance   - s.min_dance),
  m.valence_norm       = (m.valence       - s.min_valence) / (s.max_valence - s.min_valence),
  m.tempo_norm         = (m.tempo         - s.min_tempo)   / (s.max_tempo   - s.min_tempo),
  m.loudness_norm      = (m.loudness      - s.min_loud)    / (s.max_loud    - s.min_loud);
