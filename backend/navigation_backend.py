from __future__ import annotations

import sqlite3
from pathlib import Path

from PySide6.QtCore import QObject, Signal, Slot


class NavigationBackend(QObject):
    waypointSaved = Signal(str, float, float)
    waypointSaveFailed = Signal(str)

    def __init__(self) -> None:
        super().__init__()

        self.database_path = (
            Path.home()
            / "passenger-display"
            / "data"
            / "navigation.db"
        )

        self.database_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        self.initialize_database()

    def connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(self.database_path)
        connection.row_factory = sqlite3.Row
        return connection

    def initialize_database(self) -> None:
        with self.connect() as connection:
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS waypoints (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    category TEXT NOT NULL DEFAULT 'General',
                    notes TEXT NOT NULL DEFAULT '',
                    latitude REAL NOT NULL,
                    longitude REAL NOT NULL,
                    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )

    @Slot(str, str, str, float, float, result=bool)
    def saveWaypoint(
        self,
        name: str,
        category: str,
        notes: str,
        latitude: float,
        longitude: float,
    ) -> bool:
        clean_name = name.strip()

        if not clean_name:
            self.waypointSaveFailed.emit(
                "Waypoint name is required."
            )
            return False

        try:
            with self.connect() as connection:
                connection.execute(
                    """
                    INSERT INTO waypoints (
                        name,
                        category,
                        notes,
                        latitude,
                        longitude
                    )
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (
                        clean_name,
                        category,
                        notes.strip(),
                        latitude,
                        longitude,
                    ),
                )

            self.waypointSaved.emit(
                clean_name,
                latitude,
                longitude,
            )

            return True

        except sqlite3.Error as error:
            self.waypointSaveFailed.emit(str(error))
            return False
