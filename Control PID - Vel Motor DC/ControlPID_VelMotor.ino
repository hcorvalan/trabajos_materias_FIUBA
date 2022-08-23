//Controlador PID para velocidad de motor
//hcorvalan
//Codigo diseñado para un Arduino UNO o un Arduino Nano (Atmega328P)

//El siguiente programa captura la cantidad de pulsos provenientes de un encoder que adquiere los datos
//gracias a una rueda con ranuras conectada al eje del motor. Una vez medida la velocidad, la compara con una señal
//de referencia y actúa el controlador PID para estabilizar al motor en esa velocidad.



//Variables para el CONTROLADOR PID
unsigned long UltimoTiempo=0;
double SetPoint;
double errSum, lastErr;
double kp, ki, kd;
int TiempoMuestreo = 1000000; // Seteamos el tiempo de muestreo en 1 segundo.
float Referencia;
long velocidad=1;
float Salida_PID;


//Variables para el MEDIDOR DE VELOCIDAD
volatile unsigned long contador=0;//Cuento los flancos ascendentes.
unsigned long contador_aux=0;//Cuento los flancos ascendentes.
int ppv=20; //Defino la cantidad de ranuras del encoder.


unsigned long t_act=0;
unsigned long t_ant=0;

//INICIO DEL PROGRAMA
void setup() {
  Serial.begin(9600);
  attachInterrupt(0,medicion,RISING); //Defino la interrupción 0, pin 2, para contar flancos ascendentes.
}//Fin del setup()

void loop(){
  //Se definen, los valores de kp,ki, kd y la referencia
  kp=10;
  ki=0.2;
  kd=1;
  Referencia=0; //Valor en RPM
  
  //***********************************************************************************************//
  //Comenzamos midiendo la velocidad
  t_act=micros();
  if(t_act-t_ant>=1000000){ //Cada un segundo, mido la velocidad

   contador_aux=contador; //Utilizo contador_aux para la cuenta, por cambios durante el envío del valor medido
   velocidad = ((60*contador_aux)/ppv);//Calculo la velocidad
   
   contador=0;
   contador_aux=0;//Reinicio los contadores para la próxima medición

  //Realizamos la acción de control
  Salida_PID=PID_function(kp,ki,kd,Referencia,velocidad,t_act);
  PWM_function(Salida_PID);

  }
  Serial.print(velocidad);
  Serial.println("  RPM");
  Serial.print("Acción PID: ");
  Serial.println(Salida_PID);
  Serial.print("ERROR:  ");
  Serial.println(velocidad-Referencia);
  Serial.println("....");

  delay(1000);
  
}//Fin del loop()
//FIN DEL PROGRAMA

//***********************************************************************************************//
//Función que implementa el PID en Arduino.
float PID_function(float kp,float ki,float kd, int SetPoint, long velocidad,unsigned long tiempo_actual){
  
    double error = SetPoint - velocidad;//Calculo el error, entre la referencia y la velocidad medida
    
    errSum += error; //Integro el error
    double dErr = (error - lastErr);//Derivo el error

    float Output = kp * error + ki * errSum + kd * dErr;//Calculo la función de salida del PID.

    //Guardamos el valor de algunas variables para el próximo ciclo de cálculo.
    lastErr = error;
    t_ant = tiempo_actual;
    return Output;    
}
//*****************************************************************************************//
//Función PWM
float PWM_function(Salida_PID){
  Salida_PID = map(Salida_PID, 0, 1024, 0, 255);
  analogWrite(6, Salida_PID);
  Serial.println(Salida_PID);
  
  delay(100);
}


//INTERRUPCIÓN 0, PIN 2
void medicion(){ //Función a la que viene la interrupción
  contador++;   
}


