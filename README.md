# Donteco TestTask
### Task description
Требуется разработать небольшое приложение на Swift по проигрыванию аудиофайлов с кросс-фейдом 
 
Приложение должно содержать 1 экран, на котором будут 4 элемента интерфейса: 
1. Ползунок выбора величины кроссфейда - от 2 с до 10 с 
2. Кнопка выбора аудиофайла №1
3. Кнопка выбора аудиофайла №2
4. Кнопка начала воспроизведения 
 
Воспроизведение заключается в постоянном циклическом проигрывании двух выбранных аудиофайлов 
Первый - потом второй - потом снова первый - и так далее.. 
 
Между ними - кроссфейд, заданный ползунком. Возможность менять величину кроссфейда во время воспроизведения не требуется 
 
Приложение нужно сделать максимально хорошо: 
* Качественный программный код 
* Симпатичный UI 
* Обработка исключений и нестандартных ситуаций 

### Used in app
1. SnapKit and UIKit – interface
2. MediaPlayer and AVFoundation – work with audio
3. Singleton pattern for player manager
