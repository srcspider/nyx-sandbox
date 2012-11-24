import 'dart:html';
import 'nyx/lib.dart' as nyx;
import 'nyx/lib.dart' show GL;

///
/// ### The Boilerplate ### 
///
/// Based on: http://martinsikora.com/dart-webgl-simple-demo
/// Original author: martinsik@github.com
///
/// The code displays a blinking triangle. In this case the webgl code isn't 
/// very important, rather the [nyx.Viewport] class and logistics required to 
/// get webgl running is the point of the example.
///
/// I had to do this first to get a proper setup for later examples, ie. nice
/// way to load shaders, nice way to setup the viewport, simply way to write 
/// the program; while at the same time not sacrificing too much flexibility by
/// dealing away with the boilerplate code.
///
/// Skip to example-1 if you've already wrestled yourself with this.
///
/// If you want to use the struacture see: sandbox.dart
///

/**
 * ...
 */
void program(nyx.Viewport viewport) {
  
  // first we add a fragment shader
  viewport.addFragmentShader(
    source:
      """
      precision mediump float;
      uniform vec4 uColor;
      void main() {
        gl_FragColor = uColor;
      }
      """
  );
  
  /// Explanation
  /// 
  ///  - "precision mediump float" suggests to the hardware the precition for
  ///    all floats (vec4 in this case). "mediump" = "medium precition" there's
  ///    also "lowp" and "highp"; just don't use highp withouth a C style 
  ///    compile time test block to fallback to mediump if it's not supported,
  ///    ie. #ifdef GL_FRAGMENT_PRECISION_HIGH followed by #else and #endif
  ///
  ///  - "uniform" there says "this is read-only global variable"; whereby 
  ///    global there stands to mean it's available in both the vertex and 
  ///    fragment shader -- in this case it's used for passing in a color; you 
  ///    can have at least 8 of these; more depending on hardware
    
  // next we add a vertex shader; the order of these is unimportant, the 
  // fragment shader could have come first -- in our case this is second since
  // it helps with the explanation blocks
  viewport.addVertexShader(
    source:
      """
      attribute vec2 aPosition;
      void main() {
        gl_Position = vec4(aPosition, 0, 1);
      }
      """
  );
  
  /// Explanation
  ///
  ///  - "attribute" there means it's going to be passed as an input; attributes
  ///    are essentially "uniforms" that apply only to the vertex shader; as 
  ///    with uniforms you can have at least 8 of these; more depending on 
  ///    hardware
  ///
  ///  - "vec2" means it's a vector of 2 elements (ie. unidimentional array of 
  ///    two elements)
  ///
  ///  - "vec4(aPosition, 0, 1)" there means "create a vector of 4 elements 
  ///    (x, y, z, q) by first using the two elements in the vec2 "aPosition" 
  ///    for x and y and then 0 and 1 for z and q. It's essentially just a fancy
  ///    constructor. In this case the input aPosition is converted to the 
  ///    desired 4 point position in space that's used by the hardware to render 

  /// There is a 3rd type called a "varying" which is used for both input and
  /// output in the vertex and fragment shader; so obviously unlike uniform 
  /// it's not read-only -- same limitation of 8 applies.

  // some variables used in the animation
  double foobar   = 0.5;
  int    itemSize = 2;
  bool   adding   = true;

  viewport.painter(({WebGLRenderingContext gl, WebGLProgram program, num aspect, num time}) {
    
    /// the following is practically copy/paste of the original, if you're 
    /// interested it should be simple enough to understand if you got the 
    /// explanation on what the shader code was up to above; at this point I was
    /// only focusing in the function and method call this code is sitting in
    /// so didn't even read it =P
    
    /// If you need help understanding the code, see example-1, then come back;
    /// example-1 is just about drawing a simple triangle
    
    // genereate 3 points (that's 6 items in 2D space) = 1 polygon
    Float32Array vertices = new Float32Array.fromList(
      [
        -foobar,  foobar * aspect,
         foobar,  foobar * aspect,
         foobar, -foobar * aspect
      ]
    );

    gl.bindBuffer(GL.ARRAY_BUFFER, gl.createBuffer());
    gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, vertices, WebGLRenderingContext.STATIC_DRAW);

    int numItems = vertices.length ~/ itemSize;

    gl.clearColor(0.9, 0.9, 0.9, 1);
    gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT);

    // set color
    WebGLUniformLocation uColor = gl.getUniformLocation(program, "uColor");
    // as defined in fragment shader source code, color is vector of 4 items
    gl.uniform4fv(uColor, new Float32Array.fromList([foobar, foobar, 0.0, 1.0]));

    // set position
    // WebGL knows we want to use 'vertices' for this because
    // we called bindBuffer above (it's maybe a bit unclear but)
    // For more info: http://www.netmagazine.com/tutorials/get-started-webgl-draw-square
    int aPosition = gl.getAttribLocation(program, "aPosition");
    gl.enableVertexAttribArray(aPosition);
    gl.vertexAttribPointer(aPosition, itemSize, WebGLRenderingContext.FLOAT, false, 0, 0);

    // draw it!
    gl.drawArrays(WebGLRenderingContext.TRIANGLES, 0, numItems);

    // change color and move the triangle a little bit
    foobar += (adding ? 1 : -1) * foobar / 100;

    if (foobar > 0.9) {
      adding = false;
    }
    else if (foobar < 0.2) {
      adding = true;
    }
  });

  viewport.execute();
}

/**
 * Boilerplate...
 */
void main() {
  try {
    
    // we create a viewport (canvas, various html, etc); in this instance it's 
    // only a canvas and frame per second (fps) counter
    nyx.Viewport viewport = new nyx.Viewport(
        container:
          query('[data-nyx-viewport]'),
        showFPS: true
    );
    
    // feed the viewport into our program and let it do magic
    program(viewport);
  }
  on nyx.Exception_MissingFeature catch(e) {
    query('[data-nyx-viewport]').text
       = nyx.Exception_MissingFeature.HELP_MESSAGE;
  }
}

