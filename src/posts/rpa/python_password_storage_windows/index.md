---
title: Хранение паролей в Windows и доступ к ним в Python
---

Для безопасного хранения паролей в Windows использую Windows Credential Locker.

Покажу на примере:

## Добавляем пароль

Зайдем в панель управления `Пуск -> Панель управления или`

```bash
win + r
```

Набираем `control` и нажимаем `ok`

![cmd](./cmd.png)

И переходим в `Учетные данные пользователей`

![cmd](./users_1.png)

Далее `Администрирование учетных данных`

![cmd](./users_2.png)

И кликаем на `Добавить общие учетные данные`

![cmd](./users_3.png)

Заполняем поля

![cmd](./users_4.png)

## Получаем пароль в скрипте python

```python
login = "Pupkin"
pwd = keyring.get_password("may_may", login)
```

Если пароль не найден вернет `None`

О том, зачем мне это понадобилось в [статье](/posts/rpa/1С_schedule_start_stop_run_epf)
