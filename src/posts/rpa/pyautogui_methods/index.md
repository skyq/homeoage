---
title: Методы для работы с pyautogui
---

[git](https://github.com/skyq/rpa_pyautogui_methods)

На нескольких проектах использовал [PyAutoGUI](https://pyautogui.readthedocs.io/en/latest/install.html) и само собой
набрался файлик с методами для удобной работы с этой библиотекой.

Все изображения храним в папке `img`

```python 
import pyautogui
import time
from os.path import join, abspath, dirname, exists
from os import makedirs

root = dirname(abspath(__file__))
confidence = 0.7
img_dir = join(root, 'img')

if not exists(img_dir):
    makedirs(img_dir)

screenshots_dir = join(img_dir, 'screenshots')

if not exists(screenshots_dir):
    makedirs(screenshots_dir)


def get_img_path(img):
    return join(img_dir, img)


def get_center(img, region=None):
    """
    Ищет центр img на экране и возвращает центр (x, y).
    Если указан region (left, top, width, height) - Ищет картинку только в этой области
    """
    if region is None:
        return pyautogui.locateCenterOnScreen(get_img_path(img), confidence=confidence)
    else:
        return pyautogui.locateCenterOnScreen(get_img_path(img), region=region, confidence=confidence)


def get_locate(img, region=None):
    """
    Ищет img на экране и возвращает центр (x, y, width, height).
    Если указан region (left, top, width, height) - Ищет картинку только в этой области
    """
    if region is None:
        return pyautogui.locateOnScreen(get_img_path(img), confidence=confidence)
    else:
        return pyautogui.locateOnScreen(get_img_path(img), region=region, confidence=confidence)


def wait_element(img, timeout=15, region=None) -> bool:
    """
    Ожидает появления Img на экране. В случае успеха возварщеает True
    :param img: имя картинки в папке img
    :param timeout: максимальное время ожидания img
    :param region: область в которой искать (left, top, width, height)
    :return: bool
    """
    if not exists(get_img_path(img)):
        raise Exception(f'File not found {get_img_path(img)}')

    time_start = time.time()
    while True:
        btn = get_center(img, region)
        if btn is not None:
            return True
        time_cur = time.time()
        if time_cur - time_start > timeout:
            time.sleep(0.5)
            return False


def click(img=None, region=None, x=0, y=0, button='left') -> None:
    """
    Клик на центр картинки со смещением x, y или клик по центру x, y
    :param img: имя картинки в папке img
    :param region: область в которой искать (left, top, width, height)
    :param x: смещение по оси x относительно центра картинки
    :param y: смещение по оси y относительно центра картинки
    :return: None
    """
    if img is None:
        pyautogui.click(x, y, button=button)
    else:
        if not wait_element(img, timeout=1, region=region):
            raise Exception(f'Not found {get_img_path(img)} on screen')

        img_x, img_y = get_center(img, region)
        pyautogui.click(img_x + x, img_y + y, button=button)


def hower(img=None, region=None, x=0, y=0) -> None:
    """
    Наводит курсор на центр картинки со смещением x, y или по центру x, y
    :param img: имя картинки в папке img
    :param region: область в которой искать (left, top, width, height)
    :param x: смещение по оси x относительно центра картинки
    :param y: смещение по оси y относительно центра картинки
    :return: None
    """
    if img is None:
        pyautogui.moveTo(x, y)
    else:
        if not wait_element(img, timeout=1, region=region):
            raise Exception(f'Not found {get_img_path(img)} on screen')

        img_x, img_y = get_center(img, region=region)
        pyautogui.moveTo(img_x + x, img_y + y)


def hower_click(img, region=None, x=0, y=0, timeout=0.5, button="left") -> None:
    hower(img, region, x, y)
    time.sleep(timeout)
    pyautogui.click(button=button)


def screenshot(img, region=None):
    if region is None:
        pyautogui.screenshot(join(screenshots_dir, img))
    else:
        pyautogui.screenshot(join(screenshots_dir, img), region=region)

```

За этой библиотекой были замечаны ошибки ввода текста и вызова hotkey если раскладка языка установлена на RUS. Тут
иногда помогает библиотека [keyboard](https://pypi.org/project/keyboard/) и для нее пригодился вот такой метод в ходе
работы:

```python 
import keyboard

def press(key, presses=1, interval=0.2):
    for i in range(0, presses):
        keyboard.send(key)
        if interval > 0:
            time.sleep(interval)
```
