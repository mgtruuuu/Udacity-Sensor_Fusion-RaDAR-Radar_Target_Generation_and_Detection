# Radar Target Generation and Detection




## 1. Project Overview

This is the project about radar target generation and detection. It uses [Matlab](https://www.mathworks.com/?s_tid=gn_logo) and covers the following key concepts:

- Frequency-Modulated Continuous Wave radar (FMCW)
- Range-Doppler Estimation
- (2D) Fast Fourier transforms (FFT) algorithm (to convert the signal from time domain to frequency domain)
- Constant false alarm rate (CFAR) detection (to deal with clutter from the objects of interest)



### Project layout

![layout](./images/layout.png)

1. Configure the FMCW waveform based on the system requirements.
2. Define the range and velocity of target and simulate its displacement.
3. For the same simulation loop process the transmit and receive signal to determine the beat signal
4. Perform Range FFT on the received signal to determine the Range
5. Towards the end, perform the CFAR processing on the output of 2nd FFT to display the target.


### Radar System Requirements

![radar system requirements](./images/radar%20system%20requirements.png)

Max Range and Range Resolution will be considered here for waveform design.

- The sweep bandwidth can be determined according to the range resolution and the sweep slope is calculated using both sweep bandwidth and sweep time.

    B_sweep = c / (2 * d_res), where c : speed of light

- The sweep time can be computed based on the time needed for the signal to travel the unambiguous maximum range. In general, for an FMCW radar system, the sweep time should be at least 5 to 6 times the round trip time. This example uses a factor of 5.5 ( T_chirp = 5.5 * 2 * (R_max / c) ), giving the slope of the chirp signal ( B_sweep / T_chirp ).


### Initial Range and velocity of the Target

You will provide the initial range and velocity of the target. Range cannot exceed the max value of 200m and velocity can be any value in the range of -70 to +70 m/s.



## 2. Target Generation and Detection

![modeling signal propagation for the moving target scenario](./images/modeling%20signal%20propagation%20for%20the%20moving%20target%20scenario.png "Signal Propagation")




## 3. FFT Operation

![1D FFT output](./images/1D%20FFT%20output%20for%20the%20target%20located%20at%20110%20meters.png "1D FFT output for the target located at 110 meters")

![2D FFT output](./images/2D%20FFT%20output%20-%20Range%20Doppler%20map.png "2D FFT output - Range Doppler map")

1. Implement the 1D FFT on the Mixed Signal
2. Reshape the vector into Nr*Nd array.
3. Run the FFT on the beat signal along the range bins dimension (Nr)
4. Normalize the FFT output.
5. Take the absolute value of that output.
6. Keep one half of the signal
7. Plot the output
8. There should be a peak at the initial position of the target






## 4. 2D CFAR

![2D CFAR output](./images/2D%20CFAR%20output.png "output of the 2D CFAR process")

1. Determine the number of Training cells for each dimension. Similarly, pick the number of guard cells.
2/ Slide the cell under test across the complete matrix. Make sure the CUT has margin for Training and Guard cells from the edges.
3. For every iteration sum the signal level within all the training cells. To sum convert the value from logarithmic to linear using db2pow function.
4. Average the summed values for all of the training cells used. After averaging convert it back to logarithmic using pow2db.
5. Further add the offset to it to determine the threshold.
6. Next, compare the signal under CUT against this threshold.
7. If the CUT level > threshold assign it a value of 1, else equate it to 0.

The process above will generate a thresholded block, which is smaller than the Range Doppler Map as the CUTs cannot be located at the edges of the matrix due to the presence of Target and Guard cells. Hence, those cells will not be thresholded.

8. To keep the map size same as it was before CFAR, equate all the non-thresholded cells to 0.



```matlab
% Slide Window through the complete Range Doppler Map

%% Select the number of Training Cells in both the dimensions.
TC_range = 12;      
TC_doppler = 6;     

%% Select the number of Guard Cells in both dimensions around the Cell under test (CUT) for accurate estimation.
GC_range = 6;       
GC_doppler = 4;     

%% Offset the threshold by SNR(signal-to-noise ratio) value in dB.
offset = 18;


% Design a loop such that it slides the CUT across range doppler map
% by giving margins at the edges for training and Guard Cells.
% For every iteration sum the signal level within all the training cells.
% To sum convert the value from logarithmic to linear using db2pow function.
% Average the summed values for all of the training cells used.
% After averaging convert it back to logarithimic using pow2db.
% Further add the offset to it to determine the threshold. 
% Next, compare the signal under CUT with this threshold. 
% If the CUT level > threshold assign it a value of 1, else equate it to 0.

%% Use RMD[x,y] as the matrix from the output of 2D FFT for implementing CFAR.
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
```


## 
