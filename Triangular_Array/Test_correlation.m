%
% Este programa calcula el angulo de arribo (DOA)
% para cada par de microfonos del arreglo triangular
% utilizando GCC o GCC-PHAT.
%
% N = 1024 (Tamaño de ventana ~21ms)
% t = 4s (Duracion de las grabaciones a emplear)
%

clc;
clear;

PHAT = false

Fs = 48000; %frecuencia de muestreo
N = 1024; %tamaño de la ventana
N2 = floor(N/2);
c = 340; %velocidad del sonido
d = 0.18; %distancia entre microfonos

AUDIO_SOURCE = "clean-1source"
AUDIO_PATH = (["corpus",num2str(Fs),"/",AUDIO_SOURCE]);

% Lectura de los microfonos
s1 = wavread([AUDIO_PATH,'/wav_mic1.wav']); 
s2 = wavread([AUDIO_PATH,'/wav_mic2.wav']); 
s3 = wavread([AUDIO_PATH,'/wav_mic3.wav']); 

L = length(s1);
m = 1; %contador de frames
t = 4;

for l=1:N:t*Fs
    
    % Frames para trabajar
    x1 = s1(l:l+N-1);
    x2 = s2(l:l+N-1);
    x3 = s3(l:l+N-1);
    
    if VAD(x1,Fs)
        % FFT
        xw1 = fft(x1);
        xw2 = fft(x2);
        xw3 = fft(x3);
        
        % correlaciones
        rw12 = conj(xw1).*xw2;
        rw23 = conj(xw2).*xw3;
        rw31 = conj(xw3).*xw1;
        
        % GCC-PHAT(W)
        if PHAT
            rw12 = rw12./abs(rw12);
            rw23 = rw23./abs(rw23);
            rw31 = rw31./abs(rw31);
        end
        
        % GCC (se toma la parte real para evitar problemas de precision numerica)
        r12 = real(fftshift(ifft(rw12)));
        r23 = real(fftshift(ifft(rw23)));
        r31 = real(fftshift(ifft(rw31)));
        
        % Obtencion de los retrasos(en muestras)
        [~, Tau12] = max(r12);
        [~, Tau23] = max(r23);
        [~, Tau31] = max(r31);
        
        Tau12 = Tau12-N2;
        Tau23 = Tau23-N2;
        Tau31 = Tau31-N2;
        
        DOA12(m) = real(asind((Tau12/Fs)*c/d));
        %DOA12(m) = (DOA12(m)<180) * DOA12(m) + (DOA12(m)>=180) *180;
        %DOA12(m) = (DOA12(m)>0) * DOA12(m) + (DOA12(m)<=0) *0;
        
        DOA23(m) = real(asind((Tau23/Fs)*c/d));
        %DOA23(m) = (DOA23(m)<180) * DOA23(m) + (DOA23(m)>180) *180;
        %OA23(m) = (DOA23(m)>0) * DOA23(m) + (DOA23(m)<=0) *0;
        
        DOA31(m) = real(asind((Tau31/Fs)*c/d));
        %DOA31(m) = (DOA31(m)<180) * DOA31(m) + (DOA31(m)>180) *180;
        %DOA31(m) = (DOA31(m)>0) * DOA31(m) + (DOA31(m)<=0) *0;
        
        m++;
    
    end % if VAD(x1,Fs)
    
end %end for l=1:N:L

doa12 = mean(DOA12)
doa23 = mean(DOA23)
doa31 = mean(DOA31)