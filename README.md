---
title : "SFND-project-04-radar_target_generation_and_detection"
category :
    - SFND
tag : 
    - matlab
    - https://www.udacity.com/course/sensor-fusion-engineer-nanodegree--nd313
toc: true  
toc_sticky: true 
use_math : true
---



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

<p><span class="MathJax_Preview" style="color: inherit; display: none;"></span><span class="MathJax" id="MathJax-Element-1-Frame" tabindex="0" data-mathml="<math xmlns=&quot;http://www.w3.org/1998/Math/MathML&quot;><msub><mi>B</mi><mrow class=&quot;MJX-TeXAtom-ORD&quot;><mtext>sweep</mtext></mrow></msub><mo>=</mo><mfrac><mi>c</mi><mrow><mo stretchy=&quot;false&quot;>(</mo><mn>2</mn><mo>&amp;#x22C5;</mo><msub><mi>d</mi><mrow class=&quot;MJX-TeXAtom-ORD&quot;><mtext>res</mtext></mrow></msub></mrow></mfrac></math>" role="presentation" style="position: relative;"><nobr aria-hidden="true"><span class="math" id="MathJax-Span-1" style="width: 7.212em; display: inline-block;"><span style="display: inline-block; position: relative; width: 6.193em; height: 0px; font-size: 116%;"><span style="position: absolute; clip: rect(1.569em, 1006.19em, 3.098em, -999.998em); top: -2.388em; left: 0em;"><span class="mrow" id="MathJax-Span-2"><span class="msubsup" id="MathJax-Span-3"><span style="display: inline-block; position: relative; width: 2.627em; height: 0px;"><span style="position: absolute; clip: rect(3.215em, 1000.75em, 4.116em, -999.998em); top: -3.995em; left: 0em;"><span class="mi" id="MathJax-Span-4" style="font-family: MathJax_Math-italic;">B</span><span style="display: inline-block; width: 0px; height: 3.999em;"></span></span><span style="position: absolute; top: -3.838em; left: 0.746em;"><span class="texatom" id="MathJax-Span-5"><span class="mrow" id="MathJax-Span-6"><span class="mtext" id="MathJax-Span-7" style="font-size: 70.7%; font-family: MathJax_Main;">sweep</span></span></span><span style="display: inline-block; width: 0px; height: 3.999em;"></span></span></span></span><span class="mo" id="MathJax-Span-8" style="font-family: MathJax_Main; padding-left: 0.276em;">=</span><span class="mfrac" id="MathJax-Span-9" style="padding-left: 0.276em;"><span style="display: inline-block; position: relative; width: 2em; height: 0px; margin-right: 0.12em; margin-left: 0.12em;"><span style="position: absolute; clip: rect(3.568em, 1000.32em, 4.116em, -999.998em); top: -4.387em; left: 50%; margin-left: -0.155em;"><span class="mi" id="MathJax-Span-10" style="font-size: 70.7%; font-family: MathJax_Math-italic;">c</span><span style="display: inline-block; width: 0px; height: 3.999em;"></span></span><span style="position: absolute; clip: rect(3.333em, 1001.84em, 4.312em, -999.998em); top: -3.564em; left: 50%; margin-left: -0.938em;"><span class="mrow" id="MathJax-Span-11"><span class="mo" id="MathJax-Span-12" style="font-size: 70.7%; font-family: MathJax_Main;">(</span><span class="mn" id="MathJax-Span-13" style="font-size: 70.7%; font-family: MathJax_Main;">2</span><span class="mo" id="MathJax-Span-14" style="font-size: 70.7%; font-family: MathJax_Main;">⋅</span><span class="msubsup" id="MathJax-Span-15"><span style="display: inline-block; position: relative; width: 1.021em; height: 0px;"><span style="position: absolute; clip: rect(3.372em, 1000.36em, 4.116em, -999.998em); top: -3.995em; left: 0em;"><span class="mi" id="MathJax-Span-16" style="font-size: 70.7%; font-family: MathJax_Math-italic;">d<span style="display: inline-block; overflow: hidden; height: 1px; width: 0.002em;"></span></span><span style="display: inline-block; width: 0px; height: 3.999em;"></span></span><span style="position: absolute; top: -3.877em; left: 0.355em;"><span class="texatom" id="MathJax-Span-17"><span class="mrow" id="MathJax-Span-18"><span class="mtext" id="MathJax-Span-19" style="font-size: 50%; font-family: MathJax_Main;">res</span></span></span><span style="display: inline-block; width: 0px; height: 3.999em;"></span></span></span></span></span><span style="display: inline-block; width: 0px; height: 3.999em;"></span></span><span style="position: absolute; clip: rect(0.864em, 1002em, 1.178em, -999.998em); top: -1.291em; left: 0em;"><span style="display: inline-block; overflow: hidden; vertical-align: 0em; border-top: 1.5px solid; width: 2em; height: 0px;"></span><span style="display: inline-block; width: 0px; height: 1.06em;"></span></span></span></span></span><span style="display: inline-block; width: 0px; height: 2.392em;"></span></span></span><span style="display: inline-block; overflow: hidden; vertical-align: -0.725em; border-left: 0px solid; width: 0px; height: 1.593em;"></span></span></nobr><span class="MJX_Assistive_MathML" role="presentation"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mi>B</mi><mrow class="MJX-TeXAtom-ORD"><mtext>sweep</mtext></mrow></msub><mo>=</mo><mfrac><mi>c</mi><mrow><mo stretchy="false">(</mo><mn>2</mn><mo>⋅</mo><msub><mi>d</mi><mrow class="MJX-TeXAtom-ORD"><mtext>res</mtext></mrow></msub></mrow></mfrac></math></span></span><script type="math/tex" id="MathJax-Element-1">B_\textrm{sweep} = \frac {c} {(2 \cdot d_\textrm{res}}</script>, <span class="MathJax_Preview" style="color: inherit; display: none;"></span><span class="MathJax" id="MathJax-Element-2-Frame" tabindex="0" data-mathml="<math xmlns=&quot;http://www.w3.org/1998/Math/MathML&quot;><mi>c</mi></math>" role="presentation" style="position: relative;"><nobr aria-hidden="true"><span class="math" id="MathJax-Span-20" style="width: 0.511em; display: inline-block;"><span style="display: inline-block; position: relative; width: 0.433em; height: 0px; font-size: 116%;"><span style="position: absolute; clip: rect(1.804em, 1000.43em, 2.471em, -999.998em); top: -2.349em; left: 0em;"><span class="mrow" id="MathJax-Span-21"><span class="mi" id="MathJax-Span-22" style="font-family: MathJax_Math-italic;">c</span></span><span style="display: inline-block; width: 0px; height: 2.353em;"></span></span></span><span style="display: inline-block; overflow: hidden; vertical-align: -0.043em; border-left: 0px solid; width: 0px; height: 0.639em;"></span></span></nobr><span class="MJX_Assistive_MathML" role="presentation"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>c</mi></math></span></span><script type="math/tex" id="MathJax-Element-2">c</script> : speed of light</p>

- The sweep time can be computed based on the time needed for the signal to travel the unambiguous maximum range. In general, for an FMCW radar system, the sweep time should be at least 5 to 6 times the round trip time. This example uses a factor of 5.5

    $T_\textrm{chirp} = \frac {5.5 \cdot 2 \cdot R_\textrm{max}} {c}$

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

![2D CFAR output](./images/2D%20CFAR%20output.png "output of the 2D CFAR process")


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