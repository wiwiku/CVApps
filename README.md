# CVApps
Final project for 16-423.

## Real-Time Lane Tracking for Mobile Devices
'''
Jaineel Dalal (jdalal), William Ku (wku)
https://github.com/wiwiku/CVApps
'''

### Summary
Our project aims to provide a more convenient way for the driver to stay within driving lanes - a difficult problem for even seasoned drivers, especially in Pittsburgh - through a projected guiding line that the driver can follow in real-time. We look to efficient Hough transform implementations and hope to achieve near- or over 30 frame-per-second results using OpenGL ES and potentially the GPUImage library. If time permits, we would like to extend the solution to curve representations as well.

### Background
This project takes advantage of the available line detection algorithms in OpenGL ES and GPUImage. We are interested in exploiting the results presented in [1,2,3,4] to implement real-time mobile applications. From some initial research, we see that the naive usage of Hough transform in OpenCV will not allow real-time processing [5]. With the aforementioned technologies, real-time results may be possible.

### Challenges
The line detection algorithms (namely, Hough transform) in OpenCV is too slow for real-time. This poses a challenge since the driver needs real-time guidance in real world driving situations. We hope to discover a more efficient approach or an alternative solution for this mobile application.

### Requirements
PLAN TO ACHIEVE:
- Detection of the left and right lane markers that belong to the driver’s lane;
- Extraction of the left and right lane markers away from other detected lines, if any;
- Projection of visual marker for the driver’s guidance.

HOPE TO ACHIEVE
- Apply the planned requirements to curves (in turning situations);
- Pre-driving calibration to understand the vehicle side extensions;
- Projection of the side limits for staying in the current lane.

### Success Metrics
For validation, we measure the performance of our application against available driving videos (from online sources, etc.). Finally, we would like to test the application in extremely controlled (for safety) driving scenarios. A video of the application running in real-time (with stock footage or in a car) and displaying the functionalities specified by the requirements will validate the success of this project.

### Project Feasibility
The scope of the project is determined with the limited time resources in mind. We are confident that we can achieve the required functionalities, possibly with cushion time for extra validation testing or adding desired features. The detailed project roadmap is shown in the next section.

### Schedule
Week of 11/9
Jaineel: Test Hough transform on OpenGL ES
William: Test Hough transform on GPUImage

Week of 11/16
Jaineel: Implement lane marker filtering
William: Integrate video feed and line detection

Week of 11/23*
Jaineel: Project visual guidance marker
William: Project visual guidance marker

Week of 11/30
Jaineel: Integration testing
William: Integration testing

Week of 12/7
Jaineel: Reporting
William: Reporting

* Denotes light workload week for time cushion and holidays

### References
[1] Abdulhakam.AM.Assidiq, Othman O. Khalifa, Md. Rafiqul Islam, Sheroz Khan : Real time Lane Detection for Autonomous Vehicles, International Conference on Computer and Communication Engineering, 2008
[2] Mohamed Aly : Real time detection of Lane Markers in Urban Streets, IEEE Intelligent Vehicles Symposium, 2008
[3] Feixiang Ren, Jinsheng Huang, Mutsuhiro Terauchi, Ruyi Jiang, and Reinhard Klette: Lane Detection on the iPhone
[4] Jiayong Deng, Youngjoon Han: A Real-time System of Lane Detection and Tracking Based on Optimized RANSAC B-Spline Fitting, RACS’13
[5] https://github.com/BradLarson/GPUImage/issues/309

