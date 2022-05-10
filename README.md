# Udacity-Sensor_Fusion_Nanodegree_Program-project-04-Radar_Target_Generation_and_Detection




## Project Overview

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

    $B_\textrm{sweep} = \frac {c} {(2 \cdot d_\textrm{res} $}, $c$ : speed of light

- The sweep time can be computed based on the time needed for the signal to travel the unambiguous maximum range. In general, for an FMCW radar system, the sweep time should be at least 5 to 6 times the round trip time. This example uses a factor of 5.5

    $T_\textrm{chirp} = \frac {5.5 \cdot 2 \cdot R_\textrm{max}} {c} $

    , giving the slope of the chirp signal($\frac {B_\textrm{sweep}} {T_\textrm{chirp}}$).


### Initial Range and velocity of the Target

You will provide the initial range and velocity of the target. Range cannot exceed the max value of 200m and velocity can be any value in the range of -70 to + 70 m/s.



## Target Generation and Detection

![modeling signal propagation for the moving target scenario](./images/modeling%20signal%20propagation%20for%20the%20moving%20target%20scenario.png "Signal Propagation")


### Simulation Loop






## FFT Operation

1. Implement the 1D FFT on the Mixed Signal
2. Reshape the vector into Nr*Nd array.
3. Run the FFT on the beat signal along the range bins dimension (Nr)
4. Normalize the FFT output.
5. Take the absolute value of that output.
6. Keep one half of the signal
7. Plot the output
8. There should be a peak at the initial position of the target


![1D FFT output](./images/1D%20FFT%20output%20for%20the%20target%20located%20at%20110%20meters.png "1D FFT output for the target located at 110 meters")

![2D FFT output](./images/2D%20FFT%20output%20-%20Range%20Doppler%20map.png "2D FFT output - Range Doppler map")




## 2D CFAR

1. Determine the number of Training cells for each dimension. Similarly, pick the number of guard cells.
2/ Slide the cell under test across the complete matrix. Make sure the CUT has margin for Training and Guard cells from the edges.
3. For every iteration sum the signal level within all the training cells. To sum convert the value from logarithmic to linear using db2pow function.
4. Average the summed values for all of the training cells used. After averaging convert it back to logarithmic using pow2db.
5. Further add the offset to it to determine the threshold.
6. Next, compare the signal under CUT against this threshold.
7. If the CUT level > threshold assign it a value of 1, else equate it to 0.

The process above will generate a thresholded block, which is smaller than the Range Doppler Map as the CUTs cannot be located at the edges of the matrix due to the presence of Target and Guard cells. Hence, those cells will not be thresholded.

8. To keep the map size same as it was before CFAR, equate all the non-thresholded cells to 0.

![2D CFAR output](./images/2D%20FFT%20output%20-%20Range%20Doppler%20map.png "output of the 2D CFAR process")


### Selection of Training, Guard cells and offset

The values below were hand selected. I chose a rectangular window with the major dimension along the range cells. This produced better filtered results from the given RDM. Choosing the right value for offset was key to isolating the simulated target and avoiding false positives. Finally, I precalculated the N_training value to avoid a performance hit in the nested loop.

```matlab
% Select the number of training cells in both the dimensions.
Tr = 12;  % Training (range dimension)
Td = 3;  % Training cells (doppler dimension)

% Select the number of guard cells in both dimensions around the Cell Under 
% Test (CUT) for accurate estimation.
Gr = 4;  % Guard cells (range dimension)
Gd = 1;  % Guard cells (doppler dimension)

% Offset the threshold by SNR value in dB
offset = 15;

% Calculate the total number of training and guard cells
N_guard = (2 * Gr + 1) * (2 * Gd + 1) - 1;  % Remove CUT
N_training = (2 * Tr + 2 * Gr + 1) * (2 * Td + 2 * Gd + 1) - (N_guard + 1);
```



### Implementation steps for the 2D CFAR process

The 2D constant false alarm rate (CFAR), when applied to the results of the 2D FFT, uses a dynamic threshold set by the noise level in the vicinity of the cell under test (CUT). The key steps are as follows:

1. Loop over all cells in the range and doppler dimensions, starting and ending at indices which leave appropriate margins
2. Slice the training cells (and exclude the guard cells) surrounding the CUT
3. Convert the training cell values from decibels (dB) to power, to linearize
4. Find the mean noise level among the training cells
5. Convert this average value back from power to dB
6. Add the offset (in dB) to set the dynamic threshold
7. Apply the threshold and store the result in a binary array of the same dimensions as the range doppler map (RDM)

```matlab
for range_index = Tr + Gr + 1 : Nr/2 - Tr - Gr
    for doppler_index = Td + Gd + 1 : Nd - Td - Gd
        
        % ...
        % ... calculate threshold for this CUT
        % ...
        
        if RDM(range_index, doppler_index) > threshold
            CFAR(range_index, doppler_index) = 1;
        end
    end
end
```

There is potential room for performance improvement though parallelization. These sliding window type operations may be expressed as a convolution.




### Steps taken to suppress the non-thresholded cells at the edges ????

```matlab
CFAR = zeros(size(RDM));
```

???
In my 2D CFAR implementation, only CUT locations with sufficient margins to contain the entire window are considered. I start with an empty array of zeros, equivalent in size to the RDM array. I then set the indexed locations to one if and only if the threshold is exceeded by the CUT.