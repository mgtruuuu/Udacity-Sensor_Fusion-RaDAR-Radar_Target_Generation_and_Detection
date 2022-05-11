clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fc = 77e9;
radar_range_resolution = 1;
radar_range_max = 200;
radar_velocity_max = 70;
radar_velocity_resolution = 3;

%speed of light = 3e8
c = 3e8;



%% User Defined Range and Velocity of target
% *%TODO* :
% Define the target's initial position and velocity. 
% Note : Velocity remains contant.

target_range = 100;
target_velocity = -20;



%% FMCW Waveform Generation

% *%TODO* :
% Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp)
% and Slope (slope) of the FMCW chirp using the requirements above.

B = c / (2 * radar_range_resolution);

t_sweep = 5.5;
Tchirp = t_sweep * 2 * (radar_range_max/c);
slope = B / Tchirp;
                                                          
% The number of chirps in one sequence.
% Its ideal to have 2^ value for the ease of running the FFT
% for Doppler Estimation. 
Nd = 128;               % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr = 1024;              % for length of time OR # of range cells

% timestamp for running the displacement scenario for every sample on each chirp
t = linspace(0, Nd * Tchirp, Nr * Nd);      % total time for samples


% Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx = zeros(1, length(t));       % transmitted signal
Rx = zeros(1, length(t));       % received signal
Mix = zeros(1, length(t));      % beat signal


% Similar vectors for range_covered and time delay.
r_t = zeros(1, length(t));
td = zeros(1, length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i = 1:length(t)         
        
    % *%TODO* :
    % For each time stamp update the Range of the Target for constant velocity. 
    tau = (target_range + t(i) * target_velocity) / c;       % seconds

    % *%TODO* :
    % For each time sample
    % we need to update the transmitted and received signal. 
    Tx(i) = cos(2 * pi * (fc * t(i)         + slope * t(i)^2 / 2));
    Rx(i) = cos(2 * pi * (fc * (t(i) - tau) + slope * (t(i) - tau)^2 / 2));

    % *%TODO* :
    % Now by mixing the transmit and receive generate the beat signal.
    % This is done by element wise matrix multiplication 
    % of Transmit and Receiver Signal.
    Mix(i) = Tx(i) * Rx(i);
end



%% RANGE MEASUREMENT


% *%TODO* :
% Reshape the vector into Nr*Nd array.
% Nr and Nd here would also define the size of Range and Doppler FFT respectively.
beat = reshape(Mix, [Nr, Nd]);


% *%TODO* :
% Run the FFT on the beat signal along the range bins dimension (Nr) and normalize.
signal_fft = fft(beat, Nr) ./ Nr;


% *%TODO* :
% Take the absolute value of FFT output.
signal_fft = abs(signal_fft);


% *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
signal_fft = signal_fft(1 : Nr/2 + 1);


% plotting the range
figure('Name','Range from First FFT')
plot(signal_fft); 
axis([0 200 0 1]);
xlabel('Range');
ylabel('Normalized amplitude');




%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here.
% This will run a 2DFFT on the mixed signal (beat signal) output 
% and generate a range doppler map.
% You will implement CFAR on the generated RDM.


% Range Doppler Map Generation.

% The output of the 2D FFT is an image 
% that has reponse in the range and doppler FFT bins.
% So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix = reshape(Mix, [Nr, Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix, Nr, Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:(Nr/2), 1:Nd);
sig_fft2 = fftshift(sig_fft2);
RDM = abs(sig_fft2);
RDM = 10 * log10(RDM);

% Use the surf function to plot the output of 2DFFT 
% and to show axis in both dimensions.
doppler_axis = linspace(-100, 100, Nd);
range_axis = linspace(-200, 200, Nr/2) * ((Nr/2) / 400);
figure('Name', 'Range From FFT2');
surf(doppler_axis, range_axis, RDM);
xlabel('Speed');
ylabel('Range');
zlabel('Amplitude');




%% CFAR implementation

% Slide Window through the complete Range Doppler Map

% *%TODO* :
% Select the number of Training Cells in both the dimensions.
TC_range = 12;      
TC_doppler = 6;     


% *%TODO* :
% Select the number of Guard Cells in both dimensions around the Cell 
% under test (CUT) for accurate estimation.
GC_range = 6;       
GC_doppler = 4;     


% *%TODO* :
% Offset the threshold by SNR(signal-to-noise ratio) value in dB.
offset = 18;



% *%TODO* :
% Design a loop such that it slides the CUT across range doppler map
% by giving margins at the edges for training and Guard Cells.
% For every iteration sum the signal level within all the training cells.
% To sum convert the value from logarithmic to linear using db2pow function.
% Average the summed values for all of the training cells used.
% After averaging convert it back to logarithimic using pow2db.
% Further add the offset to it to determine the threshold. 
% Next, compare the signal under CUT with this threshold. 
% If the CUT level > threshold assign it a value of 1, else equate it to 0.

% Use RMD[x,y] as the matrix from the output of 2D FFT for implementing CFAR.

threshold_CFAR = zeros(size(RDM));
CFAR = zeros(size(threshold_CFAR));

num_GC = (2 * GC_range + 1) * (2 * GC_doppler + 1) - 1;
num_TC = (2 * TC_range + 2 * GC_range + 1) * (2 * TC_doppler + 2 * GC_doppler + 1) - num_GC - 1;


% Use CFAR[x,y] from the output of 2D FFT above for implementing CFAR
for range_index = TC_range + GC_range + 1 : Nr/2 - TC_range - GC_range
    for doppler_index = TC_doppler + GC_doppler + 1 : Nd - TC_doppler - GC_doppler
        % Populate all the elements in the window.
        mat_temp = RDM(range_index - TC_range - GC_range : range_index + TC_range + GC_range, ...
                       doppler_index - TC_doppler - GC_doppler : doppler_index + TC_doppler + GC_doppler);

        % Set all non-training cells to zero.
        mat_temp(TC_range + 1 : TC_range + GC_range, TC_doppler + 1 : TC_doppler + GC_doppler) = 0;

        % Convert from decibel to linear value.
        mat_temp = db2pow(mat_temp);

        % Calculate the TC_rangeaining mean.
        mean = sum(sum(mat_temp)) / num_TC;

        % Revert
        mean = pow2db(mean);

        % Use the offset to determine the SNR threshold.
        threshold_CFAR(range_index, doppler_index) = mean + offset;

        % Apply the threshold to the CUT.
        if RDM(range_index, doppler_index) > threshold_CFAR(range_index, doppler_index)
            CFAR(range_index, doppler_index) = 1;
        end
    end
end



% *%TODO* :
% The process above will generate a thresholded block, 
% which is smaller than the Range Doppler Map
% as the CUT cannot be located at the edges of matrix. 
% Hence, few cells will not be thresholded.
% To keep the map size same set those values to 0. 



% *%TODO* :
% Display the CFAR output using the Surf function 
% like we did for Range Doppler Response output.
figure('Name', 'replace this with output')
surf(doppler_axis, range_axis, CFAR);
colorbar;
xlabel('Speed');
ylabel('Range');
zlabel('Normalized Amplitude');