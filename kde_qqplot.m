clc;
clear;
%% Preprocessing
n=10000;

% Sample from uniform (0,1)
a=rand(n,1);

% Sample from mixture of two Gaussian distributions

dane_symul=(a<0.5).*(randn(n,1)*1+1) + (a>=0.5).*(randn(n,1)*1+4);
[K, my_xi, h_opt]=my_ksdensity(dane_symul); %recznie opracowana funkcja na dole skryptu
%[f, xi, bw]=ksdensity(dane_symul);
%figure(2)
%plot(xi, f);
x=linspace(-10, 10, n);
mu1=1;
mu2=4;
sigma1=1;
sigma2=1;
f1 = 1/((2*pi)^(0.5)*sigma1)*exp(-((x-mu1).^2)/(2*sigma1^2)); %gestosc rozkladu normalnego
f2 = 1/((2*pi)^(0.5)*sigma2)*exp(-((x-mu2).^2)/(2*sigma2^2));
f=0.5*f1+0.5*f2; %zgodnie z trescia zadania
%% Nonparametric density estimate (I)
subplot(2, 2, 1);
plot(my_xi, K, 'LineWidth', 2, 'Color', 'blue') %kernel density
hold on;
plot(x, f, 'LineWidth', 2, 'Color', 'red'); %true density
title({'Nonparametric density', 'estimate (I)'});
leg=legend({'kernel density','true density'});
axis([-5 10 0 0.25]); %zgodnie z podanym wzorem
hold off;
%% Nonparametric density estimate (II)
subplot(2, 2, 2);
histogram(dane_symul, 30, 'Normalization','pdf'); %dokumentacja - v(i)=c(i)/N*w(i)
%albo znormalizowac histogram recznie - Meeting II, s.37
%[f, xout] = hist(dane_symul, 30);
%dx = diff(xout(1:2));
%bar(xout, f/sum(f*dx)); 
hold on;
plot(x, f, 'LineWidth', 2, 'Color', 'red'); %true density
title({'Nonparametric density', 'estimate (II)'});
leg=legend({'histogram density','true density'});
axis([-5 10 0 0.25]); %zgodnie z podanym wzorem
hold off;
%% Frequency histogram for Gaussian PIT
subplot(2, 2, 3);
sorted_dane_symul=sort(dane_symul); %sortowanie danych - Meeting II, s.37
PIT_normal=normcdf(sorted_dane_symul, mean(sorted_dane_symul), std(sorted_dane_symul)); %dystrybuanta 
histogram(PIT_normal, 25, 'Normalization','probability'); %dokumentacja - v(i)=c(i)/N
%albo znormalizowac histogram recznie
%[f, xout] = hist(PIT_normal, 25);
%bar(xout, f/n); 
title({'Frequency histogram', 'for Gaussian PIT'});
%axis([0 1 0 0.06]); %aby nie bylo szerokich odstepow od 0 dla osi X
%% Q-Q plot
subplot(2, 2, 4);
alpha=0.0001:0.005:0.9999; 
%alpha=0.0001:0.001:0.9999 %zmniejszenie kroku powoduje mniej przerywana linie w ogonach
x=linspace(-3.5, 3.5, size(alpha, 2));
theoretical_q=(norminv(alpha)); %standard normal quantiles
norm_dane_symul=(dane_symul-mean(dane_symul))/std(dane_symul); %standardyzacja danych
empirical_q=quantile(norm_dane_symul, alpha); %quantiles for std. data
scatter(theoretical_q, empirical_q, 'blue', 'filled');
hold on;
plot(x, x, 'LineWidth', 2, 'Color', 'red');
title('Q-Q plot');
xlabel('standard normal quantiles');
ylabel('quantiles for std. data');
axis([-2 2 -3 3]); %zgodnie z podanym wzorem
%bez tego ograniczenia widzimy wartosc odstajaca
%figure(2)
%qqplot(dane_symul);
hold off;       
%% ksdensity recznie
%optymalny bandwidth wg reguly Silvermana 
h_opt_silverman=1.059*std(dane_symul)*n^(-1/5);
%optymalny bandwidth wg reguly Scotta (for the multimodal density and for the Gaussian kernel)
my_iqr=prctile(dane_symul, 75)-prctile(dane_symul, 25);
%iqr(dane_symul)
h_opt_scott=1.059*n^(-1/5)*min(std(dane_symul), my_iqr/1.34);
function [K, my_xi, h_opt]=my_ksdensity(dane)
n=length(dane);
sig=1.4826*median(abs(dane-median(dane))); 
h_opt=sig*(4/(3*n))^(1/5); %optymalny bandwidth wg matlaba (robust standard deviation)
%Evaluation points at which ksdensity calculates f, returned as a vector or a two-column matrix.
%For univariate data, the default is 100 equally-spaced points that cover the range of data in x.
% For bivariate data, the default is 900 equally-spaced points created using meshgrid from 30 equally-spaced points in each dimension.
my_xi=linspace(min(dane), max(dane), 100);
%range(dane_symul)==max(dane_symul)-min(dane_symul);
K=zeros(1, 100); %kde
for i=1:100
    kernel = zeros(1, n); %jadro
    for j=1:n
        u=(my_xi(i)-dane(j))/h_opt; 
        kernel(j)=exp(-(u)^2/2)/sqrt(2*pi); %K((Xi-x)/h)
    end
    K(i)=sum(kernel)/(n*h_opt); %kde of specified point
end
end


