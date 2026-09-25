#!/usr/bin/env python3
import json
import dbus
import dbus.service
import time
import threading
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

notifications = []

def print_state():
    print(json.dumps(notifications), flush=True)

def remove_notif(uid):
    global notifications
    notifications = [n for n in notifications if n['id'] != int(uid)]
    print_state()

class NotificationServer(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName('org.freedesktop.Notifications', bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/org/freedesktop/Notifications')

    @dbus.service.method('org.freedesktop.Notifications', in_signature='susssasa{ss}i', out_signature='u')
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        uid = int(time.time() * 1000) % 2147483647 
        
        new_notif = {
            "id": uid,
            "app": str(app_name),
            "icon": str(app_icon),
            "summary": str(summary),
            "body": str(body),
            "time": time.strftime("%H:%M")
        }

        notifications.insert(0, new_notif)
        print_state()

        threading.Timer(6.0, remove_notif, [uid]).start()
        
        return uid

    @dbus.service.method('org.freedesktop.Notifications', in_signature='u', out_signature='')
    def CloseNotification(self, id):
        remove_notif(id)

    @dbus.service.method('org.freedesktop.Notifications', out_signature='ssss')
    def GetServerInformation(self):
        return ("Eww Notification Server", "Gemini", "1.0", "1.2")

    @dbus.service.method('org.freedesktop.Notifications', out_signature='as')
    def GetCapabilities(self):
        return ['body', 'actions', 'icon-static']

DBusGMainLoop(set_as_default=True)
if __name__ == '__main__':
    server = NotificationServer()
    print_state()
    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        pass
