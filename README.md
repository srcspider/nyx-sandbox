This is a Sandbox
=================

All example files here are webgl examples written in Dart. The reason for using
dart is simple: tooling, nice syntax, good performance. And even as just a 
javascript abstraction layer it is probably the best for anything of scale; or 
at least that's my understanding and belief at the time.

Nyx is a library I built while working though examples. It serves to eliminate 
the boilerplate and simplify the interface for doing things. It's main file is 
`nyx/lib.dart`. (I just really hate repeating myself)

You'll find the origin/source of the example at the top of every 
`example-*.dart` file. Intuitive title included for those too lazy to read
blocks of text, such as myself. Explanation blocks are provided in the code, 
they most often follow after the piece of code they are explaining. 

The `sandbox.dart` file is a blank example file. Use it if you want to write
your own example.

Because webgl only works in modern browsers I use the short syntax in html 
files, hence the short html5 doctype, and ommision of optional tags such as
html, body, head, etc. There's really no reason not to, and the double 
indentation level always irked me. And who doesn't like short files anyway?

## Comment ownership

I mix my own code with the examples so while /// are all mine (more notes, 
rather then comments), // comments might be from the original source, or 
both (ie. altered).

Also "..." comments are my way of saying "this is self explainatory". They're
just there since I always doubt myself when seing an empty space on something 
that looks like it might require a comment.

## Runs only in Dartium?

Nope. 

For the sake of simplicity I haven't generated the javascript files but
you can just open DartEditor, click on an example dart file and then from
tools select Generate Javascript. You can now open the html file in any browser
and it will just work; no dart VM required.

Unfortunately the damn thing generates another 3 files and since these are just
examples I used to learn, I didn't bother to generate the javascript. Supposedly
the Dart team are working on a dart to js, javascript compiler, so at some point
you won't even have to do what I just said, it will just work as-is. 

## Never used the DartEditor before, how do I run the examples?

Select the desired file, eg. `example-0.html` then press Ctrl+R or just click
the little green right pointing arrow on the toolbar. :)
