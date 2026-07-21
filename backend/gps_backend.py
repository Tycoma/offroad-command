import json
import socket

from PySide6.QtCore import QObject, Property, QTimer, Signal


class GPSBackend(QObject):
    speedChanged = Signal()
    headingChanged = Signal()
    satellitesChanged = Signal()
    latitudeChanged = Signal()
    longitudeChanged = Signal()
    fixModeChanged = Signal()
    connectedChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._speed_mph = 0
        self._heading = 0
        self._satellites = 0
        self._latitude = 0.0
        self._longitude = 0.0
        self._fix_mode = 0
        self._connected = False

        self._socket = None
        self._buffer = ""

        self._timer = QTimer(self)
        self._timer.setInterval(200)
        self._timer.timeout.connect(self._poll)
        self._timer.start()

        self._connect_to_gpsd()

    def _set_connected(self, value):
        value = bool(value)
        if value != self._connected:
            self._connected = value
            self.connectedChanged.emit()

    def _connect_to_gpsd(self):
        self._close_socket()

        try:
            gps_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            gps_socket.settimeout(1.0)
            gps_socket.connect(("127.0.0.1", 2947))

            watch_command = '?WATCH={"enable":true,"json":true};\n'
            gps_socket.sendall(watch_command.encode("ascii"))
            gps_socket.setblocking(False)

            self._socket = gps_socket
            self._buffer = ""
            self._set_connected(True)

            print("GPS: connected to gpsd on 127.0.0.1:2947")

        except OSError as error:
            self._socket = None
            self._set_connected(False)
            print(f"GPS: unable to connect to gpsd: {error}")

    def _close_socket(self):
        if self._socket is not None:
            try:
                self._socket.close()
            except OSError:
                pass

        self._socket = None
        self._set_connected(False)

    def _poll(self):
        if self._socket is None:
            self._connect_to_gpsd()
            return

        try:
            while True:
                chunk = self._socket.recv(4096)

                if not chunk:
                    self._close_socket()
                    return

                self._buffer += chunk.decode("utf-8", errors="ignore")

        except BlockingIOError:
            pass

        except OSError as error:
            print(f"GPS: connection error: {error}")
            self._close_socket()
            return

        while "\n" in self._buffer:
            line, self._buffer = self._buffer.split("\n", 1)
            line = line.strip()

            if not line:
                continue

            try:
                message = json.loads(line)
            except json.JSONDecodeError:
                continue

            self._process_message(message)

    def _process_message(self, message):
        message_class = message.get("class")

        if message_class == "TPV":
            mode = int(message.get("mode", 0) or 0)
            self._update_fix_mode(mode)

            if mode >= 2:
                if "lat" in message:
                    self._update_latitude(float(message["lat"]))

                if "lon" in message:
                    self._update_longitude(float(message["lon"]))

                speed_mps = float(message.get("speed", 0.0) or 0.0)
                speed_mph = round(speed_mps * 2.236936)

                # Ignore tiny stationary GPS drift.
                if speed_mph < 1:
                    speed_mph = 0

                self._update_speed(speed_mph)

                # GPS track is unreliable while stationary.
                if speed_mps >= 0.5 and "track" in message:
                    heading = round(float(message["track"])) % 360
                    self._update_heading(heading)
            else:
                self._update_speed(0)

        elif message_class == "SKY":
            # Some SKY packets don't include uSat.
            # Only update when it is actually present.
            if "uSat" in message:
                satellites = int(message["uSat"] or 0)
                print(f"GPS satellites: {satellites}")
                self._update_satellites(satellites)

    def _update_speed(self, value):
        if value != self._speed_mph:
            self._speed_mph = value
            self.speedChanged.emit()

    def _update_heading(self, value):
        if value != self._heading:
            self._heading = value
            self.headingChanged.emit()

    def _update_satellites(self, value):
        if value != self._satellites:
            self._satellites = value
            self.satellitesChanged.emit()

    def _update_latitude(self, value):
        if value != self._latitude:
            self._latitude = value
            self.latitudeChanged.emit()

    def _update_longitude(self, value):
        if value != self._longitude:
            self._longitude = value
            self.longitudeChanged.emit()

    def _update_fix_mode(self, value):
        if value != self._fix_mode:
            self._fix_mode = value
            self.fixModeChanged.emit()

    @Property(int, notify=speedChanged)
    def speedMph(self):
        return self._speed_mph

    @Property(int, notify=headingChanged)
    def heading(self):
        return self._heading

    @Property(int, notify=satellitesChanged)
    def satellites(self):
        return self._satellites

    @Property(float, notify=latitudeChanged)
    def latitude(self):
        return self._latitude

    @Property(float, notify=longitudeChanged)
    def longitude(self):
        return self._longitude

    @Property(int, notify=fixModeChanged)
    def fixMode(self):
        return self._fix_mode

    @Property(bool, notify=connectedChanged)
    def connected(self):
        return self._connected
