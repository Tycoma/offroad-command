import sys
from datetime import datetime

from PySide6.QtCore import QTimer, Qt
from PySide6.QtGui import QColor, QFont
from PySide6.QtWidgets import (
    QApplication,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QPushButton,
    QStackedWidget,
    QVBoxLayout,
    QWidget,
)


BACKGROUND = "#0b0f14"
PANEL = "#151c24"
PANEL_PRESSED = "#263646"
TEXT = "#f3f6f8"
SECONDARY_TEXT = "#97a6b5"
ACCENT = "#39a8ff"
WARNING = "#ffb347"


class Page(QWidget):
    def __init__(self, title: str, description: str):
        super().__init__()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(40, 32, 40, 32)
        layout.setSpacing(18)

        title_label = QLabel(title)
        title_label.setObjectName("pageTitle")

        description_label = QLabel(description)
        description_label.setObjectName("description")
        description_label.setWordWrap(True)

        demo_panel = QFrame()
        demo_panel.setObjectName("demoPanel")

        demo_layout = QVBoxLayout(demo_panel)
        demo_layout.setContentsMargins(28, 28, 28, 28)

        demo_text = QLabel(f"{title.upper()} MODULE")
        demo_text.setAlignment(Qt.AlignmentFlag.AlignCenter)
        demo_text.setObjectName("demoText")

        demo_layout.addStretch()
        demo_layout.addWidget(demo_text)
        demo_layout.addStretch()

        layout.addWidget(title_label)
        layout.addWidget(description_label)
        layout.addWidget(demo_panel, 1)


class EnginePage(QWidget):
    def __init__(self):
        super().__init__()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(40, 32, 40, 32)
        layout.setSpacing(18)

        title = QLabel("Engine")
        title.setObjectName("pageTitle")
        layout.addWidget(title)

        subtitle = QLabel("Simulated MEFI-4 engine information")
        subtitle.setObjectName("description")
        layout.addWidget(subtitle)

        gauge_grid = QGridLayout()
        gauge_grid.setSpacing(16)

        self.gauges = {}

        gauge_data = [
            ("RPM", "0", "RPM"),
            ("Coolant", "185", "°F"),
            ("Oil Pressure", "48", "PSI"),
            ("Battery", "14.2", "V"),
            ("Fuel Pressure", "58", "PSI"),
            ("Throttle", "0", "%"),
        ]

        for index, (name, value, unit) in enumerate(gauge_data):
            gauge = self.create_gauge(name, value, unit)
            row = index // 3
            column = index % 3
            gauge_grid.addWidget(gauge, row, column)

        layout.addLayout(gauge_grid, 1)

        self.rpm_value = self.gauges["RPM"]
        self.demo_rpm = 850
        self.rpm_direction = 1

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_demo_data)
        self.timer.start(100)

    def create_gauge(self, name: str, value: str, unit: str) -> QFrame:
        frame = QFrame()
        frame.setObjectName("gauge")

        layout = QVBoxLayout(frame)
        layout.setContentsMargins(20, 18, 20, 18)

        name_label = QLabel(name)
        name_label.setObjectName("gaugeName")

        value_label = QLabel(value)
        value_label.setObjectName("gaugeValue")
        value_label.setAlignment(Qt.AlignmentFlag.AlignCenter)

        unit_label = QLabel(unit)
        unit_label.setObjectName("gaugeUnit")
        unit_label.setAlignment(Qt.AlignmentFlag.AlignCenter)

        layout.addWidget(name_label)
        layout.addStretch()
        layout.addWidget(value_label)
        layout.addWidget(unit_label)
        layout.addStretch()

        self.gauges[name] = value_label
        return frame

    def update_demo_data(self):
        self.demo_rpm += 45 * self.rpm_direction

        if self.demo_rpm >= 3200:
            self.rpm_direction = -1
        elif self.demo_rpm <= 850:
            self.rpm_direction = 1

        self.rpm_value.setText(str(self.demo_rpm))


class HomePage(QWidget):
    def __init__(self, navigate):
        super().__init__()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(40, 30, 40, 34)
        layout.setSpacing(20)

        header = QHBoxLayout()

        title_box = QVBoxLayout()

        title = QLabel("OFF-ROAD COMMAND")
        title.setObjectName("homeTitle")

        subtitle = QLabel("Passenger control station")
        subtitle.setObjectName("description")

        title_box.addWidget(title)
        title_box.addWidget(subtitle)

        self.clock = QLabel()
        self.clock.setObjectName("clock")
        self.clock.setAlignment(Qt.AlignmentFlag.AlignRight)

        header.addLayout(title_box)
        header.addStretch()
        header.addWidget(self.clock)

        layout.addLayout(header)

        tiles = QGridLayout()
        tiles.setSpacing(18)

        buttons = [
            ("MAPS", "Offline navigation and GPX tracks", 1),
            ("RADIO", "VHF channels and intercom", 2),
            ("ENGINE", "MEFI-4 gauges and warnings", 3),
            ("CAMERAS", "Front and rear video", 4),
            ("VEHICLE", "Lights, compressor and PDM", 5),
            ("SETTINGS", "Display and system configuration", 6),
        ]

        for index, (title_text, subtitle_text, page_index) in enumerate(buttons):
            button = self.create_tile(
                title_text,
                subtitle_text,
                lambda checked=False, page=page_index: navigate(page),
            )

            tiles.addWidget(button, index // 3, index % 3)

        layout.addLayout(tiles, 1)

        status = QLabel(
            "SIMULATION MODE  •  CAN DISCONNECTED  •  GPS DISCONNECTED"
        )
        status.setObjectName("status")
        status.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(status)

        timer = QTimer(self)
        timer.timeout.connect(self.update_clock)
        timer.start(1000)
        self.update_clock()

    def create_tile(self, title: str, subtitle: str, action) -> QPushButton:
        button = QPushButton(f"{title}\n\n{subtitle}")
        button.setObjectName("tile")
        button.setCursor(Qt.CursorShape.PointingHandCursor)
        button.clicked.connect(action)
        return button

    def update_clock(self):
        self.clock.setText(datetime.now().strftime("%I:%M %p\n%b %d, %Y"))


class PassengerDisplay(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Off-Road Passenger Display")
        self.setMinimumSize(800, 480)

        root = QWidget()
        root_layout = QVBoxLayout(root)
        root_layout.setContentsMargins(0, 0, 0, 0)
        root_layout.setSpacing(0)

        self.pages = QStackedWidget()

        self.home_page = HomePage(self.navigate)
        self.maps_page = Page(
            "Maps",
            "GPS, offline maps, waypoints and GPX track recording will appear here.",
        )
        self.radio_page = Page(
            "Radio",
            "VHF channel, frequency, squelch, volume and intercom controls.",
        )
        self.engine_page = EnginePage()
        self.camera_page = Page(
            "Cameras",
            "Front, rear and suspension camera feeds.",
        )
        self.vehicle_page = Page(
            "Vehicle",
            "Lighting, compressor and future solid-state PDM controls.",
        )
        self.settings_page = Page(
            "Settings",
            "Brightness, audio, Bluetooth, CAN and system configuration.",
        )

        for page in [
            self.home_page,
            self.maps_page,
            self.radio_page,
            self.engine_page,
            self.camera_page,
            self.vehicle_page,
            self.settings_page,
        ]:
            self.pages.addWidget(page)

        navigation_bar = QFrame()
        navigation_bar.setObjectName("navigationBar")

        navigation_layout = QHBoxLayout(navigation_bar)
        navigation_layout.setContentsMargins(18, 10, 18, 10)

        home_button = QPushButton("HOME")
        home_button.setObjectName("navButton")
        home_button.clicked.connect(lambda: self.navigate(0))

        back_button = QPushButton("BACK")
        back_button.setObjectName("navButton")
        back_button.clicked.connect(self.go_back)

        exit_button = QPushButton("EXIT")
        exit_button.setObjectName("navButton")
        exit_button.clicked.connect(self.close)

        navigation_layout.addWidget(home_button)
        navigation_layout.addWidget(back_button)
        navigation_layout.addStretch()
        navigation_layout.addWidget(exit_button)

        root_layout.addWidget(self.pages, 1)
        root_layout.addWidget(navigation_bar)

        self.setCentralWidget(root)
        self.apply_style()

    def navigate(self, page_index: int):
        self.pages.setCurrentIndex(page_index)

    def go_back(self):
        if self.pages.currentIndex() != 0:
            self.pages.setCurrentIndex(0)

    def apply_style(self):
        self.setStyleSheet(
            f"""
            QMainWindow, QWidget {{
                background-color: {BACKGROUND};
                color: {TEXT};
                font-family: DejaVu Sans;
            }}

            QLabel#homeTitle {{
                font-size: 30px;
                font-weight: 800;
                color: {TEXT};
            }}

            QLabel#pageTitle {{
                font-size: 32px;
                font-weight: 800;
            }}

            QLabel#description {{
                font-size: 16px;
                color: {SECONDARY_TEXT};
            }}

            QLabel#clock {{
                font-size: 18px;
                font-weight: 700;
                color: {TEXT};
            }}

            QLabel#status {{
                padding: 11px;
                font-size: 13px;
                font-weight: 700;
                color: {WARNING};
                background-color: {PANEL};
                border-radius: 8px;
            }}

            QPushButton#tile {{
                min-height: 145px;
                padding: 20px;
                border: 2px solid #22303d;
                border-radius: 14px;
                background-color: {PANEL};
                color: {TEXT};
                font-size: 17px;
                font-weight: 700;
                text-align: left;
            }}

            QPushButton#tile:hover {{
                border-color: {ACCENT};
            }}

            QPushButton#tile:pressed {{
                background-color: {PANEL_PRESSED};
            }}

            QFrame#navigationBar {{
                background-color: #080b0f;
                border-top: 1px solid #25313c;
            }}

            QPushButton#navButton {{
                min-width: 110px;
                min-height: 44px;
                border: 1px solid #30404f;
                border-radius: 8px;
                background-color: {PANEL};
                color: {TEXT};
                font-size: 14px;
                font-weight: 700;
            }}

            QPushButton#navButton:pressed {{
                background-color: {PANEL_PRESSED};
            }}

            QFrame#demoPanel {{
                background-color: {PANEL};
                border: 2px solid #22303d;
                border-radius: 16px;
            }}

            QLabel#demoText {{
                color: {SECONDARY_TEXT};
                font-size: 24px;
                font-weight: 700;
            }}

            QFrame#gauge {{
                background-color: {PANEL};
                border: 2px solid #22303d;
                border-radius: 14px;
            }}

            QLabel#gaugeName {{
                color: {SECONDARY_TEXT};
                font-size: 15px;
                font-weight: 700;
            }}

            QLabel#gaugeValue {{
                color: {TEXT};
                font-size: 42px;
                font-weight: 800;
            }}

            QLabel#gaugeUnit {{
                color: {ACCENT};
                font-size: 14px;
                font-weight: 700;
            }}
            """
        )


def main():
    app = QApplication(sys.argv)
    app.setFont(QFont("DejaVu Sans"))

    window = PassengerDisplay()

    # Press F11 to leave or re-enter full screen during development.
    window.showFullScreen()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
