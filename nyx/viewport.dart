part of nyx;

// yes gl stands for "graphics library", and "context" might make more sense, 
// but given webgl's global nature it's not wrong per se, and it's shorter then 
// writing "context"
typedef void FramePainter({WebGLRenderingContext gl, WebGLProgram program, double aspect, num time});
typedef void Preprocess({WebGLRenderingContext gl, WebGLProgram program});

/**
 * General viewport class for managing canvas and basic webgl settings.
 *
 * Basic usage:
 *
 *  - create a new instance via new nyx.Viewport and passing a html Element as
 *    a container argument; you may also optionally pass with, height
 *    and showFPS
 *
 *  - add a fragment shader via [addFragmentShader] and a vertex shader via
 *    [addVertexShader]. Both accept the named parameter source and expect
 *    strings.
 *
 *  - put your logic into the painter via the [painter] method; simply create a
 *    annoymous function which accepts: gl, program, time and aspect (all are
 *    named parameters).
 *
 *  eg.
 *
 *      nyx.Viewport viewport = new nyx.Viewport(
 *        container:
 *          query('[data-nyx-viewport]')
 *      );
 *      
 *      // just an example
 *      viewport.addVertexShader(
 *        source:
 *          """
 *          attribute vec2 aPosition;
 *          void main() {
 *            gl_Position = vec4(aPosition, 0, 1);
 *          }
 *          """
 *      );
 *      
 *      // just an example
 *      viewport.addFragmentShader(
 *        source:
 *          """
 *          precision mediump float;
 *          uniform vec4 uColor;
 *          void main() {
 *            gl_FragColor = uColor;
 *          }
 *          """
 *      );
 *      
 *      viewport.painter(({gl, program, aspect, time}) {
 *        // your per frame logic goes here
 *      });
 *      
 *      viewport.execute();
 *
 */
class Viewport {

  Element
    container,
    fps;

  bool
    showFPS = false;

  double
    fpsAverage;

  num
    renderTime;

  int
    width = 800,
    height = 600;

  CanvasElement
    canvas;

  WebGLRenderingContext
    gl;

  WebGLProgram
    program;
  
  List<WebGLShader>
    shaders;

  FramePainter
    framepainter;
  
  Preprocess
    preanimation;

  // ---- Initialization ------------------------------------------------------

  /**
   * Creates a Viewport object which provides helpers for most of the generic 
   * webgl work. The only required parameter is a container which should 
   * preferably be a plain old div. The class will populate said div with all
   * necesary components.
   * 
   * For an example see the class's docblock. This class should be used with 
   * advanced components but may be used by itself for simple webgl animation
   * as well as sandboxing.
   * 
   * Note: frame capping is intentionally not supported; frames are not a 
   * clock, if syncronization needs to exist then it should exist as logic 
   * within the frame (ie. you don't just increment the hand of a clock every
   * frame you calculate where it needs to be). Browsers will adjust framerate
   * by themselves better then we can and needless to say there is no real way
   * to cap frames, that is not clunky, so code which works with the time 
   * provided by the frame is of far better quality at this time, then a 
   * [window.setTimeout] with [window.requestAnimationFrame] in the animation 
   * loop (which will result in frame skipping).
   */
  Viewport({Element this.container, num this.width: 800, num this.height: 600, bool this.showFPS: false}) {
    this.canvas = new Element.html
      (
        """
          <canvas width="$width" height="$height">
            Your browser does not support 3D graphics; please install a modern browser.
          </canvas>
        """
      );
    this.container.elements.add(canvas);

    if (this.showFPS) {
      // create FPS info node
      this.fps = new Element.html('<div class="nyx-fps" />');
      this.container.elements.add(this.fps);
    }

    // try and get the gl context
    this.gl = this.canvas.getContext('webgl');

    if (this.gl == null) {
      // try and get it via the legacy interface
      this.gl = this.canvas.getContext('experimental-webgl');
    }

    if (this.gl == null) {
      throw new Exception_MissingFeature();
    }

    this.gl.viewport(0, 0, this.width, this.height);
    this.program = this.gl.createProgram();
  }

  // ---- Painting ------------------------------------------------------------

  /**
   * ...
   */
  void addVertexShader({String source}) {
    WebGLShader shader = this.gl.createShader(WebGLRenderingContext.VERTEX_SHADER);
    this.gl.shaderSource(shader, source);
    this.gl.compileShader(shader);
    
    // check for errors
    if ( ! this.gl.getShaderParameter(shader, WebGLRenderingContext.COMPILE_STATUS)) {
      String error_info = this.gl.getShaderInfoLog(shader);
      this.gl.deleteShader(shader);
      
      throw new Exception(error_info);
    }
    
//    this.shaders.add(shader);
    this.gl.attachShader(this.program, shader);
  }

  /**
   * ...
   */
  void addFragmentShader({String source}) {
    WebGLShader shader = this.gl.createShader(WebGLRenderingContext.FRAGMENT_SHADER);
    this.gl.shaderSource(shader, source);
    this.gl.compileShader(shader);

    // check for errors
    if ( ! this.gl.getShaderParameter(shader, WebGLRenderingContext.COMPILE_STATUS)) {
      String error_info = this.gl.getShaderInfoLog(shader);
      this.gl.deleteShader(shader);
      
      throw new Exception(error_info);
    }

//    this.shaders.add(shader);
    this.gl.attachShader(this.program, shader);
  }
  
  /**
   * Define a function to execute before the animation starts. You can use it
   * to setup various pointers to uniforms and attributes you need, to avoid
   * re-calling them in each frame.
   */
  void preprocessor(Preprocess preprocessor) {
    this.preanimation = preprocessor;
  }

  /**
   * The painter is the per frame logic. A function accepting the named
   * parameters: gl, program, time and aspect should be used.
   */
  void painter(FramePainter painter) {
    this.framepainter = painter;
  }

  /**
   * Compile and run the program.
   */
  void execute() {
    this.gl.linkProgram(this.program);

    // check for errors
    if ( ! this.gl.getProgramParameter(this.program, WebGLRenderingContext.LINK_STATUS)) {
      String error_info = this.gl.getProgramInfoLog(this.program);
      this.gl.deleteProgram(this.program);
      this.shaders.every((WebGLShader shader) {
        gl.deleteShader(shader);
      });
      
      throw new Exception(error_info);
    }

    this.gl.useProgram(this.program);

    this.preanimation
      (
        gl: this.gl,
        program: this.program
      );
    
    this.animate(null);
  }
  
  /**
   * We use this method to run our animation loop; this method uses
   * [window.requestAnimationFrame] to conserve battery life and processing
   * power when our program is running in the background.
   *
   * To set the frame painter use the [painter] method.
   */
  void animate(num time) {
    num time = new Date.now().millisecondsSinceEpoch;

    if (this.showFPS) {
      if (renderTime != null) {
        this.fpsIs((1000 / (time - renderTime)).round());
      }

      renderTime = time;
    }

    this.framepainter(
        gl: this.gl,
        program: this.program,
        aspect: this.width / this.height,
        time: time
    );

    window.requestAnimationFrame(this.animate);  
  }

  // ---- etc -----------------------------------------------------------------
  
  /**
   * Update fps counter.
   */
  void fpsIs(num fps) {
    if (fpsAverage == null) {
      fpsAverage = fps;
    }

    fpsAverage = fps * 0.05 + fpsAverage * 0.95;

    this.fps.text = "${fpsAverage.round().toInt()} fps";
  }

} // class