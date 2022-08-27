### Astrid
A relativistic ray tracing server and end-user application built on Astray.

### Building
- Build [Astray](https://github.com/acdemiralp/astray). Recommendation: Set `-DASTRAY_DEVICE_SYSTEM=CUDA` for better local performance.
- Run `bootstrap.[bat|sh]`. This will install the remaining dependencies and create the project under the `./build` directory.
- Run cmake on the `./build` directory.
- Point `astray_DIR` to the build directory of Astray.
- Configure, generate, build.

### Installation
- Executables are available for download [here](https://github.com/acdemiralp/astrid/releases).

### Quick Tutorial
- Run astrid.exe.
- Click the File menu and select "Connect to Local". This will create and connect to a local Astrid rendering server.
- In the "Integration Parameters" toolbox, choose the "Schwarzschild" metric.
- Click the "Render" button on the bottom left.
- Adjust the parameters and repeat.

### Notes
- The screen size has an effect on performance. More the pixels, slower the rendering.
- Interactive rendering is possible even on a local server.
  - Resize the window so that the viewport is approximately 320x240.
  - In the "Observer Parameters" toolbox, untoggle "Look at Origin". This will allow you to rotate using the mouse.
  - Toggle the "Auto Render" on the bottom left.
  - Use the keyboard (WASD) and the mouse to interactively browse the metric.
