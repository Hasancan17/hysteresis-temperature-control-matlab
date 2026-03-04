clc;
clear;
close all;

%% ZAMAN TANIMI
t = 0:0.1:200;   % 0'dan 200 saniyeye kadar

%% SICAKLIK MODELİ
temperature = 27 ...
              + 4*sin(0.05*t) ...
              + 0.7*randn(size(t));

%% HİSTEREZİS EŞİKLERİ
upper_threshold = 30;   % Fan açma eşiği
lower_threshold = 25;   % Fan kapama eşiği

%% BINARY HİSTEREZİS KONTROLÜ
fanState = zeros(size(t));
currentState = 0;

for i = 1:length(t)
    
    if currentState == 0 && temperature(i) >= upper_threshold
        currentState = 1;
    end
    
    if currentState == 1 && temperature(i) <= lower_threshold
        currentState = 0;
    end
    
    fanState(i) = currentState;
end

%% HİSTEREZİSLİ KADEMELİ FAN KONTROLÜ
fanLevel = zeros(size(t));
currentLevel = 0;

for i = 1:length(t)
    
    if currentLevel == 0 && temperature(i) >= upper_threshold
        currentLevel = 1;
    end
    
    if currentLevel == 1 && temperature(i) < upper_threshold && temperature(i) >= lower_threshold
        currentLevel = 0.5;
    end
    
    if currentLevel == 0.5 && temperature(i) <= lower_threshold
        currentLevel = 0;
    end
    
    fanLevel(i) = currentLevel;
    
end

%% HİSTEREZİS OLMAYAN SİSTEM
fan_no_hysteresis = zeros(size(t));

for i = 1:length(t)
    if temperature(i) >= upper_threshold
        fan_no_hysteresis(i) = 1;
    else
        fan_no_hysteresis(i) = 0;
    end
end

%% ANAHTARLAMA SAYILARI
binary_switches = sum(abs(diff(fanState)));
multi_switches = sum(abs(diff(fanLevel)));
no_hys_switches = sum(abs(diff(fan_no_hysteresis)));

disp(['İkili histerezis anahtarlama sayısı: ', num2str(binary_switches)]);
disp(['Kademeli kontrol anahtarlama sayısı: ', num2str(multi_switches)]);
disp(['Histerezis olmayan sistem anahtarlama sayısı: ', num2str(no_hys_switches)]);

%% TEK PANEL ANALİZ GRAFİĞİ

figure;

% 1️⃣ Sıcaklık
subplot(4,1,1)
plot(t, temperature, 'LineWidth', 1.2);
yline(upper_threshold, 'r--', 'Açma Eşiği');
yline(lower_threshold, 'b--', 'Kapama Eşiği');
title('Sıcaklık Değişimi');
ylabel('Sıcaklık (°C)');
grid on;

% 2️⃣ İkili Histerezis
subplot(4,1,2)
plot(t, fanState, 'LineWidth', 1.5);
title('İkili Histerezis Kontrol Çıkışı');
ylabel('Fan Durumu');
ylim([-0.2 1.2]);
grid on;

% 3️⃣ Kademeli Kontrol
subplot(4,1,3)
plot(t, fanLevel, 'LineWidth', 1.5);
title('Kademeli Histerezis Kontrolü');
ylabel('Fan Seviyesi');
ylim([-0.2 1.2]);
grid on;

% 4️⃣ Histerezis Olmayan Sistem
subplot(4,1,4)
plot(t, fan_no_hysteresis, 'LineWidth', 1.5);
title('Histerezis Olmadan Kontrol');
xlabel('Zaman (s)');
ylabel('Fan Durumu');
ylim([-0.2 1.2]);
grid on;

saveas(gcf,'sicaklik_kontrol_analizi.png')
