clc;
clear;

n = 1000; %liczba obserwacji
alphas = [0.2 0.7 0.05 0.01 0.01]; %scenariuszowe alphy
betas = [0.7 0.2 0.8 0.95 0.98]; %scenariuszowe bety
w = zeros(5, 1); %const
for q=1:5 
    %jesli bezwarunkowa wariancja jest zawsze rowna 0.3, mamy
    w(q)=0.3*(1-alphas(q)-betas(q)); %E(at^2)=w/(1-(alpha+beta)) - GARCH(1,1)
end
x = 1:n; %dla wykresow
for i=1:5 %kazdy scenariusz
    cond_var = zeros(n, 1); %warunkowa wariancja
    returns = zeros(n, 1); %zwroty
    eps = zeros(n, 1); %skladnik losowy
    returns(1) = 1; %dla inicjalizacji loopa 
    cond_var(1) = 0.3; %dla inicjalizacji loopa pierwsza warunkowa=bezwarunkowa
    rng(11); %podane w tresci ziarno
    for j=1:n %dla kazdego scenariusza 1000 obserwacji
        eps(j)=randn; %i.i.d N(0,1)
        returns(j)=eps(j)*(cond_var(j)^0.5); %GARCH(1,1)
        cond_var(j+1)=w(i)+alphas(i)*(returns(j)^2)+betas(i)*cond_var(j); %zgodnie z podanymi wzorami
    end
    subplot(5, 2, i*2-1); %i*2, aby ominac blad zmiany wykresu przy kolejnej iteracji 
    plot(x, cond_var(1:end-1), 'Color', 'red'); %bez 1001 obserwacji
    title({['\alpha=' num2str(alphas(i)) ',\beta=' num2str(betas(i))]}); %Latex + konwertacja typow
    subplot(5, 2, i*2); 
    plot(x, returns, 'Color', 'blue');
    title({['\alpha=' num2str(alphas(i)) ',\beta=' num2str(betas(i))]}); 
end