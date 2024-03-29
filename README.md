OKTestWork
==========

Реализация тестового задания. Приложение производит авторизацию, после чего загружает друзей с возможностью страничной дозагрузки оставшихся друзей, размер страницы задается в файле конфигурации.


### Тестовые аккануты

#### Production

Логин: ivanivanovmain  
Пароль: homework

#### Sandbox

Логин: bergusman  
Пароль: bergusman_pwd


### Сторонние библиотеки

Проект использует такие сторонние библиотеки:

* *AFNetworking* — для работы с сетевым соединением,
* *SDWebImage* — библиотека для фоновой загрузки и кэширования изображений.


### CocoaPods

Для разрешения зависимостей и обновления сторонних библиотек используется [CocoaPods](http://cocoapods.org/). Для обновления или загрузки библиотек в корне проекта выполнить:

`pod install`


### Файл конфигурации

Для упрощения конфигурации приложения используется plist-файл. Имя файла указывается в info.plist через ключ `OKConfigName`.

##### Основные ключи:

* *Application ID* — идентификатор приложения,
* *Application Key* — открытй ключ приложения,
* *Application Secret Key* — секретный ключ приложения, для подписи запросов к API,
* *Use Sandbox* — выполнять запросы к API из песочницы,
* *LogIn Server* — адрес сервера, который следует использовать для авторизации,
* *Friends Page Size* — количество друзей для последующей дозагрузки.

**Замечание:** В реальном приложении такие вещи как Application Secret Key не должны находиться в легкодоступном месте, как например в этом конфигурационном файле.