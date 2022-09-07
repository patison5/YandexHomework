# YandexHomework
Выполненные домашние работы школы мобильной разработки Yandex 

- [x] **Swift как язык программирования**
- [x] **UIView и Сложные представления**
- [x] **Слой вью-контроллеров - UIViewController**
- [x] **IDE Toolchain Cocoapods**
- [x] **Concurrency**
- [x] **Networking**
- [x] **Persistence**

<p align="center">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/1.png?raw=true" alt="Demo 1" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/2.png?raw=true" alt="Demo 2" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/3.png?raw=true" alt="Demo 3" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/4.png?raw=true" alt="Demo 4" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/5.png?raw=true" alt="Demo 5" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/6.png?raw=true" alt="Demo 6" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/7.png?raw=true" alt="Demo 7" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/8.png?raw=true" alt="Demo 8" width="30%">
  <img src="https://github.com/patison5/YandexHomework/blob/main/readme/g1.gif?raw=true" alt="Demo gif" width="30%">
</p>

<hr/>

### **Swift как язык программирования**
>#### Требования
>- Реализовать структуру TodoItem
>- Реализовать расширение TodoItem для разбора json 
>- Реализовать класс FileCache
>- Реализовать сохранение и загрузку FileCache в файл и из файла
>- Предусмотреть механизм защиты от дублирования задач (сравниванием id)
>#### Задание со звездочкой
>- Написать тесты для дз

[Файлы из домашки (Commit)](https://github.com/patison5/YandexHomework/commit/ff3d79200b9de97b95efc99e243173ee2fac750e)

<hr/>

### **UIView и Сложные представления**
>#### Требования
>- Сделать верстку экрана деталей TODO листа согласно макетам
>- Привязать экран к модели TodoItem из предыдущего задания
>- По умолчанию при включении дедлайна ставится следующий день (если сегодня 10 июня, дедлайн поставится 11 июня)
>- Календарь для изменения дедлайна появляется при нажатии на дату.
>- Экран должен быть закреплен в вертикальной ориентации
>#### Задание со звездочкой
>- Текстовое поле содержания дела расширятся и включает в себя весь набранный текст (расширяя общую высоту экрана)
>- Сделать обработку появления клавиатуры, клавиатура не должна закрывать собой контент
>- Сделать горизонтальную ориентацию. Верстка должна смотреться аккуратно, это вы определяете на свой вкус
>- Реализовать тёмную тему
>- сделать раскрытие/скрытие календаря анимированным

[Файлы из домашки (Commit)](https://github.com/patison5/YandexHomework/commit/5e6479c57624d0da2dd6704af6a7abfcc87f552d)

<hr/>

### **Слой вью-контроллеров - UIViewController**
>#### Требования
>- сделать экран со списком заметок
>- обработка показа/скрытия клавиатуры (фрейм клавиатуры может быть нестандартным)
>- обработка поворотов (в том числе с активной клавиатурой)
>- добавить навигацию между экранами с использованием механизма modal presentation
>- экран редактирования должен быть достаточно универсальным, чтобы обрабатывать как создание новых заметок, так и редактирование существующих
>- поддержать повороты экрана на редактировании записи в landscape поле ввода должно занимать весь экран, остальные контролы нужно прятать
>#### Задание со звездочкой
>- custom transition на экран редактирования
>- анимировать появление именно из той ячейки table view, с которой взаимодействовал пользователь
>- поддержать механизм preview

[Файлы из домашки (Commit)](https://github.com/patison5/YandexHomework/commit/67eb5ddd01abe37a636a573037c2ef1258ec91ec)

<hr/>

### **IDE Toolchain Cocoapods**
>#### Требования
>- Добавить в проект CocoaPods
>- /Pods - исключена из гитового индекса
>- Подключить CocoaLumberjack через CocoaPods
>- Настроить и использовать логер
>- Подключить SwiftLint через CocoaPods
>- Настроить запуск swiftlint при сборке
>#### Задание со звездочкой
>- Вынести часть кода в Development Pod, использовать вынесенный код в основном таргет
>- Вынести ресурсы в Development Pod, использовать вынесенные ресурсы

[Файлы из домашки (Commit)](https://github.com/patison5/YandexHomework/commit/14e43dbbd14d6b59848f9b036cdfbff883ba9264)

Реализованная в рамках домашней работы дизайн система приложения: [**Design system**](https://github.com/patison5/DesignSystem)

Установить в проект можно указав следующую строку в pod файле и выполнив конанду **pod install**

```ruby
pod 'DesignSystem'
```

<hr/>

### **Concurrency**
>#### Требования
>- Реализовать сетевой слой
>- Использовать локальное хранилище
>- Убрать ненужную работу с главного потока
>#### Задание со звездочкой
>- Реализовать с использованием Swift concurrency

[Файлы из домашки (Commit)](https://github.com/patison5/YandexHomework/commit/f0577fa2451dbe87f6513080301a8266db83601c)

<hr/>

### **Networking**
>#### Требования
>- реализовать NetworkingService
>- реализовать 5 ручек API
>- реализовать логику обращения к API
>- Все вызовы и сериализация/десериализация должны быть НЕ на главном потоке
>#### Задание со звездочкой
>- Экспоненциальный retry и индикатор сетевых запросов в UI
>- Реализовать авторизацию через OAuth (Яндекс Паспорт)

[Файлы из домашки (Commit)](https://github.com/patison5/YandexHomework/commit/1b4313d45cc0208915dce1f4a4e70c8e01ffdaeb)

<hr/>

### **Persistence**
>#### Требования
>- У FileCache  есть методы save() /load() , необходимо заменить в них сериализацию/десериализацию и запись в файл на запись и чтение из базы SQLite.
>#### Задание со звездочкой
>- Заменить save()  на единичные запросы (как в network) - insert/update/delete , которые работают по одному элементу, load()  оставить как есть.
>#### Задание с двумя звездочками
>- Сделать все вышеперечисленное на Core Data.

[Файлы из домашки (Commit)](https://github.com/patison5/YandexHomework/pull/9)
