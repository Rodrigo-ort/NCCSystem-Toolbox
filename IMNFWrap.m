% Function name....: IMNFWrap
% Date.............: Jan 28, 2019
% Mod date.........: -
% Author...........: Fabio Henrique, (oliveirafhm@gmail.com)
% Description......:
%                    Estimates Hilbert Spectrum to track instantaneous mean
%                    frequency (IMNF) and calculates boxplot stats variables
%                    (descriptive statistics) of IMNF.
% Parameters.......:
%                    y -> input time-series
%                    fs -> sample rate
%                    rmHighestFreq -> flag to remove highest
%                    frequency of input time-series
%                    plotFlag -> flag to indicate to plot figures
%                    label ->
% Return...........:
%                    imnf_out2 -> estimated instantaneous mean frequency
%                    ds -> key values of the descriptive statistics
% Remarks..........:
%                    Ref.: A. O. ANDRADE, P. Kyberd, and S. J. Nasuto,
%                    “The application of the Hilbert spectrum to the analysis of electromyographic signals,”
%                    Inf. Sci. (Ny)., vol. 178, no. 9, pp. 2176–2193, May 2008.
%                    
%                    Used code for descriptive statistics: https://www.mathworks.com/matlabcentral/fileexchange/29305-descriptive-statistics

function [imnf_out2, ds] = IMNFWrap(y, fs, rmHighestFreq, plotFlag, label)
t = [0:1:length(y)-1]/fs;
% Remove highest frequency component before proceed
if rmHighestFreq == 1
    disp('Removing highest frequency component..');
    [IMFs,residue]= sig_to_imf(y,1e-5,2);
    y = y - IMFs(1,:);
end

% Estimating intrinsic mode functions
[IMFs,residue]= sig_to_imf(y,1e-5,2);
LFreq=0;
UFreq=fs/2;
n_bins= 400;
[m_a_p,minFreq,maxFreq, hs_dt] = ...
    plotHS1(IMFs,t,fs,n_bins,[LFreq UFreq],0);
%Generating auxiliary time and frequency vectors
f = 1:1:n_bins;
f = convScale(1,n_bins,f,minFreq,maxFreq);
%Performing energy normalization (between 0 and 1)
[m_a_p]= convScale(min(min(m_a_p)),max(max(m_a_p)),m_a_p,0,1);

T=(0:1:n_bins-1)*hs_dt;
B=m_a_p;
F = f;
[imnf_out2] = IMNF(y,B,F);

ds = getDescriptiveStatistics(imnf_out2);

if plotFlag == 1
    figure;
    subplot(2,1,1);
    plot(t,y); xlabel('time (s)'); ylabel('Unit');
    title(label,'FontSize',20);
    
    subplot(2,1,2);
    imagesc(T,f,m_a_p); axis xy; colormap('hot');drawnow;
    hold on; plot(T,imnf_out2,'g'); ylabel('HS (Hz)'); xlabel('time (s)');
    
    figure;
    %     subplot(3,1,3);
    boxplot(imnf_out2,'orientation','vertical');
    ylim([0 fs/2]); ylabel('Instantaneous mean frequency (Hz)');
    title(label,'FontSize',20);
    set(gca,'XTickLabel','');
end
end

