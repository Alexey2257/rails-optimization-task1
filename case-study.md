# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику: время выполнения программы

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений менее чем за 10 секунд.

Вот как я построил `feedback_loop`: я написал рэйк-таску которая
1. прогоняет тест корректности работы
2. прогоняет тест произовдительности
3. собирает и выводит отчет ruby-prof
4. собирает и выводит отчет stackprof
5. замеряет и выводит метрику -- время выполнения программы на заданном примере

Для начального этапа оптимизации я из исходного файла создал файл размером 10000 строк

Каждую итерацию оптимизации я запускал таску и
- смотрел что прошли тесты корректной работы и производительности
- смотрел, изменились ли основные метрики и поменялась ли точка роста
- если первые два пункта выполнены то обновлял тест производительности и искал новые точки роста

## Вникаем в детали системы, чтобы найти главные точки роста
Для того чтобы измрерить асимптотикой я написал pending тест на производительность с ожиданием линейной сложности, который сообщил мне что текущая сложность O(N^2)
Для того, чтобы найти "точки роста" для оптимизации я воспользовался ruby-prod и stackprof, а также отчетами rubocop-perfomance и fasterer

Вот какие проблемы удалось найти и решить

### Ваша находка №1
- ruby-prof показал что 87% врмени занимает Array#select который встречается в коде единожды: ser_sessions = sessions.select { |session| session['user_id'] == user['id'] }
- для оптимизации я сгруппировал сессии по user_id и заодно вынес код в отдельный метод collect_user_objects 
- метрика изменилась c 1.3с на 0.2с -- рост производительности в 6.5 раз
- согласно отчетам профайлера указанный метод перестал быть основной точкой роста, обновляю спеку и ищу новые точки роста

### Ваша находка №2
- всё тот же ruby-prof показал что Array#all? на данный момент находится в топе потребления, этот метод вызывается для подсчета уникальных браузеров
- так как далее уже есть код который собирает браузеры из сессий -- будем переиспользовать его
- новый рещультат метрики 0.15с вместо 0.2с
- согласно отчетам профайлера указанный метод перестал быть основной точкой роста, обновляю спеку и ищу новые точки роста

### Ваша находка №X
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика - исправленная проблема перестала быть главной точкой роста?

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с *того, что у вас было в начале, до того, что получилось в конце* и уложиться в заданный бюджет.

*Какими ещё результами можете поделиться*

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы *о performance-тестах, которые вы написали*
