from __future__ import annotations

from pathlib import Path

from PySide6.QtCore import QObject, Signal, Slot

from backend.console_log_model import ConsoleLogModel


class LogBridge(QObject):
    entryAdded = Signal(str, str, str)
    logSaved = Signal(str)
    logSaveFailed = Signal(str)

    def __init__(
        self,
        model: ConsoleLogModel,
        parent=None,
    ):
        super().__init__(parent)

        self._model = model
        self.entryAdded.connect(self._model.addEntry)

    def _write(
        self,
        module: str,
        level: str,
        message: str,
    ) -> None:
        clean_module = str(module).strip().upper() or "SYSTEM"
        clean_level = str(level).strip().upper() or "INFO"
        clean_message = str(message).strip()

        if not clean_message:
            return

        print(
            f"[{clean_level}] "
            f"[{clean_module}] "
            f"{clean_message}",
            flush=True,
        )

        self.entryAdded.emit(
            clean_module,
            clean_level,
            clean_message,
        )

    @Slot(str, str)
    def debug(self, module: str, message: str) -> None:
        self._write(module, "DEBUG", message)

    @Slot(str, str)
    def info(self, module: str, message: str) -> None:
        self._write(module, "INFO", message)

    @Slot(str, str)
    def warning(self, module: str, message: str) -> None:
        self._write(module, "WARNING", message)

    @Slot(str, str)
    def error(self, module: str, message: str) -> None:
        self._write(module, "ERROR", message)

    @Slot(str, str, str)
    def log(
        self,
        module: str,
        level: str,
        message: str,
    ) -> None:
        self._write(module, level, message)

    @Slot()
    def clear(self) -> None:
        self._model.clear()

    @Slot(str)
    def saveLog(self, file_path: str) -> None:
        path_text = str(file_path).strip()

        if not path_text:
            path_text = "logs/developer-console.log"

        path = Path(path_text).expanduser()

        try:
            path.parent.mkdir(
                parents=True,
                exist_ok=True,
            )

            lines: list[str] = []

            for entry in self._model._entries:
                lines.append(
                    f'{entry["time"]} '
                    f'[{entry["level"]}] '
                    f'[{entry["module"]}] '
                    f'{entry["message"]}'
                )

            path.write_text(
                "\n".join(lines) + ("\n" if lines else ""),
                encoding="utf-8",
            )

            resolved_path = str(path.resolve())

            self._write(
                "SYSTEM",
                "INFO",
                f"Log saved to {resolved_path}",
            )

            self.logSaved.emit(resolved_path)

        except Exception as error:
            message = f"Unable to save log: {error}"

            self._write(
                "SYSTEM",
                "ERROR",
                message,
            )

            self.logSaveFailed.emit(message)
