% Function name....: ss_filtEMD
% Date.............: September 10, 2004
% Author...........: Adriano de Oliveira Andrade
% Description......:
%                    This function filters a given signal based on the de-noising procedure using
%                    the empirical mode decomposition method
% Parameters.......: 
%                    signal .........-> input time-series
%                    wndNoiseI.......-> this is an integer number (index) that is the begining of the window
%                                       of noise. It is assumed that this window has been manually 
%                                       selected and therefore this parameter is known
%                    wndNoiseF.......-> this is an integer number that is the end of the window
%                                       of noise. It is assumed that this window has been manually 
%                                       selected and therefore this parameter is known
%                    kk..............-> constant (integer number) that multiplies the standard
%                                       deviation of the window of noise
%
% Return...........:
%                    FiltSig.........-> filtered signal
%                    DenoisedIMFs....-> denoised IMFs (for this soft-threshold is used)
%                    IMFs............-> this is the residue or noise. It is the difference between
%                                       the input signal and the filtered signal (X)
%                    NN..............-> noise. This is the difference between the reconstructed 
%                                       signal based on IMFs and the reconstructed signal 

function [FiltSig,DenoisedIMFs,IMFs,NN] = ss_filtEMD(signal,wndNoiseI,WNDnoiseF,kk)

%Estimating IMFs (decomposing the original signal into intrinsic mode functions)
[IMFs,residue]= sig_to_imf(signal,1e-5,2);

[r,c] = size(IMFs);
NumberOfImfs = r;

%Estimating the threshold base on the first IMF (shortest time scale)
% th = kk*std(IMFs(1,wndNoiseI:WNDnoiseF)); %based on the Chebychev's theorem

%Denoising IMFs
for i=1:r,
   th = kk*std(IMFs(i,round(wndNoiseI):round(WNDnoiseF))); %based on the Chebychev's theorem
   DenoisedIMFs(i,:) = wthresh(IMFs(i,:),'s',th);
end;%number of IMFs

%Recomposing imfs
FiltSig = sum(DenoisedIMFs);

%estimating noise
NN = signal - FiltSig; 