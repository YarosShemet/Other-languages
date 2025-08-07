%Shemet ex.20
clc;
clear;
vector_df = [1 3 5 50]; %deklaracja wektora stopni swobody
limits_x = [15 20 30 100]; %deklaracja wektora granic (aby sie zgadzalo miedzy lewa a prawa czescia)
limits_y_density = [1.5 0.25 0.2 0.05]; %jw.
limits_y_hist = [0.6 0.25 0.2 0.17]; %jw.
for i=1:4 %petla w 4 iteracje
    v = vector_df(i); %wybor stopnia swobody z wektora
    eps = chi2rnd(v, 100000, 1); %losowanie 100000 wartosci z rozkładu chi-kwadrat
    x = linspace(0, max(eps), 100000); %aby prawa i lewa strona wykresu sie zgadzala,
    % definiuje wektor 1x100000 jako ciag punktow od 0 do maksymalnej wylosowanej wartosci z krokiem 100000 
    subplot(4, 2, i*2);   %wyznaczenie "miejsca" dla wykresu funkcji gestosci iterowanego stopnia swobody
    % i*2, aby ominac blad zmiany wykresu przy kolejnej iteracji 
    f = (x.^(v/2-1).*exp(-x./2))/(2^(v/2)*gamma(v/2)); %wzor na funkcje gestosci chi-kwadrat
    %f = chi2pdf(x, v); %dla sprawdzenia poprawnosci recznie napisanej funkcji
    plot(x, f, 'LineWidth', 2);
    xlabel('x'); %podpis osi X
    title({'Density function for \chi^2 distribution', ['with no. of degrees of freedom: ' num2str(v)]});  
    %tytul jest zdefiniowany przez 2 podzielone \n (przejsciem do
    %nastepnego wiersza) elementy - string i list, gdzie list zawiera w
    %sobie skonwertowany do tekstu typ zmiennej stopnia swobody.
    %znaleziono w przykładach dokumentacji "title"
    axis([0 limits_x(i) 0 limits_y_density(i)]) %zabieg, wykorzystany aby obie osie zaczynaly sie od 0
    
    

    subplot(4, 2, i*2-1); %jw.
    histogram(eps, 25, 'Normalization', 'probability');
    %odpowiedni typ osi Y - czestosc (frequency, nie count) implikuje zastosowanie
    %nowszej funkcji i przejrzania dokumentacji - v(i)=c(i)/N
    xlabel('x'); %jw.
    title({'Frequency histogram for \chi^2 distribution', ['with no. of degrees of freedom: ' num2str(v)]}); %jw.
    axis([0 limits_x(i) 0 limits_y_hist(i)]) % bez tej linijki powstaje odstep na osi X
end