from PySide6.QtCore import QObject, Property, Signal


class VehicleManager(QObject):
    dataChanged = Signal()

    def __init__(self, gps_backend, media_backend, navigation_backend):
        super().__init__()

        self._gps = gps_backend
        self._media = media_backend
        self._navigation = navigation_backend

        self._radio_channel = 4
        self._radio_name = ""
        self._radio_frequency = ""

        self._bluetooth_connected = False
        self._can_connected = False
        self._radio_connected = False
        self._transmitting = False
        self._warning_active = False

    #
    # GPS
    #

    @Property(int, notify=dataChanged)
    def gpsSatellites(self):
        try:
            return self._gps.satellites
        except AttributeError:
            return 0

    #
    # Bluetooth
    #

    @Property(bool, notify=dataChanged)
    def bluetoothConnected(self):
        return self._bluetooth_connected

    #
    # CAN
    #

    @Property(bool, notify=dataChanged)
    def canConnected(self):
        return self._can_connected

    #
    # Radio
    #

    @Property(int, notify=dataChanged)
    def radioChannel(self):
        return self._radio_channel

    @Property(str, notify=dataChanged)
    def radioChannelName(self):
        return self._radio_name

    @Property(str, notify=dataChanged)
    def radioFrequency(self):
        return self._radio_frequency

    @Property(bool, notify=dataChanged)
    def transmitting(self):
        return self._transmitting

    @Property(bool, notify=dataChanged)
    def warningActive(self):
        return self._warning_active

    #
    # Media
    #

    @Property(str, notify=dataChanged)
    def mediaTitle(self):
        try:
            return self._media.title
        except AttributeError:
            return ""

    @Property(str, notify=dataChanged)
    def mediaArtist(self):
        try:
            return self._media.artist
        except AttributeError:
            return ""
