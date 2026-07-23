from __future__ import annotations

from datetime import datetime
from typing import Any

from PySide6.QtCore import (
    QAbstractListModel,
    QByteArray,
    QModelIndex,
    Qt,
    Signal,
    Slot,
)


class ConsoleLogModel(QAbstractListModel):
    TimeRole = Qt.UserRole + 1
    ModuleRole = Qt.UserRole + 2
    LevelRole = Qt.UserRole + 3
    MessageRole = Qt.UserRole + 4

    countChanged = Signal()

    def __init__(self, parent=None, maximum_entries: int = 1000):
        super().__init__(parent)

        self._entries: list[dict[str, str]] = []
        self._maximum_entries = maximum_entries

    def roleNames(self) -> dict[int, QByteArray]:
        return {
            self.TimeRole: QByteArray(b"time"),
            self.ModuleRole: QByteArray(b"module"),
            self.LevelRole: QByteArray(b"level"),
            self.MessageRole: QByteArray(b"message"),
        }

    def rowCount(self, parent=QModelIndex()) -> int:
        if parent.isValid():
            return 0

        return len(self._entries)

    def data(
        self,
        index: QModelIndex,
        role: int = Qt.DisplayRole,
    ) -> Any:
        if not index.isValid():
            return None

        row = index.row()

        if row < 0 or row >= len(self._entries):
            return None

        entry = self._entries[row]

        if role == self.TimeRole:
            return entry["time"]

        if role == self.ModuleRole:
            return entry["module"]

        if role == self.LevelRole:
            return entry["level"]

        if role == self.MessageRole:
            return entry["message"]

        return None

    @Slot(str, str, str)
    def addEntry(
        self,
        module: str,
        level: str,
        message: str,
    ) -> None:
        module = str(module).strip().upper() or "SYSTEM"
        level = str(level).strip().upper() or "INFO"
        message = str(message).strip()

        if not message:
            return

        entry = {
            "time": datetime.now().strftime("%H:%M:%S"),
            "module": module,
            "level": level,
            "message": message,
        }

        self.beginInsertRows(
            QModelIndex(),
            len(self._entries),
            len(self._entries),
        )

        self._entries.append(entry)

        self.endInsertRows()
        self.countChanged.emit()

        self._trim_entries()

    def _trim_entries(self) -> None:
        excess = len(self._entries) - self._maximum_entries

        if excess <= 0:
            return

        self.beginRemoveRows(
            QModelIndex(),
            0,
            excess - 1,
        )

        del self._entries[:excess]

        self.endRemoveRows()
        self.countChanged.emit()

    @Slot()
    def clear(self) -> None:
        if not self._entries:
            return

        self.beginResetModel()
        self._entries.clear()
        self.endResetModel()

        self.countChanged.emit()

    @Slot(result=int)
    def getCount(self) -> int:
        return len(self._entries)
