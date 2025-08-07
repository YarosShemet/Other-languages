%Yaraslau Shemet ex.1
clc;
clear all;
[daily_returns] = xlsread("Domowe\Apple_daily_prices.xlsx", 'F2:F9636'); %wczytuje dane 
[weekly_returns] = xlsread("Domowe\Apple_weekly_prices.xlsx", 'F2:F1998');
[monthly_returns] = xlsread("Domowe\Apple_monthly_prices.xlsx", 'F2:F462');
logreturns_daily = log(daily_returns(2:end,:))-log(daily_returns(1:end-1,:)); %transformuje do logarytmicznych stop
logreturns_weekly = log(weekly_returns(2:end,:))-log(weekly_returns(1:end-1,:));
logreturns_monthly = log(monthly_returns(2:end,:))-log(monthly_returns(1:end-1,:));
logreturns = {logreturns_daily, logreturns_weekly, logreturns_monthly}; %tworze array ktory zawiera 3 wektora
% nie moge je polaczyc do jednej macierzy z uwagi na rozne wymiary
indices = {'daily returns', 'weekly returns', 'monthly returns'}; %array nazw
desc_stat=zeros(6,3); %macierz, ktora bedzie zawierala 6 statystyk dla 3 szeregow czasowych
for i=1:3 %petla gdzie dla kazdego szeregu czasowego beda wyliczane statystyki
    desc_stat(1,i) = mean(logreturns{i}); %srednia
    desc_stat(2,i) = std(logreturns{i}); %odchylenie standardowe
    desc_stat(3,i) = skewness(logreturns{i}); %skosnosc
    desc_stat(4,i) = kurtosis(logreturns{i}); %kurtoza
    [desc_stat(5,i) desc_stat(6,i)] = jbtest1(logreturns{i}); %statystyka JB-testu i p-value JB-testu
    %korzystam z funkcji podanej na zajeciach
end;
%wyswietlanie wynikow
disp('Descriptive statistics for the Apple stock returns')
disp('-------------------------------------------------------------------------------');
disp('                    Mean   Std.Dev.  Skewness  Kurtosis  J-B stat   J-B p-value');
disp('-------------------------------------------------------------------------------');
for i=1:3
    fprintf('%15s %8.3f %9.3f %9.3f %9.3f %12.3f %9.3f \n', indices{i}, desc_stat(:,i));
end; 
%Sredni dzienny zwrot - 0.1% z odchyleniem standardowym w 3%
%Sredni tygodniowy zwrot - 0.4% z odchyleniem standardowym w 8.8%
%Sredni miesieczny zwrot - 1.9% z odchyleniem standardowym w 13.4%

%Dla kazdego szeregu skosnosc jest ujemna, wiec 
%rozklady sa lewostronne i wiekszosc wynikow jest powyzej sredniej

%Dla kazdego szeregu kurtoza wynosi wiecej niz 3, co swiadczy o tym,
%ze mamy do czynienia z rozkladami leptokurtycznymi
% p-po zdarzen nietypowych jest wyzsze niz dla rozkladow normalnego 

%Dla kazdego szeregu statystyka JB jest wieksza od wartosci krytycznej,
%P-value dla JB-testu jest mniejsza niż poziom istotności (0.01;0.05;0.1), 
%wiec odrzucam H0 na rzecz H1, mowiaca ze skladnik losowy 
%nie ma rozkladu normalnego (S~=0 ^ K~=3)
%--------------------------------------------------------------------------
%Yaraslau Shemet ex.2
clc;
clear all;
[daily_returns] = xlsread("Domowe\Apple_daily_prices.xlsx", 'F2:F9636'); %wczytuje dane
logreturns_daily = log(daily_returns(2:end,:))-log(daily_returns(1:end-1,:)); %transformuje do logarytmicznych stop
alpha = 0.05; %poziom istotnosci
n = size(logreturns_daily, 1); %liczba obserwacji
if alpha == 0.05 && n > 50 %wyznaczenie wartosci krytycznej zgodnie z podanym wzorem
    crit_value = 0.895/((0.83+n)/sqrt(n)-0.01);
elseif alpha == 0.01 && n > 50
    crit_value = 1.035/((0.83+n)/sqrt(n)-0.01);
end;
x = linspace(min(logreturns_daily), max(logreturns_daily), n); %wektor x dla CDF z takim krokiem aby wymiar sie zgadzal
%korzystam z gotowej funkcji aby wyznaczyc teoretyczna dystrybuante przy zalozeniu normalnosci
theory_cdf = normcdf(x, mean(logreturns_daily), std(logreturns_daily));
%zerowy wektor do petli obliczen empirycznej dystrybuanty (wymiary theory_cdf i ecdf musza byc takie same dla obliczenia statystyki)
my_ecdf = zeros(1, n); 
sorted_logreturns = sort(logreturns_daily); %aby obliczyc empiryczna dystybuante sortuje dane 
for i=1:n 
    yi = x(i); %dane do porownania
    my_ecdf(i) = sum(sorted_logreturns <= yi)/n; %F_n(y) - wzor podany na slajdach
end
my_KS = max(abs(my_ecdf-theory_cdf)); %statystyka testowa - wzor podany na slajdach

plot(x,theory_cdf,'LineWidth',2,'Color','blue'); %wykresy 
hold on
plot(x,my_ecdf,'LineWidth',2,'Color','red')
xlabel('return');
ylabel('CDF');
leg=legend({'Normal CDF','Empirical CDF'});
set(gca,'xTick',-0.1:0.05:0.15)
axis([-0.15 0.15 0 1])
set(gca,'FontSize',15);
legend boxoff 
hold off;

fprintf('%29s %5.4f \n', "Lilliefors test statistic is:", my_KS); %wyswietlanie wynikow
if my_KS > crit_value
    my_h = 1; %decyzja
    fprintf('%17s %5.4f %25s \n', "Critical value is", crit_value,", thus we reject the H_0.")
else
    my_h = 0; 
    fprintf('%17s %5.4f %25s \n', "Critical value is", crit_value,", thus we failed to reject the H_0.")
end
[h,p,kstat,critval] = lillietest(logreturns_daily); %wbudowana funkcja
diff_dec = my_h==h; %odrzucenie H_0, decyzja jest taka sama
diff_KS = abs(my_KS-kstat); %roznica w statystyce testowej
diff_crit = abs(crit_value-critval); %roznica w wartosci krytycznej

%zalaczona funkcja jest prawie identyczna z opisanym wyzej
%przyjmuje dwa argumenty - dane i poziom istotnosci
lillieforstest(xlsread("Domowe\Apple_daily_prices.xlsx", 'F2:F9636'), 0.05);