clc;
clear;

N=10000; %ile razy powtarzam scenariusz
n=100; %ile obserwacji w pojedynczym scenariuszu

R2_0=zeros(N, 1); %zapisuje wartosci R^2 dla pierwszego scenariusza
R2_1=zeros(N, 1); %zapisuje wartosci R^2 dla drugiego scenariusza
tstat_0=zeros(N, 1);  %zapisuje wartosci statystyki t dla pierwszego scenariusza
tstat_1=zeros(N, 1);  %zapisuje wartosci statystyki t dla drugiego scenariusza
%% Dwa scenariusze - nonstationary random walk I(1) and white noise I(0)
for i=1:N
    x_I1 = zeros(n, 1); %wartosci xt
    x_I0 = zeros(n, 1);
    y_I1 = zeros(n, 1); %wartosci yt
    y_I0 = zeros(n, 1);
    for j=2:n
        eps_x = randn(n, 1); %skladnik losowy dla x
        eps_y = randn(n, 1); %skladnik losowy dla y

        x_I1(j) = x_I1(j-1)+eps_x(j-1); %x(t)=x(t-1)+eps_x(t)
        y_I1(j) = y_I1(j-1)+eps_y(j-1); %y(t)=y(t-1)+eps_y

        x_I0(j) = eps_x(j); %x(t)=eps_x(t)
        y_I0(j) = eps_y(j); %y(t)=eps_y(t)
    end
    x_I1 = [ones(n,1) x_I1]; %regresor z wyrazem wolnym
    x_I0 = [ones(n,1) x_I0];
    [R2_I1, tstat_I1] = my_regress(y_I1, x_I1); %recznie zbudowana funkcja na dole skryptu
    [R2_I0, tstat_I0] = my_regress(y_I0, x_I0);
    R2_1(i) = R2_I1; %za kazdym razem zapisuje wymagane wartosci
    tstat_1(i) = tstat_I1(2); 
    R2_0(i) = R2_I0;
    tstat_0(i) = tstat_I0(2); 
end
%% Wykresy
%Fischer-Snedecor F distribution if X~Beta((k-1)/2, (n-k)/2)
alpha=(size(x_I1,2)-1)/2; %(k-1)/2
beta=(n-size(x_I1,2))/2;  %(n-k)/2
ni=n-1; %liczba stopni swobody
x_g = linspace(0, 1, N);
x_t = linspace(-15, 15, N); 
f_g=x_g.^(alpha-1).*(1-x_g).^(beta-1)/((gamma(alpha)*gamma(beta))/gamma(alpha+beta)); %funkcja gestosci beta-rozkladu (dokumentacja)
f_t=(gamma((ni+1)/2))/(sqrt(ni*pi)*gamma(ni/2))*(1+(x_t.^2)/ni).^(-(ni+1)/2); %funkcja gestosci rozkladu t-studenta

subplot(2, 2, 1); %R^2 - I(1)
histogram(R2_1, 30, 'Normalization','pdf'); %dokumentacja - v(i)=c(i)/N*w(i)
%albo znormalizowac histogram recznie - Meeting II, s.37
%[f, xout] = hist(R2_1, 30);
%dx = diff(xout(1:2));
%bar(xout, f/sum(f*dx)); 
hold on;
plot(x_g, f_g, 'LineWidth', 2, 'Color','red');
xlabel('R squared'); 
ylabel('Density');
axis([0 1 0 65]); %zgodnie z podanym wzorem
legend({'histogram density estimate', 'density of \beta distribution (\alpha=0.5 and \beta=49)'});
title({'Histogram density estimate of R^2', 'from regressing one independent random-walk I(1) variable', 'on another one I(1).'});
hold off;

subplot(2, 2, 2); %statystyka t - I(1)
histogram(tstat_1, 30, 'Normalization','pdf'); %jw.
hold on;
plot(x_t, f_t, 'LineWidth', 2, 'Color','red');
xlabel('t-statistics'); 
ylabel('Density');
axis([-15 15 0 0.4]); %zgodnie z podanym wzorem
legend({'histogram density estimate', 'density of t-distribution'});
title({'Histogram density estimate for t-ratios', 'from regressing one independent random-walk I(1) variable', 'on another one I(1).'});
hold off;

subplot(2, 2, 3); %R^2 - I(0)
histogram(R2_0, 30, 'Normalization','pdf'); %jw.
hold on;
plot(x_g, f_g, 'LineWidth', 2, 'Color','red');
xlabel('R squared'); 
ylabel('Density');
axis([0 1 0 50]); %zgodnie z podanym wzorem
legend({'histogram density estimate', 'density of \beta distribution (\alpha=0.5 and \beta=49)'});
title({'Histogram density estimate of R^2', 'from regressing one independent random-walk I(0) variable', 'on another one I(0).'});
hold off;

subplot(2, 2, 4); %statystyka t - I(0)
histogram(tstat_0, 30, 'Normalization','pdf'); %jw
hold on;
plot(x_t, f_t, 'LineWidth', 2, 'Color','red');
xlabel('t-statistics'); 
ylabel('Density');
axis([-15 15 0 0.4]); %zgodnie z podanym wzorem
legend({'histogram density estimate', 'density of t-distribution'});
title({'Histogram density estimate for t-ratios', 'from regressing one independent random-walk I(0) variable', 'on another one I(0).'});
hold off;

%% Wyniki 
alphaup = 1-0.05/2; %obliczenia dla wartosci krytycznej 
alphalow = 0.05/2;
upp = tinv(alphaup,ni);
low = tinv(alphalow,ni);

perc_rej_I0 = length(tstat_0(abs(tstat_0)>upp)) / N * 100; %procentowy udzial odrzucen H0 dla stacjonarnego procesu
perc_rej_I1 = length(tstat_1(abs(tstat_1)>upp)) / N * 100; %procentowy udzial odrzucen H0 dla niestacjonarnego procesu

freq_R2_05_I0 = length(R2_0(R2_0>0.5)) / N * 100; %relatywna czestosc R^2>0.5 dla stacjonarnego procesu
freq_R2_05_I1 = length(R2_1(R2_1>0.5)) / N * 100; %relatywna czestosc R^2>0.5 dla niestacjonarnego procesu
freq_R2_075_I0 = length(R2_0(R2_0>0.75)) / N * 100; %relatywna czestosc R^2>0.75 dla stacjonarnego procesu
freq_R2_075_I1 = length(R2_1(R2_1>0.75)) / N * 100; %relatywna czestosc R^2>0.75 dla niestacjonarnego procesu
disp('Monte Carlo simulation with 2 scenarios: nonstationary I(1) and stationary I(0)'); %wyswietlanie wynikow
disp('--------------------------------------------------------------------------------------------------------------');
disp('                                                                                    random walk    white noise');
disp('--------------------------------------------------------------------------------------------------------------');
fprintf('%30s %7.2f %7.2f \n', 'How often does the t-test reject the H0 of nonsignificant impact with alpha = 0.05? (%)', perc_rej_I1, perc_rej_I0);
fprintf('%30s %7.2f %7.2f \n', 'How often is R^2 larger than 0.5? (%)                                                  ', freq_R2_05_I1, freq_R2_05_I0);
fprintf('%30s %7.2f %7.2f \n', 'How often is R^2 larger than 0.75? (%)                                                 ', freq_R2_075_I1, freq_R2_075_I0);

%% Funkcja obliczajaca R-kwadrat i statystyke t
function [R2, tstat] = my_regress(Y, X)
beta_OLS = inv(X'*X) * (X' * Y); %oszacowania MNK
y_hat = X*beta_OLS; %teoretyczne wartosci y
e_hat = Y-y_hat; %reszty z modelu
SSE = (e_hat)'*(e_hat); %suma kwadratow reszt (SSE)
%SST = (Y-mean(Y))'*(Y-mean(Y)); %laczna wariancja 
SSR = (y_hat-mean(Y))'*(y_hat-mean(Y)); %zmiennosc wartosci teoretycznych
R2 = SSR/(SSR+SSE);
variance_error=SSE/(size(Y,1)-size(X,2)); %size(Y, 1) - liczba wierszy=n; size(X, 2) - liczba zmiennych=k+1
standard_errors=diag((variance_error*inv(X'*X))).^(0.5); %bledy szacunku
tstat=beta_OLS./standard_errors; %statystyka t
%R2 = 1 - sum((Y - y_hat).^2)/sum((Y - mean(Y)).^2);
%inny sposob na obliczenie R^2
end