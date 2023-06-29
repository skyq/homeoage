---
title: Запуск 1С по расписанию и вызов обработки
---

[git](git@github.com:skyq/schedule_1C_epf.git)

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

if __name__ == '__main__':
    server_ip = os.getenv('SERVER_IP')
    login = os.getenv('LOGIN')
    base = os.getenv('BASE')
    path_1C = os.getenv('PATH_1C')
    pwd = keyring.get_password("system", login)

    cmd = 'echo \"start\" && \"{path_1C}\" ENTERPRISE /S {server_ip} /IBName "{base}" /N "{login}" /P "{pwd}" && exit'
    command = cmd.format(pwd=pwd, login=login, base=base, path_1C=path_1C, server_ip=server_ip)
    os.system(command)
```

Как видно server_ip, login и прочие переменные, которые мы вынесли в `.env`, доступны через команду `os.getenv({KEY})`

## PyAutoGUI
Следующим шагом будет вызов обработки и тут нам поможет замечательная библиотека [PyAutoGUI](https://pyautogui.readthedocs.io/en/latest/install.html).
Установим ее `pip install pyautogui`. 

```comment
Пару слов о билиотеке - она может находить на экране кнопки, текст и прочее по изображению, двигать мышкой, вводить текст, делать скриншоты экрана. Это если коротко.
```

Допустим обработка у нас лежит в «Справочнике -> Внешние обработки» и мы знаем Код этой обработки в 1С.
Шаг первый - активировать окно 1С. Тут есть несколько вариантов, нужно пробовать - некоторые у меня не работали.

Первый способ - найдем изображение кнопки информации 1С
![кнопка информации 1С](./info.png)

Для лаконичности кода методы для работы с PyAutoGUI я вынес в [отдельную статью](./posts/rpa/pyautogui_methods/)

```python
import pyautogui

def activate_1C():
    
```


