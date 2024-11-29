"""Customisations to the global logging system and custom logging classses."""

import logging
from logging.handlers import TimedRotatingFileHandler

from hpk.typing import LogArg

# Define custom levels
TRACE_LEVEL = 5
SUCCESS_LEVEL = 25

logging.addLevelName(TRACE_LEVEL, "TRACE")
logging.addLevelName(SUCCESS_LEVEL, "SUCCESS")


# Add methods for convenience
def trace(self: logging.Logger, message: str, *args: LogArg, **kwargs: LogArg) -> None:
    """Log `message at TRACE level."""
    if self.isEnabledFor(TRACE_LEVEL):
        self._log(TRACE_LEVEL, message, args, **kwargs)


def success(self: logging.Logger, message: str, *args: LogArg, **kwargs: LogArg) -> None:
    """Log `message at SUCCESS level."""
    if self.isEnabledFor(SUCCESS_LEVEL):
        self._log(SUCCESS_LEVEL, message, args, **kwargs)


logging.Logger.trace = trace
logging.Logger.success = success


# Handlers


class RotatingDailyFileHandler(TimedRotatingFileHandler):
    """Rotates file logs daily at midnight, with a week of backups by default."""

    def __init__(self, filename: str, backup_days: int = 7) -> None:
        """Pass our defaults and given args to TimedRotatingFileHandler's __init__ method."""
        super().__init__(filename, when="midnight", interval=1, backupCount=backup_days)


# Formatters


class FormatterWithEverything(logging.Formatter):
    """The *most* verbose logging formatter."""

    def format(self, record: logging.LogRecord) -> str:
        """Return a ludicrously verbose log message format."""
        verbose_message = (
            f"LEVEL: {record.levelname}\n"
            f"TIME: {self.formatTime(record)}\n"
            f"LOGGER: {record.name}\n"
            f"MODULE: {record.module}\n"
            f"FUNC: {record.funcName}\n"
            f"LINE: {record.lineno}\n"
            f"PATH: {record.pathname}\n"
            f"THREAD: {record.threadName}\n"
            f"PROCESS: {record.process}\n"
            f"MESSAGE: {record.getMessage()}\n"
        )
        if record.exc_info:
            verbose_message += f"EXCEPTION: {self.formatException(record.exc_info)}\n"
        return verbose_message
