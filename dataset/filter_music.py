#!/usr/bin/env python3
import csv

# Arquivos de entrada
history_in = 'User.Listening.History.csv'
music_in   = 'Music.Info.csv'

# Arquivos de saída
history_out = 'User.Listening.History.filtrado.csv'
music_out   = 'Music.Info.filtrado.csv'


PLAYCOUNT_MIN = 15

track_ids = set()  # para usar no passo 2

print(f'Mantendo todos os itens de {history_in} com playcount > {PLAYCOUNT_MIN}')
with open(history_in, newline='', encoding='utf-8') as f_in, \
     open(history_out, 'w', newline='', encoding='utf-8') as f_out:

    reader = csv.reader(f_in)
    writer = csv.writer(f_out)

    header = next(reader)
    writer.writerow(header)

    avg_playcount  = 0
    track_user_count = 0
    for row in reader:
        try:
            playcount = int(row[2])
            avg_playcount += playcount
            if playcount > PLAYCOUNT_MIN:
                track_user_count += 1
                writer.writerow(row)
                track_ids.add(row[0])
        except (ValueError, IndexError):
            continue  # ignora linhas inválidas

avg_playcount /= track_user_count
print(f"{history_out} gerado com {track_user_count} linhas com playcount > {PLAYCOUNT_MIN}. AVG: {avg_playcount}")


print(f'Removendo todos os itens de {music_in} cuja track_id não está em {history_out}.')
with open(music_in, newline='', encoding='utf-8') as f_in, \
     open(music_out, 'w', newline='', encoding='utf-8') as f_out:
    
    reader = csv.reader(f_in)
    writer = csv.writer(f_out)
    
    header = next(reader)
    writer.writerow(header)
    
    filtered_count = 0
    for row in reader:
        if row[0] in track_ids:
            writer.writerow(row)
            filtered_count += 1
print(f"{music_out} gerado com {filtered_count} tracks presentes no histórico filtrado.")
