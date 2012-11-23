import 'dart:html';
import 'nyx/lib.dart' as nyx;
import 'nyx/lib.dart' show GL;

// external dependencies
import 'package:vector_math/vector_math_browser.dart';

///
/// ### hello, cube ###
/// 
/// Based on: Getting started with WebGL
///   https://developer.mozilla.org/en-US/docs/WebGL/Getting_started_with_WebGL
/// 
/// Triangles are ok, we can make squares and other shapes, but what we want is
/// something 3D.
///
/// For clarity of the code I started using GL as an alias to 
/// WebGLRenderingContext; makes everything so much clearer. Note that it is
/// not interchangable; it only offers aliases to common constants.
/// 
/// The library (nyx) is also now imported directly so names are used with out
/// the "nyx." prefix. Again for clarity of the code.
///

/**
 * ...
 */
void program(nyx.Viewport viewport) {
  
  // add vertex shader
  viewport.addVertexShader(
    source:
      """
      attribute vec3 aVertexPosition;
      attribute vec4 aVertexColor;
    
      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;
      
      varying lowp vec4 vColor;

      void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
        vColor = aVertexColor;
      }
      """
  );
  
  /// uPMatrix is the "perspective matrix", and uMVMatrix is the "model view 
  /// matrix", more on these later in the example, but basically they're used 
  /// to make sure things look realistic.
  
  // add a fragment shader
  viewport.addFragmentShader(
    source:
      """
      varying lowp vec4 vColor;
      
      void main() {
        gl_FragColor = vColor;
      }
      """
  );
  
  /// Note the variable vColor also appears in the Vertex shader; it is 
  /// technically the same variable and contains the value set in the fragment
  /// shader above. As mentioned in example-1 it is a global input/output 
  /// variable.
  
  /// Before moving on we're just going to retrieve pointers to the attributes
  /// defined above for future reference; again they are globals so they are
  /// actually the same for both shaders
  
  int aVertexPosition, aVertexColor;
  WebGLUniformLocation uMVMatrix, uPMatrix;
  
  // schedule them to get populated before animation starts
  viewport.preprocessor(({WebGLRenderingContext gl, WebGLProgram program}) {
    
    aVertexPosition = gl.getAttribLocation(program, "aVertexPosition");
    gl.enableVertexAttribArray(aVertexPosition);
    
    aVertexColor = gl.getAttribLocation(program, "aVertexColor");
    gl.enableVertexAttribArray(aVertexColor);
    
    uPMatrix = gl.getUniformLocation(program, "uPMatrix");
    uMVMatrix = gl.getUniformLocation(program, "uMVMatrix");
    
  });
  
  /// "u" and "a" are hungarian notation for uniform and attribute :) 
  /// the convention works well when working with globals all the time
  
  viewport.painter(({WebGLRenderingContext gl, WebGLProgram program, double aspect, num time}) {
    
    // Welcome to the frame. You have a budget of 14 millisecond to do all your 
    // black glyph magic. Well, technically 16ms, but browsers have a 2ms frame 
    // tax (usually), so make do with 14ms. :D 
    
    /// we'll be using good old gray background again
    gl.clearColor(0.9, 0.9, 0.9, 1.0);
    
    // time for some depth
    gl.enable(GL.DEPTH_TEST);
    gl.depthFunc(GL.LEQUAL);  // "near things obscure far things"
    
    /// From opengl wiki:
    ///
    ///   The Depth Test is a per-sample operation performed conceptually after 
    ///   the Fragment Shader. The output depth is tested against the depth of 
    ///   the sample being written to. If the test fails, the fragment 
    ///   is discarded.
    ///
    /// So it's basically checking if fragments (ie. pixels) appear on the same
    /// spot and discarding the ones that closer to the viewer (ie. smaller in
    /// value, as per LEQUAL - which stands for "lower or equal").
    

    /// -----------------------------------------------------------------------
    /// Time to create a shape...
    
    // First we need to define all the points...
    
    var vertices = [
                    
      /// A cube is defined by 6 faces.
      /// Each face is defined by 4 points.                    
                    
      // Front
        -1.0, -1.0,  1.0,
         1.0, -1.0,  1.0,
         1.0,  1.0,  1.0,
        -1.0,  1.0,  1.0,
        
      // Back 
        -1.0, -1.0, -1.0,
        -1.0,  1.0, -1.0,
         1.0,  1.0, -1.0,
         1.0, -1.0, -1.0,
        
      // Top 
        -1.0,  1.0, -1.0,
        -1.0,  1.0,  1.0,
         1.0,  1.0,  1.0,
         1.0,  1.0, -1.0,
      
      // Bottom
        -1.0, -1.0, -1.0,
         1.0, -1.0, -1.0,
         1.0, -1.0,  1.0,
        -1.0, -1.0,  1.0,
        
      // Right 
         1.0, -1.0, -1.0,
         1.0,  1.0, -1.0,
         1.0,  1.0,  1.0,
         1.0, -1.0,  1.0,
        
      // Left 
        -1.0, -1.0, -1.0,
        -1.0, -1.0,  1.0,
        -1.0,  1.0,  1.0,
        -1.0,  1.0, -1.0
      
    ];
    
    /// We create a buffer and dump our stuff into it.
    
    WebGLBuffer vertex_buffer = gl.createBuffer(); // create it
    gl.bindBuffer(GL.ARRAY_BUFFER, vertex_buffer); // select it
    gl.bufferData                                  // populate it
      (
        GL.ARRAY_BUFFER, 
        new Float32Array.fromList(vertices), 
        GL.STATIC_DRAW
      );
    
    /// Note the last parameter is a "hint".
    ///
    /// DRAW there means:
    ///   The data store contents are modified by the application, and used 
    ///   as the source for GL drawing and image specification commands.
    /// 
    /// Normally you'd also have READ and COPY in place of DRAW, but not in 
    /// webgl. Or at least I think so going by how there's no corresponding 
    /// constants in the spec. So really only the first part (ie. frequency of 
    /// access) is important, which we can have as:
    ///
    ///  DYNAMIC 
    ///    modified repeatedly
    ///    used many times
    ///
    ///  STATIC 
    ///    modified once 
    ///    used many times
    ///
    ///  STREAM
    ///    modified once
    ///    used at most a few times
    /// 
    /// So posible values are: DYNAMIC_DRAW, STATIC_DRAW and STREAM_DRAW :) 
    ///
    /// But again, this works as merely a hint, according to the spec.
    
    // Next we difine the colors... (for the points)
    
    var face_colors = [
                  
        [ 1.0,  1.0,  1.0,  1.0], // Front  : white
        [ 1.0,  0.0,  0.0,  1.0], // Back   : red
        [ 0.0,  1.0,  0.0,  1.0], // Top    : green
        [ 0.0,  0.0,  1.0,  1.0], // Bottom : blue
        [ 1.0,  1.0,  0.0,  1.0], // Right  : yellow
        [ 1.0,  0.0,  1.0,  1.0]  // Left   : purple
        
      ];
    
    var colors = [];
    face_colors.forEach((List color) {
      for (var i = 0; i < 4; i++) {
        colors.addAll(color);
      }
    });
    
    /// The reason for the loops above is that while there are 6 faces, and we
    /// want the color on the faces, the color is set on the points and there
    /// are 6faces * 4points = 24vertexes that need to be set. Hence the loop. 
    
    /// And again we create another buffer and dump our stuff into it.
    
    WebGLBuffer color_buffer = gl.createBuffer();  // create it
    gl.bindBuffer(GL.ARRAY_BUFFER, color_buffer);  // select it
    gl.bufferData                                  // populate it
      (
        GL.ARRAY_BUFFER, 
        new Float32Array.fromList(colors), 
        GL.STATIC_DRAW
      );
    
    // finally we difine how the points are used to create the shape
    
    /// Basically we group the points into triangles and do 3D "hello, triangle"
    /// 12 times. 2 triangles = 1 face. To do this we use an element buffer.
    /// The element buffer needs to know which points (defined by their index)
    /// we're using to create the triangle shapes. It all works out to this:
    
    var elements = [
                    
    // triangle_1      triangle_2                      
       0,  1,  2,      0,  2,  3,  // front
       4,  5,  6,      4,  6,  7,  // back
       8,  9,  10,     8,  10, 11, // top
       12, 13, 14,     12, 14, 15, // bottom
       16, 17, 18,     16, 18, 19, // right
       20, 21, 22,     20, 22, 23  // left
       
     ];
    
    /// And again we need to send it all off to the GPU
    
    WebGLBuffer element_buffer = gl.createBuffer();         // create it
    gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, element_buffer); // select it
    gl.bufferData                                           // populate it
      (
        GL.ELEMENT_ARRAY_BUFFER, 
        new Uint16Array.fromList(elements), 
        GL.STATIC_DRAW
      );
    
    /// Take care, the target is ELEMENT_ARRAY_BUFFER this time and it's using 
    /// Uint16Array because we're not passing in floats. :) Everything else is
    /// the same.
    
    
    /// ----------------------------------------------------------------------
    /// Clear everything...
    
    gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
    
    /// Possible values for clear here are COLOR_BUFFER_BIT, DEPTH_BUFFER_BIT,
    /// and STENCIL_BUFFER_BIT; stencil is used to hide things (to give a basic
    /// explanation)
    
    /// ----------------------------------------------------------------------
    /// Ready for some pain! View frustrum...
    /// http://en.wikipedia.org/wiki/Viewing_frustum
    
    /// First we set up the necesary matrix'es
    
    mat4 perspective_matrix = makePerspective
      (
        45.0,   // field of view
        aspect, // aspect ratio (with / height)
        0.1,    // near plane
        100.0   // far plane
      );
    
    // http://3dengine.org/Modelview_matrix
    mat4 modelview_matrix = new mat4.identity();
    
    // put in the cube points
    gl.bindBuffer(GL.ARRAY_BUFFER, vertex_buffer);
    gl.vertexAttribPointer(aVertexPosition, 3, GL.FLOAT, false, 0, 0);
    
    // put in the point colors
    gl.bindBuffer(GL.ARRAY_BUFFER, color_buffer);
    gl.vertexAttribPointer(aVertexColor, 4, GL.FLOAT, false, 0, 0);
    
    // draw it!
    gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, element_buffer);
    gl.uniformMatrix4fv(uPMatrix, false, perspective_matrix.copyAsArray());
    gl.uniformMatrix4fv(uMVMatrix, false, modelview_matrix.copyAsArray());
    gl.drawElements(GL.TRIANGLES, 36, GL.UNSIGNED_SHORT, 0);
    
  });

  // run the entire thing; don't forget to cross your fingers
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
    query('[data-nyx-viewport]').Text 
      = nyx.Exception_MissingFeature.HELP_MESSAGE;
  }
}

