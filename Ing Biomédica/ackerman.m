clear all
close all
clc

%% Definimos los par�metros del modelo, ya hallados en el paper.

p1=2.73281E-2;
p2=6.60192E-2;
p3=5.64145E-1;
p4=1.34963E-1;
Gb=3.88734E2;
Ib=7.64246E2;


%Genero un tren de pulsos
    dur = 10; %Cuanto dura (en segundos).
    per = 0.25; %Cuantas veces dentro de (dur) se repite. (Ej: 0.25 es 1/4, se repite 4 vees).
    duty = 10; %Duty cicle de cada pulso. (En %).
    puntos = 10000; %Cantidad de puntos
    atenuacion = 0.01; %N�mero entre 0 y 1 para escalar el escal�n.
    t=0:dur/puntos:dur-dur/puntos;
    ton=ones(1,floor(puntos/(length(dur)/(per*(duty/100)))))*atenuacion;
    toff=zeros(1,ceil(puntos/(length(dur)/(per*((100-duty)/100)))));
    normal=[ton,toff];
    y=repmat(normal,1,(length(dur)/per));%Ac� en (y) est� el tren de pulsos
    %Est�s dos lineas que siguen es para que siempre coincida el largo de
    %ambos vectores. Este generador de pulsos lo saqu� de internet y a
    %veces fallaba si pon�a muchos per�odos.
    size_T = size(t);
    y = y(1:size_T(1,2));
    %plot(t,y);  
    
    %Genero un solo escal�n
    dur = 6;
    t=0:dur/puntos:dur-dur/puntos;
    size_T = size(t);
    duracion = 0.1; %Porcentaje del largo del escal�n en duraci�n.
    largo = size_T(1,2)*duracion;
    t_on1 = ones(1,largo)*atenuacion;
    t_off1 = zeros(1,(size_T(1,2)-largo));
    escalon = [t_on1,t_off1];
    
    
%% Definimos las matrices del sistema
A=[-p1 -p2; p4 -p3];
B=[1;0];    %Tren de pulsos de Glucosa
C=[1 0; 0 1]; %Si la matriz C es una identidad, se puede ver cada variable de estado por separado.
%El modelo no especifica una salida determinada.
D=0;

%Defino el sistema.
sys = ss(A,B,C,D);
%El comando LSIM es para simular la respuesta del sistema sys a una entrada
%determinada. Ac� es la (y) del tren de pulsos.

figure; hold on;
lsim(sys,y,t);
title('Modelo de Ackerman para la Glucosa e Insulina frente a impulsos de glucosa');
hold off;

B = [0;1]; %Tren de pulsos de insulina
sys = ss(A,B,C,D);
figure; hold on;
lsim(sys,y,t);
title('Modelo de Ackerman para la Glucosa e Insulina frente a impulsos de insulina');
hold off;


%% Ahora intentemos simular un paciente diab�tico.
%El diab�tico tipo 1 es incapaz de producir insulina.
%Por ende no deber�a haber ninguna respuesta de la insulina frente 
%un aumento de la glucosa.
%Por ende, la variable en la Matriz A de la ecuaci�n de insulina que la
%relaciona con la glucosa debe ser 0. Por ende, p4 = 0.
%Si la entrada es solo un escal�n de glucosa B=[1;0] no deber�a afectar a
%la insulina.

%Defino un nuevo sistema:
p4_dia1 = 0;
A1=[-p1 -p2; p4_dia1 -p3];
B1 = [1;0];
sys_dia1 = ss(A1,B1,C,D);
%Usamos la misma entrada.

figure; hold on;
lsim(sys_dia1,y,t);
title('Glucosa e Insulina en un paciente Diab�tico Tipo I');
hold off;

%% Ahora pensamos en un diab�tico de tipo 2.
%El diab�tico de tipo 2 si produce insulina, pero esta no sirve para que la
%c�lula pueda absorber la glucosa.
%Por ende, en la ecuaci�n de la glucosa, la constante que la relaciona con
%la insulina debe ser peque�a. No cero ya que hay una reabsorci�n, pero
%peque�a comparado al valor basal del modelo. Este valor es p2.

%Por otro lado, el valor p1 se encarga de la autoregulaci�n de la glucosa.
%Esta variable tambi�n deber�a ser bastante m�s peque�a, pero no tanto m�s
%que la atenuaci�n de p2.

%Definimos un nuevo sistema.
diabetes2 = 0.001;%Diabetes2 es una constante para medir el porcentaje
%de absorci�n de glucosa del paciente. 
p2_dia2 = p2*diabetes2; 
p1_dia2 = p1*0.05; %Constante al azar, quedaba linda.
A2=[-p1_dia2 -p2_dia2; p4 -p3];
B2=[1;1]; %B es [1;1] para mostrar la regulaci�n lenta de la diabetes tipo 2.
sys_dia2 = ss(A2,B2,C,D);

figure; hold on;
lsim(sys_dia2,escalon,t);
title('Glucosa e Insulina en un paciente Diab�tico Tipo II');
hold off;





