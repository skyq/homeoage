---
title: Запуск 1С по расписанию и вызов обработки
---

[git](https://github.com/skyq/schedule_1C_epf)

Каждое утро мне нужно было запускать в 1С одну очень полезную обработку, а вечером тушить 1С.

Для начала сходим в
документацию ([Параметры командной строки запуска «1С:Предприятия»](https://its.1c.ru/db/v8311doc/bookmark/adm/TI000000493))
и почитаем как запускать 1С из консоли и соберем следующую команду:

``` 
{path_1C} ENTERPRISE /S {server_ip} /IBName "{base}" /N "{login}" /P "{pwd}" && exit
```

И попробуем запустить ее в python создав файл `start.py`

```python
import os

if __name__ == '__main__':
    server_ip = "192.168.1.1"
    login = "login"
    base = "name database"
    pwd = "123456"
    path_1C = "\"C:\\Program Files\\1cv8\\8.3.20.1674\\bin\\1cv8.exe\""

    cmd = 'echo \"start\" && {path_1C} ENTERPRISE /S {server_ip} /IBName "{base}" /N "{login}" /P "{pwd}" && exit'
    
    command = cmd.format(pwd=pwd, login=login, base=base, path_1C=path_1C, server_ip=server_ip)
    os.system(command)
```

1С запускается, но отойдем немного в сторону - хранить такие переменные как пароль в коде очень плохая идея, да и путь к
1С может поменяться. О том как хранить пароль было в [тут](/posts/rpa/python_password_storage_windows/). Добавим связку
логин/пароль опираясь на статью. Пусть логин будет `Вася.П`

А сейчас поговорим о файле с переменными окружения. Рядом с файлом `start.py` создаем `.env`. Для доступа к переменным
нужно установить `python-dotenv` выполнив команду `pip install python-dotenv`. Содержимое файла `.env`

```txt
LOGIN=Вася.П
BASE='Торговля 11.4'
SERVER_IP=192.168.1.1
PATH_1C=C:\Program Files\1cv8\8.3.20.1674\bin\1cv8.exe
```

Правим `start.py`

```python
import os
from dotenv import load_dotenv
import keyring

load_dotenv()

def start_1C():
    server_ip = os.getenv('SERVER_IP')
    login = os.getenv('LOGIN')
    base = os.getenv('BASE')
    path_1C = os.getenv('PATH_1C')
    pwd = keyring.get_password("system", login)

    cmd = 'echo \"start\" && \"{path_1C}\" ENTERPRISE /S {server_ip} /IBName "{base}" /N "{login}" /P "{pwd}" && exit'
    command = cmd.format(pwd=pwd, login=login, base=base, path_1C=path_1C, server_ip=server_ip)
    os.system(command)


if __name__ == '__main__':
    start_1C()
```

Как видно server_ip, login и прочие переменные, которые мы вынесли в `.env`, доступны через команду `os.getenv({KEY})`

## PyAutoGUI

Следующим шагом будет вызов обработки и тут нам поможет замечательная
библиотека [PyAutoGUI](https://pyautogui.readthedocs.io/en/latest/install.html). Установим ее `pip install pyautogui`.

```comment
Пару слов о билиотеке - она может:
 - находить на экране кнопки, 
 - текст и прочее по изображению, 
 - двигать мышкой, 
 - вводить текст, 
 - делать скриншоты экрана. 
 Это если коротко.
```

Для простоты методы для работы с PyAutoGUI я вынес в [отдельную статью](/posts/rpa/pyautogui_methods/)

И так, 1С открыта и нужно убедится что окно активно:

```python
import pyautogui
import rpa_pyautogui_methods as rpa_methods

def activate_1C():
    img = 'info.png'
    name_base = 'Управление торговлей' #В моем случае база называлась Управление торговлей 11.4
    success = False
    for w in pyautogui.getWindowsWithTitle(name_base):
        w.maximize()
        w.activate()
        if rpa_methods.wait_element(img, 2):
            rpa_methods.hower(img)
            success = True
            print('success')
            break

    if not success:
        raise Exception('Ошибка активации окна 1С')
```

Отправим команду `ctrl+o` для открытия файла внешней обработки и прописав путь к нему нажмем `Enter`

```python
from os.path import exists

def open_epf(path_epf):
    if not exists(path_epf):
        raise Exception('Файл обработки не существует')
    rpa_methods.press('ctrl+o', interval=1)
    keyboard.write(path_epf)
    rpa_methods.press('enter', interval=1)

```

При открытии внешней обработки может выскочить предупреждение безопасности и нужно нажать кнопку "Да"
attention.png
![attention.png](./attention.png)

```python
from os.path import exists

def open_epf(path_epf):
    if not exists(path_epf):
        raise Exception('Файл обработки не существует')
    rpa_methods.press('ctrl+o', interval=1)
    keyboard.write(path_epf)
    rpa_methods.press('enter', interval=1)
    img = "attention.png"
    img_yes = "attention_yes.png"
    if rpa_methods.wait_element(img, timeout=5):
        if not rpa_methods.wait_element(img_yes, timeout=5):
            raise Exception('Ошибка поиска кнопик Да')
        rpa_methods.hower_click(img_yes)

```

И тут хочу показать один прием - на экране может быть несколько похожих изображений. Нужно как то определить область где
искать нужное нам изображение. В нашем случае мы можем взять область 450 на 250 px (примерный размер окна
предупреждения). Дополним код

```python
x, y = rpa_methods.get_center(img)
region = (x, y, 450, 250)  # область в которой искать (left, top, width, height)
```

```python
def open_epf(path_epf):
    if not exists(path_epf):
        raise Exception('Файл обработки не существует')
    rpa_methods.press('ctrl+o', interval=1)
    keyboard.write(path_epf)
    rpa_methods.press('enter', interval=1)
    img = "attention.png"
    img_yes = "attention_yes.png"

    if rpa_methods.wait_element(img, timeout=5):
        x, y = rpa_methods.get_center(img)
        region = (x, y, 450, 250)  # область в которой искать (left, top, width, height)
        if not rpa_methods.wait_element(img_yes, timeout=5, region=region):
            raise Exception('Ошибка поиска кнопик Да')
        rpa_methods.hower_click(img_yes, region=region)
```

Ради интереса задайте `region = (x, y, 80, 50)` и получите `raise Exception('Ошибка поиска кнопик Да')`

После открытия обработки остается лишь проверить что она и вправду запустилась. Выберем что-то уникальное на форме
обработки, сделаем скриншот и допишем код.

```python
def open_epf(path_epf, img_check=""):
    if not exists(path_epf):
        raise Exception('Файл обработки не существует')
    rpa_methods.press('ctrl+o', interval=1)
    keyboard.write(path_epf)
    rpa_methods.press('enter', interval=1)
    img = "attention.png"
    img_yes = "attention_yes.png"

    if rpa_methods.wait_element(img, timeout=5):
        x, y = rpa_methods.get_center(img)
        region = (x, y, 80, 50)  # область в которой искать (left, top, width, height)
        if not rpa_methods.wait_element(img_yes, timeout=5, region=region):
            raise Exception('Ошибка поиска кнопик Да')
        rpa_methods.hower_click(img_yes, region=region)

    if not img_check == "":
        if not rpa_methods.wait_element(img_check, timeout=5):
            raise Exception('Ошибка открытия обработки')
```

Итак соберем все до кучи

```python
import os
from dotenv import load_dotenv
import keyring
import keyboard
import pyautogui
import rpa_pyautogui_methods as rpa_methods
from os.path import exists

load_dotenv()


def start_1C():
    server_ip = os.getenv('SERVER_IP')
    login = os.getenv('LOGIN')
    base = os.getenv('BASE')
    path_1C = os.getenv('PATH_1C')
    pwd = keyring.get_password("system", login)

    cmd = 'echo \"start\" && \"{path_1C}\" ENTERPRISE /S {server_ip} /IBName "{base}" /N "{login}" /P "{pwd}" && exit'
    command = cmd.format(pwd=pwd, login=login, base=base, path_1C=path_1C, server_ip=server_ip)
    os.system(command)


def activate_1C():
    img = 'info.png'
    name_base = 'Управление торговлей'  # В моем случае база называлась Управление торговлей 11.4
    success = False
    for w in pyautogui.getWindowsWithTitle(name_base):
        # w.maximize()
        w.activate()
        if rpa_methods.wait_element(img, 2):
            rpa_methods.hower_click(img)
            success = True
            print('success')
            break

    if not success:
        raise Exception('Ошибка активации окна 1С')


def open_epf(path_epf, img_check=""):
    if not exists(path_epf):
        raise Exception('Файл обработки не существует')
    rpa_methods.press('ctrl+o', interval=1)
    keyboard.write(path_epf)
    rpa_methods.press('enter', interval=1)
    img = "attention.png"
    img_yes = "attention_yes.png"

    if rpa_methods.wait_element(img, timeout=5):
        x, y = rpa_methods.get_center(img)
        region = (x, y, 80, 50)  # область в которой искать (left, top, width, height)
        if not rpa_methods.wait_element(img_yes, timeout=5, region=region):
            raise Exception('Ошибка поиска кнопик Да')
        rpa_methods.hower_click(img_yes, region=region)

    if not img_check == "":
        if not rpa_methods.wait_element(img_check, timeout=5):
            raise Exception('Ошибка открытия обработки')


if __name__ == '__main__':
    start_1C()
    activate_1C()
    open_epf("D:\\1C\\КонсольЗапросовУФ.epf", "console.png")

```

