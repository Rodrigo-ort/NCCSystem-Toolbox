function [emgFilt, thVector] = GetEMGOnSet(sEmg,Fs,T0,T1,k_noise,FcFiltEnv,nFiltEnv,nDPth)
%
% Retorna vetor com limiares (OnSets - definem pacotes de atividade) no
% sinal EMG enviado.
%
%Como chamar esta função (para abrir a GUI):
%
% ===> CHAMADA desta função ==> 
%
%      [emgFilt, thVector] = GetEMGOnSet(sEmg,Fs,T0,T1,k_noise,FcFiltEnv,nFiltEnv,nDPth); 
%
%   Parâmetros de entrada
%      sEmg: vetor COLUNA con sinal EMG a ser processado.
%      Fs: frequencia de amostragem do sinal
%      T0,T1: intervalo (em MiliSegundos) do sinal de referência (o que não é sinal)
%      k_noise: constante para desvio padrão do ruído do sinal de referência (1 ou 2)
%      FcFiltEnv: Frequencia de corte do filtro de suavização do envelope.
%      nFiltEnv: Ordem do filtro de suavização do envelope.
%      nDPth: quantidade de desvios padrão para limiar de atividade no
%      envelope.
%
%    Retorno:
%      emgFilt: O sinal EMG FILTRADO pela técnica de Oliveira et al. 
%      thVector: Vetor com OnSets da atividade contrátil. É um vetor de 
%                limiares. 
%                Nas áreas com atividade EMG detectada, os elementos do 
%                vetor serão DIFERENTES DE ZERO. 
%                Onde não houver sinal EMG (OU onde não for o sinal desejado), 
%                os elementos serão iguais ZERO...
%como calcular os on-Sets da atividade EMG
%1 - Definir uma região do sinal com irformação distinta da desejada.
%    Neste caso, o sinal base pode ser ruído ou mesmo atividade EMG base.
%    Quando houver resistência ao estiramente teremos aumento da atividade
%    EMG. Assim, deve-se marcar como trecho de referência um trecho fora da
%    fase de estiramento/recuperação.
%    O Usuário define isso nos controles T0(milisegundos) e T1(milisegundos)
x1 = 1 + round((T0/1000)*Fs);
x2 = 1 + round((T1/1000)*Fs);

%cte_noise: valor da constante de multiplicação para o desvio padrão do reuido da
%janela de referência

%antes, eliminar qualquer nível DC - afeta o limiar
sEmg = sEmg - mean(sEmg);

%Aplicar filtro (Andrade et al.)
[emgFilt,DenoisedIMFs,IMFs,NN] = ss_filtEMD(sEmg',x1,x2,k_noise);
%calcular o emvelope do sinal EMG pela transformada de Hilbert
envSig = abs(hilbert(emgFilt));
%suavizar o envelope do sinal conforme definido pelo usuário
[envFilt] = m_LPButterworth(envSig,FcFiltEnv,nFiltEnv,Fs);
%calcular limiar conforme nro DPs definidos pelo usuário
th = mean(envSig(x1:x2)) + nDPth*std(envSig(x1:x2));
tt = find(envFilt<th); %localizar pontos abaixo do limiar
thVector = envFilt;
thVector(tt)=0; %Zerar todos os pontos do envelope filtrado abaixo do limiar
thVector(x1:x2) = 0; %ignorar qualquer detecção no intervalo de referência (de x1 a x2)

