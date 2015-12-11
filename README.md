# Real-Time Lane Tracking for Mobile Devices
Final project for 16-423 Fall 2015. <br>
Jaineel Dalal (*jdalal*), William Ku (*wku*) <br>
<i>(Updated 12/11/2015)</i>

### Summary
Our project aims to provide a more convenient way for the driver to stay within driving lanes - a difficult problem for even seasoned drivers, especially in Pittsburgh - through a projected guiding line that the driver can follow in real-time. We look to efficient Hough transform implementations and hope to achieve near- or over 30 frame-per-second results using OpenGL ES and potentially the GPUImage library. If time permits, we would like to extend the solution to curve representations as well.

### Background
This project takes advantage of the available line detection algorithms in OpenGL ES and GPUImage. We are interested in exploiting the results presented in [1,2,3,4] to implement real-time mobile applications. From some initial research, we see that the naive usage of Hough transform in OpenCV will not allow real-time processing [5]. With the aforementioned technologies, real-time results may be possible.

### Challenges
The line detection algorithms (namely, Hough transform) in OpenCV is too slow for real-time. This poses a challenge since the driver needs real-time guidance in real world driving situations. We hope to discover a more efficient approach or an alternative solution for this mobile application.

### Requirements
PLAN TO ACHIEVE:
- Detection of the left and right lane markers that belong to the driver’s lane; [<b>Achieved</b>]
- Extraction of the left and right lane markers away from other detected lines, if any;  [<b>Achieved</b>]
- Projection of visual marker for the driver’s guidance.  [<b>Achieved</b>]

HOPE TO ACHIEVE
- Apply the planned requirements to curves (in turning situations); [<b>Did not achieve</b>]
- Pre-driving calibration to understand the vehicle side extensions; [<b>Did not achieve</b>]
- Projection of the side limits for staying in the current lane. [<b>Did not achieve</b>]

### Success Metrics
For validation, we measure the performance of our application against available driving videos (from online sources, etc.). Finally, we would like to test the application in extremely controlled (for safety) driving scenarios. A video of the application running in real-time (with stock footage or in a car) and displaying the functionalities specified by the requirements will validate the success of this project.

### Project Feasibility
The scope of the project is determined with the limited time resources in mind. We are confident that we can achieve the required functionalities, possibly with cushion time for extra validation testing or adding desired features. The detailed project roadmap is shown in the next section.

### Schedule
| Week of | Jaineel | William | Status |
|---------|---------|---------|---------|
| 11/9 | Test Hough transform on OpenGL ES | Test Hough transform on GPUImage | On-time
| 11/16 | Implement lane marker filtering | Integrate video feed and line detection | Behind
| 11/23* | Implement lane marker filtering | Implement lane marker filtering | Behind
| 11/26 | Project visual guidance marker | Compute center line | Behind
| 11/30 | Benchmarking | Integration testing | Behind
| 12/3 | Real-time testing | Real-time testing | On-time
| 12/7 | Reporting | Reporting | On-time
* Denotes light workload week for time cushion and holidays

### References
[1] Abdulhakam.AM.Assidiq, Othman O. Khalifa, Md. Rafiqul Islam, Sheroz Khan : Real time Lane Detection for Autonomous Vehicles, International Conference on Computer and Communication Engineering, 2008 <br>
[2] Mohamed Aly : Real time detection of Lane Markers in Urban Streets, IEEE Intelligent Vehicles Symposium, 2008 <br>
[3] Feixiang Ren, Jinsheng Huang, Mutsuhiro Terauchi, Ruyi Jiang, and Reinhard Klette: Lane Detection on the iPhone <br>
[4] Jiayong Deng, Youngjoon Han: A Real-time System of Lane Detection and Tracking Based on Optimized RANSAC B-Spline Fitting, RACS’13 <br>
[5] https://github.com/BradLarson/GPUImage/issues/309

