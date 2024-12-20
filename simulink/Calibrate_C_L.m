% Load Simulink parameters
sim_params;
load('calibration_params.mat');

format long e;
model_name = "Calibration_model.slx";
omega = omega_0_est * 0.1;

simIn = Simulink.SimulationInput(model_name);
simIn = simIn.setVariable('omega', omega);
simOut = sim(simIn);

V1 = simOut.logsout{4}.Values.Data(:);
I1 = simOut.logsout{1}.Values.Data(:)*150;

N = round(0.2 * length(V1));

V1_amp_t = abs(hilbert(V1));
V1_amp = mean(V1_amp_t(N:end-N));

I1_amp_t = abs(hilbert(I1));
I1_amp = mean(I1_amp_t(N:end-N));

L1_calc = abs(1i* omega * (I1_amp * R_est - V1_amp) / (I1_amp * (omega - omega_0_est) * (omega + omega_0_est)));
C1_calc = abs(1i* I1_amp * (-omega^2 + omega_0_est^2) / (omega * omega_0_est^2 * (I1_amp * R_est - V1_amp)));

L1_est = max(L1_calc(:)); 
C1_est = max(C1_calc(:));

fprintf('L1_est (mean): %.20e\n', L1_est);
fprintf('C1_est (mean): %.20e\n', C1_est);

fprintf('L1_real: %.20e\n', L1);
fprintf('C1_real: %.20e\n', C1);

save('calibration_params.mat', 'L1_est', 'C1_est');