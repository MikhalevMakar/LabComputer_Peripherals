SerExpanGregoryLeibniz:
        subl    $12, %esp       #,
        movl    16(%esp), %edx  # N, N
        testl   %edx, %edx    # N
        jle     .L4       #,
        fld1
        xorl    %eax, %eax      # i
        fldz
        jmp     .L3       #
.L8:
        fxch    %st(1)      #
.L3:
        movl    %eax, 4(%esp)   # i, %sfp
        fld     %st(1)    #
        fmuls   .LC2  #
        addl    $1, %eax        #, i
        fildl   4(%esp)       # %sfp
        fadd    %st(0), %st     #,
        fadds   .LC0  #
        fdivrp  %st, %st(1) #,
        faddp   %st, %st(1)   #,
        fxch    %st(1)      #
        fchs
        cmpl    %eax, %edx      # i, N
        jne     .L8       #,
        fstp    %st(0)      #
        addl    $12, %esp       #,
        ret
.L4:
        fldz
        addl    $12, %esp
        ret
.LC4:
        .string "%lf"
main:
        leal    4(%esp), %ecx//помещает адрес нулевого аргумента, переданного основной функции, в регистр ecx
        andl    $-16, %esp // выравнивание
        movl    $1, %eax // ret value
        pushl   -4(%ecx) //сохранили в стеке адрес возврата

        pushl   %ebp  //начинает формироваться стековый кадр, путем помещения регистра ebp на вершину стека
        movl    %esp, %ebp //выравниваем уквзвтели
        pushl   %ecx  //добавили argc на стек
        subl    $20, %esp  //размер стекового кадра
        
        cmpl    $2, (%ecx) //сравнили argc и 2
        movl    4(%ecx), %edx  //argv, argv теперь в edx = argv
        je      .L18
.L9:
        movl    -4(%ebp), %ecx //адресс возврата помещаем в ecx
        leave //восстанавливаем указатели стека и кадра (esp и ebp)
        leal    -4(%ecx), %esp //возвращает stack pointer к состоянию до выравнивания по 16-байтам
        ret //Команда RET читает из стека адрес возврата и заносит его в регистр IP, передавая таким образом управление
.L18:
        pushl   %eax //добавили 1 на стек
        pushl   $10 //добавили в стек 10
        pushl   $0 //добавили в стек 0
        pushl   4(%edx) //MEM[(char * *)argv_5(D) + 4B] добавили в стек argv[argc]
        call    strtol

        addl    $16, %esp  //увеличили стековый кадр
        fldz //загрузить константу +0.0
        testl   %eax, %eax //команда TEST выполняет логическое И между всеми битами двух операндов. Результат никуда не записывается, команда влияет только на флаги    
        jle     .L11
        xorl    %edx, %edx //занулили edx то есть i = 0
        fld1 //занесли константу 1.0 на стек сопроцессора signDef
.L12:
        movl    %edx, -12(%ebp) //добавили i  в стек
        fld     %st(0) //добавлили в стек то что лежит на стеке сопроцессора то есть 1
        fmuls   .LC2  //умножили 4.0*signDef
        addl    $1, %edx //добавили i++
        fildl   -12(%ebp) //добавили i в стек сопроцессора
        fadd    %st(0), %st //сложили i+i
        fadds   .LC0 //добавили 1 то есть 2*i+1.0
        fdivrp  %st, %st(1) //поделили
        faddp   %st, %st(2) //и прибавили в res
        fchs //signDef поменял знак
        cmpl    %edx, %eax //сравнение i и N
        jne     .L12 //переход на метку .L12, если i < N
        fstp    %st(0) //иначе сохранить вещественное значение с извлечением из стека
.L11:
        subl    $12, %esp //увеличели стековый кадр
        fstpl   (%esp) //сохранить вещественное значение с извлечением из стека
        pushl   $.LC4 // добавили в стек строковый литерал: "%lf"
        call    printf
        addl    $16, %esp // esp += 16
        xorl    %eax, %eax //<retval> eax = 0
        jmp     .L9 //переходим по метке .L9 и выходим из программы
.LC0:
        .long   1065353216
//0 01111111 00000000000000000000000 = (-1)^0 * 2^(127-127) * 1.0000000000000000000000 = 1.0

.LC2:
        .long   1082130432 // 4.0
//0 10000001 00000000000000000000000 = (-1)^0 * 2^(129 - 127) * 1.00000000000000000000000 = 4.0

//Эффективный адресс как формируется:
//это БАЗА + СМЕЩЕНИЕ + ИНДЕКС
//где БАЗА - это базовый адрес
//СМЕЩЕНИЕ - это константа, заданная в команде;
//ИНДЕКС - значение индексного регистра

//andl  $-16, %esp
//%esp немного изменен, так что он становится кратным 16. Для некоторых типов данных (формат с плавающей запятой, соответствующий double и long double в C) производительность выше, когда доступ к памяти осуществляется по адресам, кратным 16.
//которая выравнивает указатель стека вверх (нижний адрес) до ближайшего адреса, который можно разделить на 16 (-16 == 0xfffffff0)
