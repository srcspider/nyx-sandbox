import 'dart:html';
import 'nyx/lib.dart' as nyx;
import 'nyx/lib.dart' show GL;

///
/// ### hello, triangle ###
/// 
/// Based on: Get started with WebGL: draw a square
///   http://www.netmagazine.com/tutorials/get-started-webgl-draw-square
///
/// Wanted to keep things simple; since square is just 2 triangles, kept this
/// experiment to a classic "hello, triangle". Less variables to edit when 
/// mutating it to see what different paramters such as draw mode do.
///
/// Used this to get a better understanding of how to just draw a frame; the
/// technical details are understandable but seem to just not connect; hence
/// why I wrote the example.
///
/// Probably everyone when they start out wants to draw 3D object like a sphere
/// or a plain, but by god do books and various other technically competent 
/// sources take ages to get there—no suprise why though.
///

/**
 * ...
 */
void program(nyx.Viewport viewport) {
  
  /// the "fragment" shader is essentially in laymen's terms "the texture of 
  /// the stuff you're drawing", basically "fragment" = "pixels" more or less;
  /// we'll just draw everything my favorite color: crimson
  /// The source mentioned at the start has a nice illustration.
  viewport.addFragmentShader(
    source:
      """
      void main() {
        gl_FragColor = vec4(0.863, 0.078, 0.235, 1.0);
      }
      """
  );
  
  /// [gl_FragColor] there is a variable and it is the "return" sort-to-speak
  /// of the main function in the shader; bellow [gl_Position] serves the same 
  /// purpose for the vertex shader
  
  /// the "vertex" shader is "the geomatry of the thing you are drawing", 
  /// "vertex" = math-speak for "point in space"
  viewport.addVertexShader(
    source:
      """
      attribute vec2 aPosition;

      void main() {
        gl_Position = vec4(aPosition, 0.0, 1.0);
      }
      """
  );
  
  /// as explained previously aPosition is a vector of two elements (vec2), so
  /// it's what we provide as input for the x and y coordinates (simple enough) 
  /// the other two values there are in order: depth of field (ie. zIndex in 
  /// css land, obviously it's a float between -1.0 and 1.0 and the last 
  /// parameter is the "homogenous coordinate" which is not important at 
  /// this time
  
  viewport.painter(({WebGLRenderingContext gl, WebGLProgram program, num aspect, num time}) {
   
    // Welcome to the frame. You have a budget of 14 milisecond to do all your 
    // black glyph magic. Well, technically 16ms, but browsers have a 2ms frame 
    // tax (usually), so make do with 14ms. :D
    
    /// let's set the background; yes you have to do it every time, else it will
    /// just reset to default: nonexistent
    gl.clearColor(0.9, 0.9, 0.9, 1.0);
    gl.clear(GL.COLOR_BUFFER_BIT);
    
    /// Explanation
    ///
    ///  - in webgl we specify color via RGBA values, which stands for 
    ///    (red, green, blue, alpha); so (0.0, 0.0, 0.0, 0.0) is black, 
    ///    (1.0, 0.0, 0.0, 1.0) is red, (1.0, 1.0, 1.0, 1.0) is white, etc.
    ///
    ///  - the first instruction [clearColor] sets the color to what we want, but
    ///    if we only do that you won't see any difference; that's because webgl
    ///    needs to be told we're done and that it should re-render. By calling
    ///    the [clear] method we thus tell webgl to refresh the view, and 
    ///    voila wonderful crappy gray! woohoo?
    
    /// Since we want to draw a triangle let's specify some random points in 
    /// space for our triangle. WebGL work is very fidly so we have to be very 
    /// caution of the data types we use. Dart, javascript, etc, magical arrays 
    /// are simply a big nono.
    
    Float32Array points = new Float32Array.fromList
      (
          [ 
            -0.5,  0.5 * aspect, // (x1, y1) 
             0.5,  0.5 * aspect, // (x2, y2)
             0.5, -0.5 * aspect, // (x3, y3)
          ]
      );
    
    /// The aspect (long: horizontal aspect ration) is used there to account
    /// for the proportions of the viewport; if the viewport was a square all
    /// would be well... but it isn't.
    
    // dump our points into the buffer
    WebGLBuffer buffer = gl.createBuffer();
    gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
    gl.bufferData(GL.ARRAY_BUFFER, points, GL.STATIC_DRAW);
    
    /// You might be thinking at this point "Well telling webgl to read our 
    /// points wasn't so hard.". Sorry to say webgl doesn't know zilch at this
    /// point, all we did is push our junk to the magical memory space the 
    /// shaders can read from.
    
    /// More details on the specifics of what's happening there in example-2
    
    // we now need to get the "index" to the [aPosition] attribute
    int index = gl.getAttribLocation(program, 'aPosition');
    // ..then, might not be intuitive, but we have to tell webgl we want 
    // it enabled, like so 
    gl.enableVertexAttribArray(index);
    // ..and then, finally, have webgl read the damn buffer
    gl.vertexAttribPointer
      (
          index, // the index of the attribute
          2, // item size; we use (x, y) style coordinates hence the 2 
          GL.FLOAT, // type of the components in the array
          false, // fixed point data: true = normalize, false = use as is
          0, // stride
          0 // pointer
      );
    
    /// The last two parameters are related to packing; also item size can only
    /// be 1, 2, 3, 4. If you want to know the technical details on what they
    /// are and do just about any reference will tell you, since the API is 
    /// virtually universal across languages, here's one:
    /// http://www.opengl.org/sdk/docs/man/xhtml/glVertexAttribPointer.xml
    
    /// Bear in mind that in the last call there we didn't specify the buffer
    /// that's because this is a API based on all sorts of globals and if didn't
    /// know why people hate globals because classes and such were invented
    /// before you were probably born, well nows your chance...
    
    /// With everything set, we just need to tell webgl to draw
    gl.drawArrays(GL.TRIANGLES, 0, 3);
    
    /// First parameter specifies the mode (eg. TRIANGLES, POINTS, LINES).
    /// Second paramter the starting position in the buffer.
    /// The last paramter the count.
    /// Get any of them wrong and it all falls on it's ass. :D
    
  });

  // run the entire thing
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

