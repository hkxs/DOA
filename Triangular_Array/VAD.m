%------------------------------------------------
% Funcion para deteccion de actividad de voz
% basado en el algoritmo propuesto por Moattar
% en el articulo:
% A simple but efficient real-time voice 
% activity detection algorithm. EUSIPCO 2009
%
% Entradas:
%  x:     Señal a analizar
%  Fs:    Frecuencia de muestreo
%
% Salidas:
%  voice: Indica si existe señal de voz
%           voice = 0 <- No hay señal
%           voice = 1 <- Hay señal
%  
%
%------------------------------------------------


function [voice] = VAD(x, Fs)
    
    N = size(x);     %tamaño de la ventana
    N2 = round(N/2); %mitad de la ventana
    
    persistent silence_count = 0;
    
    persistent E_th = 4;%1;    %umbral de energia
    F_th = 300;%100;               %umbral de frecuencia
    K_th = floor(F_th*N/Fs);  %umbral de frecuencia (convertido a muestras)
    SF_th = 2;%200;                %umbral de SFM

    persistent E_min = 1;  
    K_min = 1;
    SF_min = 1;

    xw = fft(x);  
    
    E = dot(x,x);          %energia del segmento actual

    xm = abs(xw(1:N2+1));  %magnitud del espectro
    
    Gm = mean(xm,'g');     %media geometrica
    Am = mean(xm,'a');     %media aritmetica
    
    SF = 10*log10(Gm/Am);  %Spectral Flatness Measure
    
    [aux K] = max(xm);     %maxima frecuencia (en muestras)
    
    if( (E-E_min) >= E_th )
        voice = 1;

    elseif ( (K-K_min) >= K_th  )
        voice = 1;

    elseif ( (SF-SF_min) >= SF_th  )
        voice = 1;
    else
        voice = 0;
        silence_count++;
        
        E_min = (silence_count*E_min+E)/(silence_count+1);
        E_th = E_th*E_min;
    end
    
   
end %fin de la funcion