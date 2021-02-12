;*******************************************************************************
    ;Archivo:	  main.s
    ;Dispositivo: PIC16F887
    ;Autor: José Vanegas
    ;Compilador: pic-as (v2.30), MPLABX V5.40
    ;
    ;Programa: Contadores en los puertos A, C, D
    ;Hardware: LEDs en los puertos A,C,D 
    ;
    ;Creado: 9 feb, 2021
    ;Última modificación: 9 feb, 2021    
;*******************************************************************************

    PROCESSOR 16F887
    #include <xc.inc>
    
    ;configuration word 1
    CONFIG FOSC=EXTRC_NOCLKOUT //Oscillador externo
    CONFIG WDTE=OFF	//WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=ON	//PWRT enabled (espera de 72ms al iniciar)
    CONFIG MCLRE=OFF	//El pin de MCLR se utiliza como I/O
    CONFIG CP=OFF	//Sin protecci[on de codigo
    CONFIG CPD=OFF	//Sin proteccion de datos

    CONFIG BOREN=OFF	//Sin reinicio cuando el voltaje de alimentacion baja 4v
    CONFIG IESO=OFF	//Reinicio sin cambio de reloj de interno a externo
    CONFIG FCMEN=OFF	//Cambio de reloj externo a interno en caso de fallo
    CONFIG LVP=ON	//programacion en bajo voltaje permitida
    
;configuration word 2
    CONFIG WRT=OFF	//Proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V //Reinicio abajo de 4V, (BOR21v=2.1v)

    PSECT resVect, class=CODE, abs, delta=2
;Configuracion de puertos
    BSF STATUS, 6 ;Banco 3
    BSF STATUS, 5 ;Banco 3
    CLRF ANSEL
    CLRF ANSELH
    
    BCF STATUS, 6 ;Banco 1
    CLRF TRISA	  ;Puerto A como Salida
    CLRF TRISC	  ;Puerto C como salida   
    CLRF TRISD	  ;Puerto D como salida
    
    MOVLW 255
    MOVWF TRISB ;Configurar puerto B como entrada
    
    BCF OPTION_REG, 7 ;Pull up del puerto B
    
    BCF STATUS, 5; Banco 0
    
    CLRF PORTA ;Poner en 0 el puerto
    CLRF PORTC ;Poner en 0 el puerto
    CLRF PORTD ;Poner en 0 el puerto
;******************************************************************************
;Loop General
 LOOP:
    BTFSS PORTB, 0 ;Boton incremento contador 1
    CALL INCREMENTOA
    BTFSS PORTB, 1 ;Boton decremento contador 1
    CALL DECREMENTOA
    BTFSS PORTB, 2 ;Boton incremento contador 2
    CALL INCREMENTOC
    BTFSS PORTB, 3 ;Boton decremento contador 2
    CALL DECREMENTOC
    BTFSS PORTB, 4 ;Boton Aplicar Suma
    CALL SUMA
    GOTO LOOP
;******************************************************************************    
;Subrutina contador 1
 INCREMENTOA:
    BTFSS PORTB, 0 ;Si se deja de presionar el boton incrementa contador 1
    GOTO $-1
    INCF PORTA, F
    BTFSC PORTA, 4 ;Instruccion para no sobrepasar los 4 bits encendidos
    DECF PORTA, F
    RETURN
    
 DECREMENTOA:
    BTFSS PORTB, 1 ;Si se deja de presionar el boton decrementa el contador 1
    GOTO $-1
    DECF PORTA, F ;decrementa puerto A
    INCFSZ PORTA, F ;Incrementa puerto A, si valor de F es 1
    DECF PORTA,F ;Decrementa puerto A y guarda valor en F
    RETURN
 ;*****************************************************************************
 ;Subrutina contador 2
 ;Mismo codigo que el contador 1
 INCREMENTOC:
    BTFSS PORTB, 2
    GOTO $-1
    INCF PORTC, F
    BTFSC PORTC, 4 
    DECF PORTC, F
    RETURN
    
 DECREMENTOC:
    BTFSS PORTB, 3
    GOTO $-1
    DECF PORTC, F
    INCFSZ PORTC, F
    DECF PORTC,F
    RETURN
;******************************************************************************
;Subrutina contador de suma
 SUMA:
    MOVF PORTA, W   ;Mueve valor de puerto A a W
    ADDWF PORTC, W  ;Suma Valor W a Puerto C y lo guarda en W
    MOVWF PORTD	    ;Mueve valor de W al puerto D
    RETURN
    
    END
    