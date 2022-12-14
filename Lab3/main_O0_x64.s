SerExpanGregoryLeibniz:
        pushq   %rbp  #
        movq    %rsp, %rbp    //как я понял максимальный размер стекового кадра равен 40 так как максимальное значение и при этом rsp остается на месте потому что не вызываются другие функции
        movl    %edi, -36(%rbp) # N, N
        pxor    %xmm0, %xmm0
        movsd   %xmm0, -8(%rbp)     //заносим 0 res
        movsd   .LC1(%rip), %xmm0   //в векторный регистр xmm0 положили 1
        movsd   %xmm0, -16(%rbp)    // занесение на стек 1.0
        movl    $0, -20(%rbp)  //записываем в стек по адресу -24(%rbp) значение 0, то есть i = 0
        jmp     .L2       #
.L3:
        movsd   -16(%rbp), %xmm1      //записываем в xmm1 значение по адресу -16(%rbp). signDef = 1
        movsd   .LC2(%rip), %xmm0   // заносим значение 4.0
        mulsd   %xmm0, %xmm1 //умножение 4.0 * signDef и занносим в xmm1
        pxor    %xmm0, %xmm0    //xmm0 = 0
        cvtsi2sdl       -20(%rbp), %xmm0       //xmm0 = i
        movapd  %xmm0, %xmm2      //то есть xmm0 = i и xmm1 = i
        addsd   %xmm0, %xmm2  //сложение xmm2 = xmm0 + xmm2 = 2 * i
        movsd   .LC1(%rip), %xmm0   //xmm0 = 1.0
        addsd   %xmm0, %xmm2  //xmm2 = xmm0 + xm1(2.0 * (i) + 1.0));
        divsd   %xmm2, %xmm1  //xmm1 / xmm2 = (4.0 * signDef) / (2.0 * (i) + 1.0)
        movapd  %xmm1, %xmm0      //xmm0 += xmm1  сложение текущего результата и предыдущей суммы. На первой итерации 0 + (4.0 * signDef ) / (2.0 * (i) + 1.0)
        movsd   -8(%rbp), %xmm1    ) //помещаем на стек значение суммы
        addsd   %xmm1, %xmm0   //xmm0 += xmm1  сложение текущего результата и предыдущей суммы. На первой итерации 0 + (4.0 * signDef ) / (2.0 * (i) + 1.0)
        movsd   %xmm0, -8(%rbp)   //помещаем на стек значение суммы
        movsd   -16(%rbp), %xmm0 //достали со стека signDef
        movq    .LC3(%rip), %xmm1 //записываем -1
        xorpd   %xmm1, %xmm0  //выполняем (%xmm0) ^= (%xmm1) этим реализуем умножение signDef  *= (-1)
        movsd   %xmm0, -16(%rbp) //заносим в стек переменую signDef
        addl    $1, -20(%rbp)  //реализуем ++i
.L2:
        movl    -20(%rbp), %eax  //достаём переменную i
        cmpl    -36(%rbp), %eax //выполняется сравнение значений, хранящихся по адресам -40(%rbp) и %rax соответственно (N > i)
        jl      .L3 #,
        movsd   -8(%rbp), %xmm0    // достаём res
        movq    %xmm0, %rax     # _13, <retval>
        movq    %rax, %xmm0     # <retval>,
        popq    %rbp  //востанавливаем состояние стека и кадра, которые были до вызова функции
        ret
.LC4:
        .string "%lf"

main:
        pushq   %rbp // записываем старый указатель базы в стек, чтобы сохранить его на будущее
        movq    %rsp, %rbp // копировавние указателя то есть два указтеля сравнялись
        subq    $64, %rsp // размер стекового кадра
        movl    %edi, -52(%rbp) //копирует аргумент  в локальный (смещение -52 байта от значения указателя кадра, хранящегося в edi (Этот регистр в цепочечных операциях содержит текущий адрес элемента в цепочке-источнике (первоначальная строка).)
        movq    %rsi, -64(%rbp) // второй аргумент кладет на стековый кадр
        cmpl    $2, -52(%rbp) // условный оператор
        je      .L6 //команды условного перехода если if не сработал
        movl    $1, %eax //иначе в регистр eax копируется значение 1 и переход по метке L8
        jmp     .L8
.L6:

//Вызов функции atoll
        movq    -64(%rbp), %rax //теперь rax указывает на вершину стека
        addq    $8, %rax
        movq    (%rax), %rax // разыменовываем rax и заносит в rax
        movq    %rax, %rdi
        call    atoll
        movq    %rax, -8(%rbp)
        
//вызываем функции clock_gettime
        leaq    -32(%rbp), %rax
        movq    %rax, %rsi
        movl    $4, %edi
        call    clock_gettime
//rbp база стекового помещается на вершину стека далее помещается адрес возрата затем лежит rsp
//вызываем функции SerExpanGregoryLeibniz
        movq    -8(%rbp), %rax // берём значение со стека и помещаем rax
        movq    %rax, %rdi // затемрегистр регистр rdi первый агумент функции
        call    SerExpanGregoryLeibniz(long long)
        movq    %xmm0, %rax //записываем резульат значения из функции в rax
        movq    %rax, -16(%rbp) // дале помещаем это значение на стек

//вызываем функции clock_gettime
        leaq    -48(%rbp), %rax //со стека достаем знасение и кладем в rax (то есть заполняем сигнатуру)
        movq    %rax, %rsi //передаем в функцию
        movl    $4, %edi //Это количество аргументов, передаваемое ф-ии printf (этот регистр в цепочечных операциях содержит текущий адрес результирующая) строка
        call    clock_gettime

//вызов функции printf
        movq   -16(%rbp), %rax # res, tmp92
        movq    %rax, %xmm0
        movl    $.LC4, %edi //записываем в edi строку "%lf" из .LC6
        movl    $1, %eax
        call    printf
        movl    $0, %eax
.L8:
        leave   // Это эквивалентно movl %ebp, %esp; popl %ebp
// Так мы восстанавливаем состояние стека и кадра, которые были до вызова
        ret
.LC1://1.0
        .long   0
        .long   1072693248
//0 01111111111 00000000000000000000 = (-1)^0*2^(1023-1023)*1,00000000000000000000.. = 1.0
.LC2://4.0
        .long   0
        .long   1074790400
//0 10000000001 00000000000000000000 = (-1)^0*2^(1025-1023)*1,00000000000000000000.. = 4.0
.LC3://-1
        .long   0
        .long   -2147483648
        .long   0
        .long   0
//1 000000000000000000000000000000000000000011111111111 111111111111111111111 = (-1)^1*2(0)*1,0000...0111111111111111111111111111111111100000...000 = -1

//1)как работает функция
//2)метки -LC старшая младшая часть (переводит эти части )
//3)стек в функции
