# Boxify

This is an ARKit project that demonstrates drawing out a 3-dimensional box in the world, which can be rotated and resized from each of its faces.

### Requirements
1. XCode 9 (or newer)
2. [One of the following devices (or newer) running iOS 11 (or newer)](http://wccftech.com/heres-the-list-of-iphone-models-compatible-with-the-arkit-in-ios-11/):
    - The 2017 9.7-inch iPad
    - All three variants of the iPad Pro
    - iPhone 7 Plus
    - iPhone 7
    - iPhone 6s Plus
    - iPhone 6s
    - iPhone SE

### Instructions
0. Build the project and launch it on your device. Grant it permission to access the camera.
1. Move the device around until ARKit detects a suitable horizontal surface - this will appear as a flat blue rectangle.
2. Tap somewhere inside the blue rectangle and drag to begin pulling out a straight line from that point.
3. Release your finger to confirm the line.
4. Drag the line to either side to pull it out into a 2-dimensional rectangle.
5. Tap within the rectangle and drag to pull it out into a 3-dimensional box.
6. Tap and drag on any face of the box to resize the box from that face.
7. Put two fingers on the screen and twist to rotate the box.
8. Double-tap on the screen to delete the box and start again.

### Acknowledgements

This project uses code from Apple's [ARKitExample sample project](https://developer.apple.com/arkit/). It evolved from a Shopify hackdays project between @paige.sun, @ignacio.chiazzo and @alun.bestor.
