# -*- coding: utf-8 -*-
"""
Monitor local ultraligero para La Cripta Gamer.
Permite que la app (incluso corriendo en Edge/Web) detecte juegos en ejecución
en la PC y lea los juegos instalados de Steam sin requerir Visual Studio C++.
"""
import os
import re
import json
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 38291

STEAM_PATHS = [
    r'C:\Program Files (x86)\Steam\steamapps',
    r'C:\Program Files\Steam\steamapps',
    r'D:\SteamLibrary\steamapps',
    r'E:\SteamLibrary\steamapps',
]

KNOWN_GAMES = {
    'left4dead2': {'nombre': 'Left 4 Dead 2', 'tienda': 'Steam', 'genero': 'Shooter · Coop', 'appid': '550'},
    'cs2': {'nombre': 'Counter-Strike 2', 'tienda': 'Steam', 'genero': 'Shooter Táctico', 'appid': '730'},
    'dota2': {'nombre': 'Dota 2', 'tienda': 'Steam', 'genero': 'MOBA', 'appid': '570'},
    'cultofthelamb': {'nombre': 'Cult of the Lamb', 'tienda': 'Steam', 'genero': 'Roguelike · Acción', 'appid': '1313140'},
    'stardew valley': {'nombre': 'Stardew Valley', 'tienda': 'Steam', 'genero': 'Casual · Indie', 'appid': '413150'},
    'stardewvalley': {'nombre': 'Stardew Valley', 'tienda': 'Steam', 'genero': 'Casual · Indie', 'appid': '413150'},
    'graveyard keeper': {'nombre': 'Graveyard Keeper', 'tienda': 'Steam', 'genero': 'Simulación · Rol', 'appid': '599140'},
    'graveyardkeeper': {'nombre': 'Graveyard Keeper', 'tienda': 'Steam', 'genero': 'Simulación · Rol', 'appid': '599140'},
    'valheim': {'nombre': 'Valheim', 'tienda': 'Steam', 'genero': 'Supervivencia · Coop', 'appid': '892970'},
    'ac3rm': {'nombre': 'Assassin\'s Creed III Remastered', 'tienda': 'Steam', 'genero': 'Acción · Aventura', 'appid': '911400'},
    'repo': {'nombre': 'R.E.P.O.', 'tienda': 'Steam', 'genero': 'Indie · Acción', 'appid': '3241660'},
    'gta5': {'nombre': 'Grand Theft Auto V', 'tienda': 'Steam', 'genero': 'Acción · Mundo Abierto', 'appid': '271590'},
    'gtav': {'nombre': 'Grand Theft Auto V', 'tienda': 'Steam', 'genero': 'Acción · Mundo Abierto', 'appid': '271590'},
    'rdr2': {'nombre': 'Red Dead Redemption 2', 'tienda': 'Steam', 'genero': 'Acción · Aventura', 'appid': '1174180'},
    'eldenring': {'nombre': 'Elden Ring', 'tienda': 'Steam', 'genero': 'RPG · Acción', 'appid': '1245620'},
    'sekiro': {'nombre': 'Sekiro: Shadows Die Twice', 'tienda': 'Steam', 'genero': 'Acción · Aventura', 'appid': '814380'},
    'cyberpunk2077': {'nombre': 'Cyberpunk 2077', 'tienda': 'Steam', 'genero': 'RPG · Acción', 'appid': '1091500'},
    'witcher3': {'nombre': 'The Witcher 3: Wild Hunt', 'tienda': 'Steam', 'genero': 'RPG · Aventura', 'appid': '292030'},
    're4': {'nombre': 'Resident Evil 4 Remake', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '2050650'},
    're4remake': {'nombre': 'Resident Evil 4 Remake', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '2050650'},
    're8': {'nombre': 'Resident Evil Village', 'tienda': 'Steam', 'genero': 'Terror · Acción', 'appid': '1196590'},
    'bg3': {'nombre': 'Baldur\'s Gate 3', 'tienda': 'Steam', 'genero': 'RPG · Rol', 'appid': '1086940'},
    'godofwar': {'nombre': 'God of War', 'tienda': 'PS', 'genero': 'Acción · Aventura', 'appid': '1593500'},
    'gow': {'nombre': 'God of War', 'tienda': 'PS', 'genero': 'Acción · Aventura', 'appid': '1593500'},
    'spiderman': {'nombre': 'Marvel\'s Spider-Man', 'tienda': 'PS', 'genero': 'Acción · Mundo Abierto', 'appid': '1817070'},
    'forzahorizon5': {'nombre': 'Forza Horizon 5', 'tienda': 'Xbox', 'genero': 'Carreras', 'appid': '1551360'},
    'fc24': {'nombre': 'EA SPORTS FC 24', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '2195250'},
    'fc25': {'nombre': 'EA SPORTS FC 25', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '2669320'},
    'fifa23': {'nombre': 'FIFA 23', 'tienda': 'Steam', 'genero': 'Deportes · Fútbol', 'appid': '1811260'},
    'hollow_knight': {'nombre': 'Hollow Knight', 'tienda': 'Epic', 'genero': 'Metroidvania · 2D', 'appid': '367520'},
    'hollowknight': {'nombre': 'Hollow Knight', 'tienda': 'Epic', 'genero': 'Metroidvania · 2D', 'appid': '367520'},
    'celeste': {'nombre': 'Celeste', 'tienda': 'Steam', 'genero': 'Plataformas · Indie', 'appid': '504230'},
    'hades': {'nombre': 'Hades', 'tienda': 'Epic', 'genero': 'Acción · Indie', 'appid': '1145360'},
    'minecraft': {'nombre': 'Minecraft', 'tienda': 'Xbox', 'genero': 'Sandbox · Aventura'},
    'fortniteclient-win64-shipping': {'nombre': 'Fortnite', 'tienda': 'Epic', 'genero': 'Battle Royale'},
    'genshinimpact': {'nombre': 'Genshin Impact', 'tienda': 'Epic', 'genero': 'RPG · Aventura'},
}

def get_installed_steam_games():
    games = []
    seen = set()
    for sp in STEAM_PATHS:
        if not os.path.exists(sp):
            continue
        try:
            for f in os.listdir(sp):
                if f.startswith('appmanifest_') and f.endswith('.acf'):
                    with open(os.path.join(sp, f), 'r', encoding='utf-8', errors='ignore') as acf:
                        content = acf.read()
                        m_name = re.search(r'"name"\s+"([^"]+)"', content)
                        m_id = re.search(r'"appid"\s+"([^"]+)"', content)
                        if m_name and m_id:
                            appid = m_id.group(1)
                            name = m_name.group(1)
                            if appid != '228980' and 'steamworks' not in name.lower() and name not in seen:
                                seen.add(name)
                                games.append({
                                    'nombre': name,
                                    'genero': 'Steam Local',
                                    'tienda': 'Steam',
                                    'jugadores': '1 jugador',
                                    'estado': 'Jugando',
                                    'id': int(appid),
                                    'imageUrl': f'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{appid}/header.jpg'
                                })
        except Exception as e:
            pass
    return games

def get_running_game():
    try:
        cmd = ['powershell', '-NoProfile', '-Command', '(Get-Process).ProcessName']
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=3)
        if res.returncode == 0:
            lines = [l.strip().lower() for l in res.stdout.splitlines() if l.strip()]
            procs = set(lines)

            # 1. Comparar contra juegos instalados de Steam
            installed = get_installed_steam_games()
            for g in installed:
                clean_game = re.sub(r'[^a-z0-9]', '', g['nombre'].lower())
                for p in procs:
                    clean_p = re.sub(r'[^a-z0-9]', '', p)
                    if clean_p and (clean_p == clean_game or (len(clean_p) >= 5 and clean_p in clean_game)):
                        res_game = dict(g)
                        res_game['isLivePlaying'] = True
                        return res_game

            # 2. Comparar contra base conocida
            for k, val in KNOWN_GAMES.items():
                clean_k = k.lower().replace('.exe', '')
                if clean_k in procs:
                    appid = val.get('appid')
                    cover = f'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{appid}/header.jpg' if appid else None
                    return {
                        'nombre': val['nombre'],
                        'genero': val['genero'],
                        'tienda': val['tienda'],
                        'jugadores': '1 jugador',
                        'estado': 'Jugando',
                        'id': int(appid) if appid else None,
                        'imageUrl': cover,
                        'isLivePlaying': True
                    }

            # 3. Heurística Unreal Engine
            for p in procs:
                if p.endswith('-win64-shipping') or p.endswith('_shipping'):
                    clean_title = p.replace('-win64-shipping', '').replace('_shipping', '').replace('_', ' ').replace('-', ' ').title().strip()
                    if len(clean_title) > 2:
                        return {
                            'nombre': clean_title,
                            'genero': 'Juego de PC',
                            'tienda': 'PC',
                            'jugadores': '1 jugador',
                            'estado': 'Jugando',
                            'isLivePlaying': True
                        }
    except Exception as e:
        pass
    return None

class Handler(BaseHTTPRequestHandler):
    def _send_cors(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Content-Type', 'application/json; charset=utf-8')

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors()
        self.end_headers()

    def do_GET(self):
        self.send_response(200)
        self._send_cors()
        self.end_headers()

        if self.path == '/status':
            running = get_running_game()
            data = {'running': running}
            self.wfile.write(json.dumps(data).encode('utf-8'))
        elif self.path == '/installed':
            installed = get_installed_steam_games()
            self.wfile.write(json.dumps({'installed': installed}).encode('utf-8'))
        else:
            self.wfile.write(json.dumps({'ok': True}).encode('utf-8'))

    def log_message(self, format, *args):
        return # silencioso

if __name__ == '__main__':
    server = HTTPServer(('127.0.0.1', PORT), Handler)
    print(f'Monitor de juegos de La Cripta Gamer activo en http://127.0.0.1:{PORT}')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
