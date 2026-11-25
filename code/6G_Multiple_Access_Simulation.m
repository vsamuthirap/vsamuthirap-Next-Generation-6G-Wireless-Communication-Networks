%% 6G Multiple Access Performance Evaluation
% Project: Performance Evaluation and Optimization of Advanced Multiple
% Access Techniques for Next-Generation 6G Wireless Communication Networks
%
% Algorithms: OFDMA, NOMA, SCMA, PDMA, CA-HMRA (proposed)
% Toolbox requirement: Base MATLAB only.
%
% IMPORTANT:
% This is a comparative system-level simulation using explicit simplified
% assumptions. It is suitable for generating reproducible project results,
% but it is NOT a standards-compliant 6G physical-layer simulator and the
% outputs must not be described as measured/real-world results.

clear; clc; close all;
rng(10);                         % Reproducible results

%% 1. Simulation configuration
algorithms = {'OFDMA','NOMA','SCMA','PDMA','CA-HMRA'};
nAlg = numel(algorithms);
algorithmVars = {'OFDMA','NOMA','SCMA','PDMA','CA_HMRA'};

bandwidth_MHz = 20;              % Assumed system bandwidth
snrBER_dB = 0:5:30;              % BER analysis SNR values
snrOperating_dB = 10;            % Operating SNR for other comparisons
userLoads = [5 10 15 20 25 30 35 40];
channelNames = {'Poor','Moderate','Good','Very Good'};
channelSNR_dB = [0 5 10 15];

% Comparative model parameters (assumptions, not measured constants).
% Access efficiency represents usable resource fraction.
accessEff = [0.90 0.94 0.92 0.91 0.97];

% Effective link gain includes the modeled benefit/penalty of each method.
linkGain_dB = [-1.0 1.0 0.5 0.0 2.5];

% Residual multi-user interference coefficient. Lower is better.
interferenceCoeff = [0.080 0.120 0.100 0.090 0.040];

% Power model: fixed network power plus per-active-user power (W).
basePower_W = [8.0 9.0 8.5 8.5 8.2];
powerPerUser_W = [0.35 0.38 0.36 0.35 0.30];

%% 2. BER versus SNR
% BPSK over an equivalent AWGN link. The effective SNR includes the
% assumed algorithm link gain and residual multi-user interference.
berUsers = 10;
ber = zeros(numel(snrBER_dB),nAlg);
loadFactorBER = 1 + interferenceCoeff*(berUsers-1);

for a = 1:nAlg
    effectiveSNR = 10.^(snrBER_dB/10) .* ...
        10^(linkGain_dB(a)/10) ./ loadFactorBER(a);
    ber(:,a) = 0.5 .* erfc(sqrt(effectiveSNR(:)));
end

BER_Table = array2table([snrBER_dB(:), ber], ...
    'VariableNames', [{'SNR_dB'}, algorithmVars]);

figure('Name','BER vs SNR');
semilogy(snrBER_dB, ber, '-o','LineWidth',1.8,'MarkerSize',6);
grid on; xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
title('BER Performance Comparison');
legend(algorithms,'Location','southwest');
ylim([1e-8 1]);

%% 3. Network throughput versus number of users
% Total throughput = bandwidth x spectral efficiency x user-activity
% factor. The activity factor increases with user count and saturates.
throughput_Mbps = zeros(numel(userLoads),nAlg);
snrLinear = 10^(snrOperating_dB/10);

for a = 1:nAlg
    for k = 1:numel(userLoads)
        U = userLoads(k);
        multiUserPenalty = 1 + interferenceCoeff(a)*(U-1);
        effSINR = snrLinear * 10^(linkGain_dB(a)/10) / multiUserPenalty;
        spectralEff = accessEff(a)*log2(1+effSINR);
        userActivity = 1-exp(-U/8);
        throughput_Mbps(k,a) = bandwidth_MHz * spectralEff * userActivity;
    end
end

Throughput_Table = array2table([userLoads(:), throughput_Mbps], ...
    'VariableNames', [{'Number_of_Users'}, algorithmVars]);

figure('Name','Throughput vs Users');
plot(userLoads, throughput_Mbps, '-o','LineWidth',1.8,'MarkerSize',6);
grid on; xlabel('Number of Active Users'); ylabel('Throughput (Mbps)');
title(sprintf('Network Throughput at %d dB SNR',snrOperating_dB));
legend(algorithms,'Location','best');

%% 4. Spectral efficiency comparison
% Evaluated at the stated operating SNR and a reference load of 20 users.
referenceUsers = 20;
spectralEfficiency = zeros(1,nAlg);

for a = 1:nAlg
    effSINR = snrLinear * 10^(linkGain_dB(a)/10) / ...
        (1 + interferenceCoeff(a)*(referenceUsers-1));
    spectralEfficiency(a) = accessEff(a)*log2(1+effSINR);
end

SpectralEfficiency_Table = table(algorithms(:), ...
    spectralEfficiency(:), ...
    'VariableNames',{'Algorithm','Spectral_Efficiency_bit_per_s_per_Hz'});

figure('Name','Spectral Efficiency');
bar(spectralEfficiency);
grid on; xticks(1:nAlg); xticklabels(algorithms);
ylabel('Spectral Efficiency (bit/s/Hz)');
title(sprintf('Spectral Efficiency at %d dB SNR, %d Users', ...
    snrOperating_dB,referenceUsers));

%% 5. Energy efficiency comparison
% Energy efficiency = aggregate throughput (Mbit/s) / total power (W)
% resulting in Mbit/J. The power model is an explicit simulation assumption.
energyEfficiency = zeros(1,nAlg);
throughputAtReference = zeros(1,nAlg);
totalPower_W = zeros(1,nAlg);

for a = 1:nAlg
    throughputAtReference(a) = throughput_Mbps( ...
        find(userLoads==referenceUsers,1),a);
    totalPower_W(a) = basePower_W(a) + ...
        powerPerUser_W(a)*referenceUsers;
    energyEfficiency(a) = throughputAtReference(a)/totalPower_W(a);
end

EnergyEfficiency_Table = table(algorithms(:), ...
    throughputAtReference(:),totalPower_W(:),energyEfficiency(:), ...
    'VariableNames',{'Algorithm','Throughput_Mbps','Power_W', ...
    'Energy_Efficiency_Mbit_per_J'});

figure('Name','Energy Efficiency');
bar(energyEfficiency);
grid on; xticks(1:nAlg); xticklabels(algorithms);
ylabel('Energy Efficiency (Mbit/J)');
title(sprintf('Energy Efficiency at %d dB SNR, %d Users', ...
    snrOperating_dB,referenceUsers));

%% 6. Outage probability under different channel conditions
% Rayleigh fading model: P_out = 1 - exp(-gamma_threshold/average_gamma).
% The outage threshold is 0 dB. Channel conditions are represented by
% average SNR values listed in channelSNR_dB.
outageThreshold_dB = 0;
outageThreshold = 10^(outageThreshold_dB/10);
outageProbability = zeros(numel(channelSNR_dB),nAlg);
outageUsers = 10;

for a = 1:nAlg
    for c = 1:numel(channelSNR_dB)
        avgSNR = 10^(channelSNR_dB(c)/10) * ...
            10^(linkGain_dB(a)/10) / ...
            (1 + interferenceCoeff(a)*(outageUsers-1));
        outageProbability(c,a) = ...
            1-exp(-outageThreshold/avgSNR);
    end
end

Outage_Table = array2table([channelSNR_dB(:),outageProbability], ...
    'VariableNames',[{'Channel_Average_SNR_dB'},algorithmVars]);

figure('Name','Outage Probability');
plot(channelSNR_dB,outageProbability,'-o', ...
    'LineWidth',1.8,'MarkerSize',6);
grid on; xlabel('Average Channel SNR (dB)');
ylabel('Outage Probability');
title('Outage Probability Under Different Channel Conditions');
legend(algorithms,'Location','northeast');
ylim([0 1]);

%% 7. Combined comparison table at reference operating point
[bestBER,idxBER] = min(ber(snrBER_dB==snrOperating_dB,:));
[bestThroughput,idxThroughput] = max(throughputAtReference);
[bestSE,idxSE] = max(spectralEfficiency);
[bestEE,idxEE] = max(energyEfficiency);
[bestOutage,idxOutage] = min(outageProbability( ...
    channelSNR_dB==snrOperating_dB,:));

BestAlgorithm_Table = table( ...
    {'Lowest BER';'Highest Throughput';'Highest Spectral Efficiency'; ...
     'Highest Energy Efficiency';'Lowest Outage Probability'}, ...
    {algorithms{idxBER};algorithms{idxThroughput};algorithms{idxSE}; ...
     algorithms{idxEE};algorithms{idxOutage}}, ...
    [bestBER;bestThroughput;bestSE;bestEE;bestOutage], ...
    'VariableNames',{'Performance_Metric','Best_Algorithm','Value'});

%% 8. Display all numerical tables in MATLAB Command Window
fprintf('\n========== BER vs SNR TABLE ==========\n');
disp(BER_Table);

fprintf('\n========== THROUGHPUT TABLE ==========\n');
disp(Throughput_Table);

fprintf('\n========== SPECTRAL EFFICIENCY TABLE ==========\n');
disp(SpectralEfficiency_Table);

fprintf('\n========== ENERGY EFFICIENCY TABLE ==========\n');
disp(EnergyEfficiency_Table);

fprintf('\n========== OUTAGE PROBABILITY TABLE ==========\n');
disp(Outage_Table);

fprintf('\n========== BEST-PERFORMANCE SUMMARY ==========\n');
disp(BestAlgorithm_Table);

%% 9. Export tables as CSV files
writetable(BER_Table,'BER_Results.csv');
writetable(Throughput_Table,'Throughput_Results.csv');
writetable(SpectralEfficiency_Table,'Spectral_Efficiency_Results.csv');
writetable(EnergyEfficiency_Table,'Energy_Efficiency_Results.csv');
writetable(Outage_Table,'Outage_Probability_Results.csv');
writetable(BestAlgorithm_Table,'Best_Algorithm_Summary.csv');

fprintf('\nSimulation completed. Six CSV result files were saved in:\n%s\n',pwd);

%% 10. Save all figures as PNG files
figHandles = findall(0,'Type','figure');
for k = 1:numel(figHandles)
    figure(figHandles(k));
    saveas(figHandles(k),sprintf('6G_Result_Figure_%02d.png',k));
end

fprintf('All result figures were saved as PNG files.\n');
