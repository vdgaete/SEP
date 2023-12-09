% Trabalho de sistemas eletricos de potencia
% Fluxo de carga não linear 

% Esse programa resolve o fluxo de carga não linear
% utilizando o método de Newton-Raphson

% Dados de entrada

% IEEE 14 barras

% Dados 
% [       NUM    TIPO    V        TETA     PG      QG      PD         QD       GSH    BSH Qmin  Qmax]
barras = [
            1     2   1.060       0.0      232.4  -16.9   0.0         0.0      0.0    0.0    0    0
            2     1   1.045       0.0      40.0    42.4   21.70      12.70     0.0    0.0    -40  50
            3     1   1.010       0.0      0.0     23.4   94.20      19.00     0.0    0.0    0    40
            4     0   1.000       0.0      0.0    0.0     47.80       -3.90    0.0    0.0    0    0
            5     0   1.000       0.0      0.0    0.0     7.60       1.600     0.0    0.0    0    0
            6     1   1.070       0.0      0.0    12.2    11.20      7.500     0.0    0.0    -6   24
            7     0   1.000       0.0      0.0    0.0     0.0        0.0       0.0    0.0    0    0
            8     1   1.090       0.0      0.0    17.4    0.0        0.0       0.0    0.0    -6   24
            9     0   1.000       0.0      0.0    0.0     29.50       16.60    0.0   19.0    0    0
            10    0   1.000       0.0      0.0    0.0    9.00         5.800    0.0    0.0    0    0
            11    0   1.000       0.0      0.0    0.0    3.50         1.800    0.0    0.0    0    0
            12    0   1.000       0.0      0.0    0.0    6.10         1.600    0.0    0.0    0    0
            13    0   1.000       0.0      0.0    0.0    13.50        5.800    0.0    0.0    0    0
            14    0   1.000       0.0      0.0    0.0    14.90        5.000    0.0    0.0    0    0 ];

%            [FR    TO         R          X      BSHtotal   Tap  ]
linhas = [
1	2	0.01938  0.05917	0.05280    0    	
1	5	0.05403  0.22304	0.04920    0    	
2	3	0.04699  0.19797	0.04380    0   
2	4	0.05811  0.17632	0.03400    0    	
2	5	0.05695  0.17388	0.03460    0      
3	4	0.06701  0.17103	0.01280    0    	
4	5	0.01335  0.04211	0          0    	
4	7	0.0      0.20912	0  	    0.978   
4	9	0.0      0.55618	0  	    0.969   
5	6	0.0      0.25202	0  	    0.932  
6	11	0.09498  0.19890	0          0    	
6	12	0.12291  0.25581	0          0    	
6	13	0.06615  0.13027	0          0    	
7	8	0.0      0.17615  	0          0      	
7	9	0.0      0.11001	0          0    	
9	10	0.03181  0.08450	0  	       0      
9	14	0.12711  0.27038	0          0    	
10	11	0.08205  0.19207	0          0    	
12	13	0.22092  0.19988	0          0  	
13	14	0.17093  0.34802	0          0     	 ];


% Custo = [1 1 2 4 4];
% MaxP  = [250 40 15 15 15];
% MaxQ  = [50  50  50 50 50];
% MinP  = [0 0 0 0 0];
% MinQ  = [-50 -50 -50 -50 -50];


% Parametros do sistema
Ref= 1;
% ========================
% Leitura dos dados de entrada

[NumBarras,NumBCol] = size(barras);
[NumLinhas,NumLCol] = size(linhas);

% Linhas
% Init das variaveis
de = zeros(NumLinhas,1);
para = zeros(NumLinhas,1);
R = zeros(NumLinhas,1);
X = zeros(NumLinhas,1);
Tap = zeros(NumLinhas,1);

for i=1:NumLinhas
    de(i) = linhas(i,1);
    para(i) = linhas(i,2);
    R(i) = linhas(i,3);
    X(i) = linhas(i,4);
    Tap(i) = linhas(i,6);
end

% Desconsiderando taps
Tap = ones(NumLinhas,1);

% Barras
% Init das variaveis
Tipo = zeros(NumBarras,1);
V = zeros(NumBarras,1);
Teta = zeros(NumBarras,1);
Pg = zeros(NumBarras,1);
Qg = zeros(NumBarras,1);
Pd = zeros(NumBarras,1);
Qd = zeros(NumBarras,1);
Gsh = zeros(NumBarras,1);
Bsh = zeros(NumBarras,1);

for i=1:NumBarras
    Tipo(i) = barras(i,2);
    V(i) = barras(i,3);
    Teta(i) = barras(i,4);
    Pg(i) = barras(i,5);
    Qg(i) = barras(i,6);
    Pd(i) = barras(i,7);
    Qd(i) = barras(i,8);
    Gsh(i) = barras(i,9);
    Bsh(i) = barras(i,10);
end

% Potencias em PU
Pg = Pg/100;
Qg = Qg/100;
Pd = Pd/100;
Qd = Qd/100;

% Matriz de admitancia
Y = zeros(NumBarras,NumBarras);

for i=1:NumLinhas
    Y(de(i),para(i)) = -1/(R(i) + X(i)*1i);
    Y(para(i),de(i)) = Y(de(i),para(i));
end

% Diagonal principal: soma das admitancias

for i=1:NumBarras
    for j=1:NumBarras
        if i ~= j
            Y(i,i) = Y(i,i) - Y(i,j);
        end
    end 
end

% Matriz Condutancia e Susceptancia

G = real(Y);
B = imag(Y);

% Numero de barras Vtheta, PV e PQ

NumVtheta = 0;
NumPV = 0;
NumPQ = 0;

for i=1:NumBarras
    if Tipo(i) == 2
        NumVtheta = NumVtheta + 1;
    elseif Tipo(i) == 1
        NumPV = NumPV + 1;
    elseif Tipo(i) == 0
        NumPQ = NumPQ + 1;
    end
end

% Vetor BarraVtheta, BarraPV e BarraPQ

BarraVtheta = zeros(NumVtheta,1);
BarraPV = zeros(NumPV,1);
BarraPQ = zeros(NumPQ,1);

% Ordenando as barras

k = 1;
l = 1;
m = 1;

for i=1:NumBarras
    if Tipo(i) == 2
        BarraVtheta(k) = i;
        k = k + 1;
    elseif Tipo(i) == 1
        BarraPV(l) = i;
        l = l + 1;
    elseif Tipo(i) == 0
        BarraPQ(m) = i;
        m = m + 1;
    end
end

BarraPVPQ = [BarraPV;BarraPQ];


% Inicializando as matrizes

% Vetor deltaP e deltaQ

deltaP = zeros(NumPQ+NumPV,1);
deltaQ = zeros(NumPQ,1);

% Vetor Pesp e Qesp

Pesp = zeros(NumPQ+NumPV,1);
Qesp = zeros(NumPQ,1);

% Vetor Pnew e Qnew

Pnew = zeros(NumPQ+NumPV,1);
Qnew = zeros(NumPQ,1);

% Potencias Iniciais

for i=1:NumPQ+NumPV
    Pesp(i) = Pg(i) - Pd(i);
end

for i=1:NumPV
    Qesp(i) = Qg(i) - Qd(i);
end

% Vetor Teta, V: V = 1 e Teta = 0

Teta0 = zeros(NumPQ+NumPV,1);
V0 = ones(NumPQ,1);

% Matriz F: F = [deltaP;deltaQ]

F = [deltaP;deltaQ];

% Matriz X: X = [Teta;V]

X_0 = [Teta0;V0];
X_1 = [Teta0;V0];

% Equação: X_1 = X_0 + inv(J)*F_1

% Erro
erromin = 10^-6;
iter = 0;
err = 1;

% Inicializando as matrizes
H = zeros(NumPQ+NumPV,NumPQ+NumPV);
N = zeros(NumPQ+NumPV,NumPQ);
M = zeros(NumPQ,NumPQ+NumPV);
L = zeros(NumPQ,NumPQ);

% Inicio do loop
% 1 - Calculo das potencias
% 2 - Vetor F
% 3 - Calculo das derivadas parciais
% 4 - Jacobiana
% 5 - Calculo de X_1 = X_0 + inv(J)*F_1

while err > erromin
    iter = iter + 1;

    % Calculo das potencias

    % Potencia ativa
    for i=1:NumPQ+NumPV
        for j=1:NumBarras
            Pnew(i) = V(BarraPVPQ(i))*V(j)*(G(BarraPVPQ(i),j)*cos(Teta(BarraPVPQ(i))-Teta(j)) + B(BarraPVPQ(i),j)*sin(Teta(BarraPVPQ(i))-Teta(j)));
        end
    end

    % Potencia reativa
    for i=1:NumPQ
        for j=1:NumBarras
            Qnew(i) = V(BarraPQ(i))*V(j)*(G(BarraPQ(i),j)*sin(Teta(i)-Teta(j)) - B(BarraPQ(i),j)*cos(Teta(BarraPQ(i))-Teta(j)));
        end
    end

    % Residuos
    deltaP = Pesp - Pnew;
    deltaQ = Qesp - Qnew;
    % Vetor F:
    F = [deltaP;deltaQ];
    % Atualizando as potencias
    Pesp = Pnew;

    % Calculo das derivadas parciais
    % H = delP/delTeta
    % N = delP/delV
    % M = delQ/delTeta
    % L = delQ/delV

    % Equações

    % Zerar H, N, M, L
    H = zeros(NumPQ+NumPV,NumPQ+NumPV);
    N = zeros(NumPQ+NumPV,NumPQ);
    M = zeros(NumPQ,NumPQ+NumPV);
    L = zeros(NumPQ,NumPQ);

    % H
    % Hkm = V(k)*V(m)*(G(k,m)*sin(Teta(k)-Teta(m)) - B(k,m)*cos(Teta(k)-Teta(m)))
    % Hkk = -V(k)^2*B(k,k) - sum(H(k,:))
    for k=1:NumPV+NumPQ
        for m=1:NumPV+NumPQ
            if k ~= m
                H(k,m) = V(BarraPVPQ(k))*V(BarraPVPQ(m))*(G(BarraPVPQ(k),BarraPVPQ(m))*sin(Teta(BarraPVPQ(k))-Teta(BarraPVPQ(m))) - B(BarraPVPQ(k),BarraPVPQ(m))*cos(Teta(BarraPVPQ(k))-Teta(BarraPVPQ(m))));
                H(k,k) = H(k,k)-H(k,m);
            else
                H(k,k) = -V(BarraPVPQ(k))^2*B(BarraPVPQ(k),BarraPVPQ(k)) + H(k,k);
            end
        end
    end

    % N
    % Nkm = V(k)*(G(k,m)*cos(Teta(k)-Teta(m)) + B(k,m)*sin(Teta(k)-Teta(m)))
    % Nkk = V(k)*G(k,k) + sum(N(k,:))
    for k=1:NumPV+NumPQ
        for m=1:NumPQ
            if k ~= m
                N(k,m) = V(BarraPVPQ(k))*(G(BarraPVPQ(k),BarraPQ(m))*cos(Teta(BarraPVPQ(k))-Teta(BarraPQ(m))) + B(BarraPVPQ(k),BarraPQ(m))*sin(Teta(BarraPVPQ(k))-Teta(BarraPQ(m))));
                if k <= NumPQ
                    N(k,k) = N(k,k)+N(k,m);
                end
            else
                N(k,k) = V(BarraPVPQ(k))*G(BarraPVPQ(k),BarraPVPQ(k)) + N(k,k);
            end
        end
    end
    % M
    % Mkm = -V(k)*V(m)*(G(k,m)*cos(Teta(k)-Teta(m)) + B(k,m)*sin(Teta(k)-Teta(m)))
    % Mkk = -V(k)^2*G(k,k) - sum(M(k,:))
    for k=1:NumPQ
        for m=1:NumPQ+NumPV
            if k ~= m
                M(k,m) = -V(BarraPQ(k))*V(BarraPVPQ(m))*(G(BarraPQ(k),BarraPVPQ(m))*cos(Teta(BarraPQ(k))-Teta(BarraPVPQ(m))) + B(BarraPQ(k),BarraPVPQ(m))*sin(Teta(BarraPQ(k))-Teta(BarraPVPQ(m))));
                M(k,k) = M(k,k)-M(k,m);
            else
                M(k,k) = -V(BarraPQ(k))^2*G(BarraPQ(k),BarraPQ(k)) + M(k,k);
            end
        end
    end
    
    % L
    % Lkm = V(k)*(G(k,m)*sin(Teta(k)-Teta(m)) - B(k,m)*cos(Teta(k)-Teta(m)))
    % Lkk = -V(k)*B(k,k) + sum(L(k,:))
    for k=1:NumPQ
        for m=1:NumPQ
            if k ~= m
                L(k,m) = V(BarraPQ(k))*(G(BarraPQ(k),BarraPQ(m))*sin(Teta(BarraPQ(k))-Teta(BarraPQ(m))) - B(BarraPQ(k),BarraPQ(m))*cos(Teta(BarraPQ(k))-Teta(BarraPQ(m))));
                L(k,k) = L(k,k)+L(k,m);
            else
                L(k,k) = -V(BarraPQ(k))*B(BarraPQ(k),BarraPQ(k)) + L(k,k);
            end
        end
    end
    

    % Jacobiana
    J = [ H N;
          M L];

    % Calculo de X_1 = X_0 + inv(J)*F_1

    X_1 = X_0 + J\F;

    % Atualizando os valores de X_0
    X_0 = X_1;

    % Atualizando os valores de Teta e V
    for i=NumPQ+NumPV
        Teta(BarraPVPQ(i)) = X_1(i);
    end

    for i=NumPQ
        V(BarraPQ(i)) = X_1(i+NumPQ+NumPV);
    end

    % Calculo do erro
    err = max(abs(F));
    
    % Print do erro
    fprintf('Iteracao %d: Erro = %f\n',iter,err);
end


% Print dos resultados
% Print das tensões

for i=1:NumBarras
    fprintf('Barra %d: V = %f, Teta = %f\n',i,V(i),Teta(i));
end

% Print Fluxo de potencia

for i=1:NumLinhas
    fprintf('Fluxo de potencia na linha %d-%d: P = %f, Q = %f\n',de(i),para(i),Pnew(i),Qnew(i));
end




