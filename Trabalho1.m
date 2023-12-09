%% Trabalho SEP 
% Implementação do fluxo de carga linear

% Será utilizado o método de Newton para resolver o problema de fluxo de carga linear
% Para testar o programa, será utilizado o sistema ieee14 e ieee33

% O programa foi dividido em 3 partes:
% 1 - Leitura dos dados de entrada
% 2 - Cálculo das matrizes de admitância e dos vetores de potência
% 3 - Cálculo do fluxo de carga

%% Dados
% ieee14
% [       NUM    TIPO    V        TETA     PG    QG      PD         QD       GSH    BSH ]
barras = [
            1   2   1.060 0.0  232.4 -16.9  0.0     0.0     0.0    0.0 0 0
            2   1   1.045 0.0  40.0  42.4  21.70  12.70    0.0    0.0 -40  50
            3   1   1.010 0.0  0.0  23.4  94.20  19.00    0.0    0.0 0    40
            4   0   1.000 0.0  0.0   0.0  47.80   -3.90   0.0    0.0 0    0
            5   0   1.000 0.0  0.0   0.0  7.60   1.600    0.0    0.0 0    0
            6   1   1.070 0.0  0.0   12.2  11.20  7.500    0.0    0.0 -6   24
            7   0   1.000 0.0  0.0   0.0   0.0    0.0     0.0    0.0 0    0
            8   1   1.090 0.0  0.0   17.4   0.0    0.0     0.0    0.0 -6   24
            9   0   1.000 0.0  0.0   0.0  29.50   16.60   0.0   19.0 0    0
            10  0   1.000 0.0  0.0   0.0   9.00   5.800   0.0    0.0 0    0
            11  0   1.000 0.0  0.0   0.0   3.50   1.800   0.0    0.0 0    0
            12  0   1.000 0.0  0.0   0.0   6.10   1.600   0.0    0.0 0    0
            13  0   1.000 0.0  0.0   0.0   13.50  5.800   0.0    0.0 0    0
            14  0   1.000 0.0  0.0   0.0   14.90  5.000   0.0    0.0 0    0 ];

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

Custo = [1 1 2 4 4];
MaxP  = [250 40 15 15 15];
MaxQ  = [50  50  50 50 50];
MinP  = [0 0 0 0 0];
MinQ  = [-50 -50 -50 -50 -50];
% ieee33 - não inserido ainda

%% 1 - Leitura dos dados de entrada
% 1.1 - Leitura dos dados das barras
% 1.1.1 - Número de barras
nBarras = size(barras,1);

% 1.1.2 - Tipo de barras
% 0 - Slack
% 1 - PV
% 2 - PQ
tipoBarras = barras(:,2);

% 1.1.3 - Tensão inicial
V = barras(:,3);

% 1.1.4 - Ângulo inicial
theta = barras(:,4);

% 1.1.5 - Potência ativa gerada
Pg = barras(:,5);

% 1.1.6 - Potência reativa gerada
Qg = barras(:,6);

% 1.1.7 - Potência ativa consumida
Pd = barras(:,7);

% 1.1.8 - Potência reativa consumida
Qd = barras(:,8);

% 1.1.9 - Condutância shunt
Gsh = barras(:,9);

% 1.1.10 - Susceptância shunt
Bsh = barras(:,10);

% 1.2 - Leitura dos dados das linhas
% 1.2.1 - Número de linhas
nLinhas = size(linhas,1);

% 1.2.2 - Número da barra de origem
de = linhas(:,1);

% 1.2.3 - Número da barra de destino
para = linhas(:,2);

% 1.2.4 - Resistência
R = linhas(:,3);

% 1.2.5 - Reatância
X = linhas(:,4);

% 1.2.6 - Susceptância shunt total
BshTotal = linhas(:,5);

% 1.2.7 - Tap
Tap = linhas(:,6);

% 1.3 - Preparação dos dados
% 1.3.1 - Potencia em PU

Pg = Pg/100;
Qg = Qg/100;
Pd = Pd/100;
Qd = Qd/100;

% 1.3.2 - Condutância shunt em PU

Gsh = Gsh/100;
Bsh = Bsh/100;

% 1.3.3 - Susceptância shunt total em PU

BshTotal = BshTotal/100;

%% 2 - Cálculo das matrizes de admitância e dos vetores de potência
% 2.1 - Cálculo da matriz de admitância
% 2.1.1 - Cálculo da matriz de admitância de série
%
% A matriz de admitância de série é calculada a partir da matriz de
% admitância nodal, que é calculada a partir da matriz de admitância de
% linha

admNodal = zeros(nBarras,nBarras);

for i = 1:nLinhas
    admNodal(de(i),para(i)) = -1/(R(i)+1i*X(i));
    admNodal(para(i),de(i)) = admNodal(de(i),para(i));
end

% 2.1.2 - Cálculo da matriz de admitância de shunt
%
% A matriz de admitância de shunt é calculada a partir da matriz de
% admitância nodal, que é calculada a partir da matriz de admitância de
% linha

for i = 1:nBarras
    admNodal(i,i) = admNodal(i,i) + 1i*Bsh(i);
end

% 2.2 - Cálculo da matriz de admitância de linha

admLinha = zeros(nLinhas,nLinhas);

for i = 1:nLinhas
    admLinha(i,i) = 1/(R(i)+1i*X(i));
end

% 2.3 - Cálculo da matriz de admitância de shunt total

admShuntTotal = zeros(nLinhas,nLinhas);

for i = 1:nLinhas
    admShuntTotal(i,i) = 1i*BshTotal(i);
end

% 2.4 - Cálculo do vetor de potência líquida

S = (Pg - Pd) + 1i*(Qg - Qd);

%% 3 - Cálculo do fluxo de carga

% 3.1 - Cálculo do vetor de potência líquida
% 3.1.1 - Cálculo do vetor de potência líquida para barras PQ
S = S.*tipoBarras;

% 3.1.2 - Cálculo do vetor de potência líquida para barras PV

for i = 1:nBarras
    if tipoBarras(i) == 1
        S(i) = Pg(i) - Pd(i) + 1i*(Qg(i) - Qd(i));
    end
end

% 3.2 - Cálculo do vetor de potência líquida para barras PV

for i = 1:nBarras
    if tipoBarras(i) == 1
        S(i) = Pg(i) - Pd(i) + 1i*(Qg(i) - Qd(i));
    end
end

% 3.3 - Cálculo do vetor de potência líquida para barras PQ

for i = 1:nBarras
    if tipoBarras(i) == 2
        S(i) = Pg(i) - Pd(i) + 1i*(Qg(i) - Qd(i));
    end
end

% 3.4 - Cálculo do vetor de potência líquida para barras slack

for i = 1:nBarras
    if tipoBarras(i) == 0
        S(i) = Pg(i) - Pd(i) + 1i*(Qg(i) - Qd(i));
    end
end

% 3.5 - Cálculo do vetor de tensão

% 3.5.1 - Cálculo do vetor de tensão para barras PQ
V = V.*tipoBarras;

% 3.5.2 - Cálculo do vetor de tensão para barras PV

for i = 1:nBarras
    if tipoBarras(i) == 1
        V(i) = sqrt(Pg(i)^2 + Qg(i)^2)/abs(S(i));
    end
end

% 3.5.3 - Cálculo do vetor de tensão para barras PQ

for i = 1:nBarras
    if tipoBarras(i) == 2
        V(i) = sqrt(Pg(i)^2 + Qg(i)^2)/abs(S(i));
    end
end

% 3.5.4 - Cálculo do vetor de tensão para barras slack

for i = 1:nBarras
    if tipoBarras(i) == 0
        V(i) = sqrt(Pg(i)^2 + Qg(i)^2)/abs(S(i));
    end
end

% 3.6 - Cálculo do vetor de ângulo

for i = 1:nBarras
    if tipoBarras(i) == 1
        theta(i) = atan(Qg(i)/Pg(i));
    end
end





% % Salvar os valores obtidos
% V0 = V;
% theta0 = theta;
% Pg0 = Pg;
% Qg0 = Qg;
% Pd0 = Pd;
% Qd0 = Qd;
% % %% Inicialização do algoritmo de Newton
% % 1 - Inicialização do vetor de tensão
% V = ones(nBarras,1);
% 
% % 2 - Inicialização do vetor de ângulo
% theta = zeros(nBarras,1);
% 
% % 3 - Inicialização do vetor de potência líquida
% S = zeros(nBarras,1);
% 
% % 4 - Inicialização do vetor de potência ativa gerada
% Pg = zeros(nBarras,1);
% 
% % 5 - Inicialização do vetor de potência reativa gerada
% Qg = zeros(nBarras,1);
% 
% % 6 - Inicialização do vetor de potência ativa consumida
% Pd = zeros(nBarras,1);
% 
% % 7 - Inicialização do vetor de potência reativa consumida
% Qd = zeros(nBarras,1);

% %% Algoritmo de Newton
% % inicialização do erro
% erro = 1;
% erro_min = 1e-6;
% 
% % inicialização do histórico de valores
% V_hist = V;
% 
% 
% while erro > erro_min
%     % 1 - Cálculo do vetor de potência líquida
%     % 1.1 - Cálculo do vetor de potência líquida para barras PQ
%     S = S.*tipoBarras;
% 
%     % 1.2 - Cálculo do vetor de potência líquida para barras PV
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 1
%             S(i) = Pg(i) - Pd(i) + 1i*(Qg(i) - Qd(i));
%         end
%     end
% 
%     % 1.3 - Cálculo do vetor de potência líquida para barras PQ
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 2
%             S(i) = Pg(i) - Pd(i) + 1i*(Qg(i) - Qd(i));
%         end
%     end
% 
%     % 1.4 - Cálculo do vetor de potência líquida para barras slack
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 0
%             S(i) = Pg(i) - Pd(i) + 1i*(Qg(i) - Qd(i));
%         end
%     end
% 
%     % 2 - Cálculo do vetor de tensão
%     % 2.1 - Cálculo do vetor de tensão para barras PQ
%     V = V.*tipoBarras;
% 
%     % 2.2 - Cálculo do vetor de tensão para barras PV
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 1
%             V(i) = sqrt(Pg(i)^2 + Qg(i)^2)/abs(S(i));
%         end
%     end
% 
%     % 2.3 - Cálculo do vetor de tensão para barras PQ
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 2
%             V(i) = sqrt(Pg(i)^2 + Qg(i)^2)/abs(S(i));
%         end
%     end
% 
%     % 2.4 - Cálculo do vetor de tensão para barras slack
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 0
%             V(i) = sqrt(Pg(i)^2 + Qg(i)^2)/abs(S(i));
%         end
%     end
% 
%     % 3 - Cálculo do vetor de ângulo
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 1
%             theta(i) = atan(Qg(i)/Pg(i));
%         end
%     end
% 
%     % 4 - Cálculo do vetor de potência ativa gerada
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 1
%             Pg(i) = Pg(i) + Custo(i);
%         end
%     end
% 
%     % 5 - Cálculo do vetor de potência reativa gerada
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 1
%             Qg(i) = Qg(i) + Custo(i);
%         end
%     end
% 
%     % 6 - Cálculo do vetor de potência ativa consumida
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 2
%             Pg(i) = Pg(i) + Custo(i);
%         end
%     end
% 
%     % 7 - Cálculo do vetor de potência reativa consumida
% 
%     for i = 1:nBarras
%         if tipoBarras(i) == 2
%             Qg(i) = Qg(i) + Custo(i);
%         end
%     end
% 
%     % 8 - Cálculo do erro
% 
%     erro = max(abs(S));
% 
%     % 9 - Atualização de histórico de valores
% 
%     V_hist = [V_hist V];
%     theta_hist = [theta_hist theta];
%     Pg_hist = [Pg_hist Pg];
%     Qg_hist = [Qg_hist Qg];
%     Pd_hist = [Pd_hist Pd];
%     Qd_hist = [Qd_hist Qd];
%     S_hist = [S_hist S];
%     erro_hist = [erro_hist erro];
% 
% end




%% Resultados
%
% 1 - Matriz de admitância nodal
% disp('Matriz de admitância nodal')
% disp(admNodal)
% 
% % 2 - Matriz de admitância de linha
% disp('Matriz de admitância de linha')
% disp(admLinha)
% 
% % 3 - Matriz de admitância de shunt total
% disp('Matriz de admitância de shunt total')
% disp(admShuntTotal)
% 
% % 4 - Vetor de potência líquida
% disp('Vetor de potência líquida')
% disp(S)
% 
% % 5 - Vetor de tensão
% disp('Vetor de tensão')
% disp(V)
% 
% % 6 - Vetor de ângulo
% disp('Vetor de ângulo')
% disp(theta)
% 
% % 7 - Vetor de potência ativa gerada
% disp('Vetor de potência ativa gerada')
% disp(Pg)
% 
% % 8 - Vetor de potência reativa gerada
% disp('Vetor de potência reativa gerada')
% disp(Qg)
% 
% % 9 - Vetor de potência ativa consumida
% disp('Vetor de potência ativa consumida')
% disp(Pd)
% 
