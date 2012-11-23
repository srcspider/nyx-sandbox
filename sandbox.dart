import 'dart:html';
import 'nyx/lib.dart' as nyx;
import 'nyx/lib.dart' show GL;

///
/// ### Sandbox ###
/// 
/// This is an empty file. It is used as a base for examples.
///

/**
 * ...
 */
void program(nyx.Viewport viewport) {
  
  // add a fragment shader
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
 
  // add vertex shader
  viewport.addVertexShader(
    source:
      """
      attribute vec2 aPosition;
      void main() {
        gl_Position = vec4(aPosition, 0, 1);
      }
      """
  );
  
  viewport.painter(({WebGLRenderingContext gl, WebGLProgram program, num aspect, num time}) {
    
    // Welcome to the frame. You have a budget of 14 millisecond to do all your 
    // black glyph magic. Well, technically 16ms, but browsers have a 2ms frame 
    // tax (usually), so make do with 14ms. :D 
    
    // GL can be used in place of WebGLRenderingContext for accessing constants
    // GL can NOT be used in any other context in place of WebGLRenderingContext
    
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

