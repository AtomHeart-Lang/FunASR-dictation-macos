from dataclasses import dataclass
from typing import Tuple


@dataclass(frozen=True)
class HotkeyDialogItem:
    key: str
    label_key: str


@dataclass(frozen=True)
class HotkeyDialogSection:
    key: str
    title_key: str
    items: Tuple[HotkeyDialogItem, ...]


@dataclass(frozen=True)
class HotkeyDialogAction:
    key: str
    label_key: str
    emphasis: str = "secondary"


@dataclass(frozen=True)
class HotkeyDialogGeometry:
    panel_w: int
    panel_h: int
    mode_card_x: int
    mode_card_y: int
    mode_card_w: int
    mode_card_h: int
    current_card_x: int
    current_card_y: int
    current_card_w: int
    current_card_h: int
    current_keyboard_y: int
    current_mouse_y: int
    current_title_bottom: int


def build_hotkey_settings_sections() -> Tuple[HotkeyDialogSection, ...]:
    return (
        HotkeyDialogSection(
            key="mode",
            title_key="hotkey_dialog_section_mode",
            items=(
                HotkeyDialogItem("mode_keyboard", "mode_keyboard"),
                HotkeyDialogItem("mode_mouse", "mode_mouse"),
            ),
        ),
        HotkeyDialogSection(
            key="current",
            title_key="hotkey_dialog_section_current",
            items=(
                HotkeyDialogItem("keyboard_hotkey", "hotkey_settings_keyboard_line"),
                HotkeyDialogItem("mouse_button", "hotkey_settings_mouse_line"),
            ),
        ),
    )


def build_hotkey_settings_actions() -> Tuple[HotkeyDialogAction, ...]:
    return (
        HotkeyDialogAction(
            key="set_keyboard",
            label_key="menu_set_hotkey",
        ),
        HotkeyDialogAction(
            key="set_mouse",
            label_key="menu_set_mouse",
        ),
        HotkeyDialogAction(
            key="save",
            label_key="save",
            emphasis="primary",
        ),
    )


def build_hotkey_dialog_geometry() -> HotkeyDialogGeometry:
    panel_w = 278
    panel_h = 172
    current_card_h = 72
    return HotkeyDialogGeometry(
        panel_w=panel_w,
        panel_h=panel_h,
        mode_card_x=14,
        mode_card_y=100,
        mode_card_w=panel_w - 28,
        mode_card_h=60,
        current_card_x=14,
        current_card_y=12,
        current_card_w=panel_w - 28,
        current_card_h=current_card_h,
        current_keyboard_y=22,
        current_mouse_y=6,
        current_title_bottom=current_card_h - 28,
    )
