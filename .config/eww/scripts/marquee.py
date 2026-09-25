#!/usr/bin/env python3
import time, subprocess, sys, unicodedata, json

WIDTH = 30

def get_player_data():
    try:
        all_players = subprocess.check_output(["playerctl", "-l"], stderr=subprocess.DEVNULL).decode("utf-8").strip().split('\n')
        all_players = [p for p in all_players if p]

        if not all_players:
            return "Stopped", "", ""

        playing_players = []
        for p in all_players:
            try:
                st = subprocess.check_output(["playerctl", "-p", p, "status"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
                if st == "Playing":
                    playing_players.append(p)
            except:
                continue

        active_player = None
        if playing_players:
            for p in playing_players:
                if "spotify" in p.lower():
                    active_player = p
                    break
            if not active_player:
                active_player = playing_players[0]
        else:
            active_player = all_players[0]

        status = subprocess.check_output(["playerctl", "-p", active_player, "status"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        
        try:
            artist = subprocess.check_output(["playerctl", "-p", active_player, "metadata", "artist"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        except: artist = ""
        try:
            title = subprocess.check_output(["playerctl", "-p", active_player, "metadata", "title"], stderr=subprocess.DEVNULL).decode("utf-8").strip()
        except: title = ""

        if artist and title:
            metadata = f"{title} - {artist}"
        elif artist or title:
            metadata = artist if artist else title
        else:
            metadata = active_player.split('.')[0].capitalize()
            
        return status, metadata, active_player
    except Exception:
        return "Stopped", "", ""

def run():
    offset = 0
    last_meta = ""
    last_json = ""
    
    while True:
        status, metadata, player_id = get_player_data()

        if status != "Playing":
            offset = 0

        if not metadata or status == "Stopped":
            res = json.dumps({"status": "Stopped", "text": "NO_DATA_STREAM".ljust(WIDTH, "\u00A0"), "icon": "󰐊", "name": "", "active": False})
            if res != last_json:
                print(res, flush=True)
                last_json = res
            time.sleep(1)
            continue

        if metadata != last_meta:
            offset = 0
            last_meta = metadata

        text = unicodedata.normalize('NFC', metadata).replace(" ", "\u00A0")
        
        if len(text) > WIDTH:
            text_with_gap = text + "\u00A0" * 5
            L = len(text_with_gap)
            start = offset % L
            display_text = (text_with_gap[start:] + text_with_gap[:start])[:WIDTH]
        else:
            display_text = text.ljust(WIDTH, "\u00A0")

        current_data = {
            "status": status,
            "text": display_text,
            "icon": "󰏤" if status == "Playing" else "󰐊",
            "name": player_id,
            "active": True
        }
        res = json.dumps(current_data)

        if res != last_json or status == "Playing":
            print(res, flush=True)
            last_json = res
        
        if status == "Playing":
            offset += 1
            time.sleep(0.5)
        else:
            time.sleep(1.0)

if __name__ == "__main__":
    run()
