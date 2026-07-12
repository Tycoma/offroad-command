from __future__ import annotations

import re
import subprocess
from typing import Optional

from PySide6.QtCore import QObject, Property, QTimer, Signal, Slot


class MediaBackend(QObject):
    mediaChanged = Signal()
    volumeChanged = Signal()
    errorChanged = Signal()
    previousPhoneChanged = Signal()
    connectionMessageChanged = Signal()

    # Previously paired phone
    PREVIOUS_PHONE_MAC = "C4:F7:C1:BA:87:63"

    def __init__(self) -> None:
        super().__init__()

        self._player_path = ""

        self._title = "No media playing"
        self._artist = "Connect phone and start Spotify"
        self._album = ""
        self._playback_status = "Stopped"
        self._connected = False
        self._volume = 70
        self._error = ""

        self._previous_phone_name = "Previous phone"
        self._previous_phone_mac = self.PREVIOUS_PHONE_MAC
        self._previous_phone_connected = False
        self._previous_phone_paired = False
        self._previous_phone_trusted = False
        self._connection_message = ""

        self._timer = QTimer(self)
        self._timer.setInterval(1000)
        self._timer.timeout.connect(self.refresh)
        self._timer.start()

        self.refreshPreviousPhone()
        self.refresh()

    @staticmethod
    def _run(
        command: list[str],
        timeout: float = 6.0,
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )

    def _set_error(self, message: str) -> None:
        if message != self._error:
            self._error = message
            self.errorChanged.emit()

    def _set_connection_message(self, message: str) -> None:
        if message != self._connection_message:
            self._connection_message = message
            self.connectionMessageChanged.emit()

    @staticmethod
    def _bluetooth_value(
        output: str,
        field: str,
    ) -> str:
        pattern = rf"^\s*{re.escape(field)}:\s*(.+?)\s*$"
        match = re.search(
            pattern,
            output,
            flags=re.MULTILINE,
        )

        return match.group(1).strip() if match else ""

    @Slot()
    def refreshPreviousPhone(self) -> None:
        try:
            result = self._run(
                [
                    "bluetoothctl",
                    "info",
                    self._previous_phone_mac,
                ]
            )

            output = result.stdout

            name = (
                self._bluetooth_value(output, "Alias")
                or self._bluetooth_value(output, "Name")
                or "Previous phone"
            )

            connected = (
                self._bluetooth_value(output, "Connected").lower()
                == "yes"
            )

            paired = (
                self._bluetooth_value(output, "Paired").lower()
                == "yes"
            )

            trusted = (
                self._bluetooth_value(output, "Trusted").lower()
                == "yes"
            )

            changed = (
                name != self._previous_phone_name
                or connected != self._previous_phone_connected
                or paired != self._previous_phone_paired
                or trusted != self._previous_phone_trusted
            )

            self._previous_phone_name = name
            self._previous_phone_connected = connected
            self._previous_phone_paired = paired
            self._previous_phone_trusted = trusted

            if changed:
                self.previousPhoneChanged.emit()

        except (
            FileNotFoundError,
            subprocess.SubprocessError,
        ) as error:
            self._set_error(str(error))

    @Slot()
    def connectPreviousPhone(self) -> None:
        self._set_connection_message(
            f"Connecting to {self._previous_phone_name}..."
        )

        try:
            self._run(
                [
                    "bluetoothctl",
                    "power",
                    "on",
                ]
            )

            self._run(
                [
                    "bluetoothctl",
                    "trust",
                    self._previous_phone_mac,
                ]
            )

            result = self._run(
                [
                    "bluetoothctl",
                    "connect",
                    self._previous_phone_mac,
                ],
                timeout=15.0,
            )

            QTimer.singleShot(
                1200,
                self._finishPreviousPhoneConnection,
            )

            if result.returncode != 0:
                error_text = (
                    result.stderr.strip()
                    or result.stdout.strip()
                    or "Bluetooth connection failed."
                )

                self._set_connection_message(error_text)

        except (
            FileNotFoundError,
            subprocess.SubprocessError,
        ) as error:
            self._set_connection_message(str(error))

    @Slot()
    def _finishPreviousPhoneConnection(self) -> None:
        self.refreshPreviousPhone()
        self.refresh()

        if self._previous_phone_connected:
            self._set_connection_message(
                f"{self._previous_phone_name} connected."
            )
        else:
            self._set_connection_message(
                "Phone was not available. Make sure Bluetooth is enabled "
                "and the phone is near the display."
            )

    @Slot()
    def disconnectPreviousPhone(self) -> None:
        try:
            result = self._run(
                [
                    "bluetoothctl",
                    "disconnect",
                    self._previous_phone_mac,
                ]
            )

            if result.returncode == 0:
                self._set_connection_message(
                    f"{self._previous_phone_name} disconnected."
                )
            else:
                self._set_connection_message(
                    result.stderr.strip()
                    or result.stdout.strip()
                    or "Disconnect failed."
                )

            QTimer.singleShot(
                700,
                self._finishPreviousPhoneDisconnect,
            )

        except (
            FileNotFoundError,
            subprocess.SubprocessError,
        ) as error:
            self._set_connection_message(str(error))

    @Slot()
    def _finishPreviousPhoneDisconnect(self) -> None:
        self.refreshPreviousPhone()
        self.refresh()

    def _find_bluez_player(self) -> Optional[str]:
        result = self._run(
            [
                "busctl",
                "tree",
                "org.bluez",
                "--list",
            ]
        )

        if result.returncode != 0:
            return None

        for line in result.stdout.splitlines():
            path = line.strip()

            if "/player" in path:
                return path

        return None

    def _get_property(self, property_name: str) -> str:
        if not self._player_path:
            return ""

        result = self._run(
            [
                "busctl",
                "get-property",
                "org.bluez",
                self._player_path,
                "org.bluez.MediaPlayer1",
                property_name,
            ]
        )

        if result.returncode != 0:
            return ""

        return result.stdout.strip()

    @staticmethod
    def _parse_string_property(raw_value: str) -> str:
        match = re.search(r'^s\s+"(.*)"$', raw_value)

        if match:
            return match.group(1)

        return raw_value.replace('s "', "").rstrip('"').strip()

    @staticmethod
    def _extract_track_value(
        raw_track: str,
        key: str,
    ) -> str:
        patterns = [
            rf'"{re.escape(key)}"\s+s\s+"([^"]*)"',
            rf'{re.escape(key)}\s+s\s+"([^"]*)"',
        ]

        for pattern in patterns:
            match = re.search(pattern, raw_track)

            if match:
                return match.group(1)

        return ""

    def _update_media(
        self,
        player_path: str,
        title: str,
        artist: str,
        album: str,
        status: str,
        connected: bool,
    ) -> None:
        changed = (
            self._player_path != player_path
            or self._title != title
            or self._artist != artist
            or self._album != album
            or self._playback_status != status
            or self._connected != connected
        )

        self._player_path = player_path
        self._title = title
        self._artist = artist
        self._album = album
        self._playback_status = status
        self._connected = connected

        if changed:
            self.mediaChanged.emit()

    def _call_player(self, method: str) -> bool:
        if not self._player_path:
            self.refresh()

        if not self._player_path:
            self._set_error("No Bluetooth media player found.")
            return False

        result = self._run(
            [
                "busctl",
                "call",
                "org.bluez",
                self._player_path,
                "org.bluez.MediaPlayer1",
                method,
            ]
        )

        if result.returncode != 0:
            self._set_error(
                result.stderr.strip()
                or f"{method} command failed."
            )
            return False

        self._set_error("")
        QTimer.singleShot(300, self.refresh)
        return True

    def _refresh_volume(self) -> None:
        result = self._run(
            [
                "wpctl",
                "get-volume",
                "@DEFAULT_AUDIO_SINK@",
            ]
        )

        if result.returncode != 0:
            return

        match = re.search(
            r"Volume:\s+([0-9.]+)",
            result.stdout,
        )

        if not match:
            return

        new_volume = round(float(match.group(1)) * 100)
        new_volume = max(0, min(100, new_volume))

        if new_volume != self._volume:
            self._volume = new_volume
            self.volumeChanged.emit()

    @Slot()
    def refresh(self) -> None:
        self.refreshPreviousPhone()

        try:
            player_path = self._find_bluez_player()

            if not player_path:
                self._update_media(
                    "",
                    "No media playing",
                    (
                        self._previous_phone_name
                        if self._previous_phone_connected
                        else "Connect phone and start Spotify"
                    ),
                    "",
                    "Stopped",
                    self._previous_phone_connected,
                )

                self._refresh_volume()
                return

            self._player_path = player_path

            raw_status = self._get_property("Status")
            status = self._parse_string_property(raw_status)

            if not status:
                status = "Stopped"

            raw_track = self._get_property("Track")

            title = self._extract_track_value(
                raw_track,
                "Title",
            )

            artist = self._extract_track_value(
                raw_track,
                "Artist",
            )

            album = self._extract_track_value(
                raw_track,
                "Album",
            )

            if not title:
                title = "Bluetooth Audio"

            if not artist:
                artist = self._previous_phone_name

            self._update_media(
                player_path,
                title,
                artist,
                album,
                status,
                True,
            )

            self._refresh_volume()
            self._set_error("")

        except (
            FileNotFoundError,
            subprocess.SubprocessError,
            ValueError,
        ) as error:
            self._set_error(str(error))

    @Slot()
    def playPause(self) -> None:
        if self._playback_status.lower() == "playing":
            self._call_player("Pause")
        else:
            self._call_player("Play")

    @Slot()
    def previous(self) -> None:
        self._call_player("Previous")

    @Slot()
    def next(self) -> None:
        self._call_player("Next")

    @Slot(int)
    def setVolume(self, volume: int) -> None:
        safe_volume = max(0, min(100, int(volume)))

        result = self._run(
            [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                f"{safe_volume / 100:.2f}",
            ]
        )

        if result.returncode != 0:
            self._set_error(
                result.stderr.strip()
                or "Volume command failed."
            )
            return

        if safe_volume != self._volume:
            self._volume = safe_volume
            self.volumeChanged.emit()

    @Property(str, notify=mediaChanged)
    def title(self) -> str:
        return self._title

    @Property(str, notify=mediaChanged)
    def artist(self) -> str:
        return self._artist

    @Property(str, notify=mediaChanged)
    def album(self) -> str:
        return self._album

    @Property(str, notify=mediaChanged)
    def playbackStatus(self) -> str:
        return self._playback_status

    @Property(bool, notify=mediaChanged)
    def connected(self) -> bool:
        return self._connected

    @Property(int, notify=volumeChanged)
    def volume(self) -> int:
        return self._volume

    @Property(str, notify=errorChanged)
    def error(self) -> str:
        return self._error

    @Property(str, notify=previousPhoneChanged)
    def previousPhoneName(self) -> str:
        return self._previous_phone_name

    @Property(str, notify=previousPhoneChanged)
    def previousPhoneMac(self) -> str:
        return self._previous_phone_mac

    @Property(bool, notify=previousPhoneChanged)
    def previousPhoneConnected(self) -> bool:
        return self._previous_phone_connected

    @Property(bool, notify=previousPhoneChanged)
    def previousPhonePaired(self) -> bool:
        return self._previous_phone_paired

    @Property(bool, notify=previousPhoneChanged)
    def previousPhoneTrusted(self) -> bool:
        return self._previous_phone_trusted

    @Property(str, notify=connectionMessageChanged)
    def connectionMessage(self) -> str:
        return self._connection_message
