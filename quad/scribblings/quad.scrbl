#lang scribble/manual

@(require scribble/eval (for-label txexpr (except-in pollen #%module-begin) xml racket/base racket/draw)
pollen/scribblings/mb-tools)

@(define my-eval (make-base-eval))

@title[#:style 'toc]{Quad: document processor}

@author[(author+email "Matthew Butterick" "mb@mbtype.com")]

@defmodulelang*[(quadwriter
quadwriter/markdown
quadwriter/markup)]

@italic{This software is under development. Set expectations accordingly.}


@section{Installing Quad}

At the command line:
@verbatim{raco pkg install quad}

After that, you can update the package like so:
@verbatim{raco pkg update quad}

Quad is not stable, usable software. It is currently in documented-demo mode. Fiddle with it at your own risk. I make no commitment to maintain the API in its current state.

@section{What is Quad?}

A document processor that outputs to PDF.

@section{What is Quadwriter?}

A demo language built on Quad that takes a text-based source file as input, calculates the typesetting and layout, and then outputs a PDF.

@section{What can I do with this demo?}

You can fiddle with it & then submit issues and feature requests at the @link["http://github.com/mbutterick/quad"]{Quad repo}. After a few dead ends, I think I'm headed in the right direction. But I also want to open it to comments & criticism, because that can bend the thinking in productive ways.

Also, I have about a hundred topics to add to the documentation. So I don't mind requests along the lines of ``can you document such-and-such'' — it's probably already on my list and I don't mind moving it to the front in response to human interest. At this point in its development, I find it easier to have a working version of the project and iterate, rather than leave it in some partially busted state for weeks on end.


@section{What are your plans for Quad?}

Some things I personally plan to use Quad for:

@itemlist[#:style 'ordered

@item{@bold{A simple word processor}. Quadwriter is the demo of this.}

@item{@bold{Font sample documents}. In my work as a @link["https://mbtype.com"]{type designer}, I have to put together PDFs of fonts. To date, I have done them by hand, but I would like to just write programs to generate them.}

@item{@bold{Racket documentation}. The PDFs of Racket documentation are currently generated by LaTeX. I would like to make Quad good enough to handle them.}

@item{@bold{Book publishing}. My wife is a lawyer and wants to publish a book about a certain area of the law that involves a zillion fiddly charts. If I had to do it by hand, it would take months. But with a Quad program, it could be easy.}

]


@section{What's a document processor?}

A @deftech{document processor} is a rule-driven typesetter. It takes a text-based source file as input and converts it into a page layout. 

For instance, LaTeX is a document processor. So are web browsers. Quad borrows from both traditions — it's an attempt to modernize the good ideas in LaTeX, and generalize the good ideas in web browsers.

Document processors sit opposite WYSIWYG tools like Word and InDesign. There, the user controls the layout by manipulating a representation of the page on the screen. This is fine as far as it goes. But changes to the layout — for instance, a new page size — often require a new round of manual adjustments. 

A document processor, by contrast, relies on markup codes within the text to determine the layout programmatically. Compared to WYSIWYG, this approach offers less granular control. But it also creates a more flexible relationship between the source and its possible layouts. 

Another benefit of document processors is that it permits every document to have a high-level, text-based source file that's independent of any particular output format (rather than the opaque binary formats endemic to Word, InDesign, et al.)

@subsection{Why not just use LaTeX?}

I wouldn't want to criticize software merely for being old. It's a great compliment to LaTeX that it's endured this long. But —

@itemlist[#:style 'ordered

@item{It's never made much headway beyond its original audience of scientific & technical writers.}

@item{The last 25 years of advances in digital typesetting have been implemented as a huge (occasionally tenuous) tower of patches.}

@item{The source code is increasingly opaque to today's programmers. Meaning, if LaTeX were plausibly rewritable, it would've been rewritten by now.}
]

Instead, let's take its good ideas — there are a few — and terraform a new planet. 

@margin-note{Quad has no ambition to supplant LaTeX. I am not an academic writer. Those typesetting problems are not my problems. So I am not proposing to solve them. Best of luck, though.}

@subsection{Why not use more HTML/CSS?}

In principle, it's possible to generate PDF documents from a web browser. Support for paper-based layouts has been part of the CSS concept @link["https://www.w3.org/People/howcome/p/cascade.html"]{since the beginning} (though it's been lightly used).

But web browsers have some limitations:

@itemlist[#:style 'ordered

@item{Web browsers only render HTML, and many typesetting concepts (e.g., footnotes) don't correspond to any HTML entity. So there is a narrowing of possiblities.}

@item{Browsers are built for speed, so high-quality typesetting is off the table.}

@item{Browsers render pages inconsistently.}

@item{Taking off my typography-snob tiara here — browsers are unstable. What seems well supported today can be broken or removed tomorrow. So browsers can't be a part of a dependable publishing workflow that yields reproducible results.}
]


@section{What does Quad do?}

Quad produces PDFs using three ingredients: 

@itemlist[#:style 'ordered
  @item{A @bold{font engine} that handles glyph shaping and positioning using standard TTF or OTF font files.}

  @item{A @bold{layout engine} that converts typesetting instructions into an output-independent layout — e.g., putting characters into lines, and lines into pages.}

  @item{A @bold{PDF engine} that takes this layout and renders it as a finished PDF file.}
]

While there's no reason Quad couldn't produce an HTML layout, that's an easier problem, because most of the document-layout chores can (and should) be delegated to the web browser. For now, most of Quad's apparatus is devoted to its layout engine so it can produce PDFs.

Much of the font-parsing and PDF-rendering code in Quad is adapted from @link["http://github.com/foliojs/"]{FolioJS} by Devon Govett. I thank Mr. Govett for figuring out a lot of details that would've made me squeal in agony. 

For the most part, neither Quad nor Quadwriter rely much on @racketmodname[racket/draw], and completely avoid its PDF-drawing functions. These facilities are provided by Pango, which has some major deficiencies in the kind of PDFs it produces (for instance, it doesn't support hyperlinks). In fact, most of the good ideas in Quad, I figured out a while ago. But then I had to embark on a multi-year yak-shave to be able to get sufficient control of PDFs.

@section{What doesn't Quad do?}

@itemlist[#:style 'ordered
@item{Quad is not a WYSIWYG or interactive previewing tool.}

@item{Quad does not have user-level representations of formatting, à la Word style sheets.}

@item{Quad does not handle semantic or configurable markup. Its markup is limited to its specific, layout-based vocabulary.}
]
Rather, it's designed to cooperate with tools that offer these facilities. For instance, Quadwriter is a demonstration language that provides an interface to a small set of word-processor-like features that are implemented with Quad.

@section{Theory of operation}

A document processor starts with input that we can think of as one giant line of text. It breaks this into smaller lines, and then distributes these lines across pages. Various complexities surface along the way. But that's the basic idea.

More specifically:

@itemlist[#:style 'ordered
  @item{Quad starts with a source file. In this demo, we can will use the @code{#lang quadwriter} language. For the most part, it's text with markup codes (though it may also include things like diagrams and images).}

  @item{Each markup entity is called a @deftech{quad}. A quad roughly corresponds to a box. ``Roughly'' because quads can have zero or negative dimension. Also, at the input stage, the contents of some quads may end up being spread across multiple non-overlapping boxes (e.g., a quad containing a word might be hyphenated to appear on two lines). The more precise description of a quad is therefore ``contiguous formatting region''. Quads can be recursively nested inside other quads, thus the input file is tree-shaped.}

  @item{This tree-shaped input file is flattened into a list of @deftech{atomic} quads. ``Atomic'' in the sense that these are the smallest items the typesetter can manipulate. (For instance, the word @italic{bar} would become three one-character quads. An image or other indivisible box would remain as is.) During the flattening, tags from higher in the tree are propagated downward by copying them into the atomic quads. The result is that all the information needed to typeset an atomic quad is contained within the quad itself.

  @margin-note{The input is flattened because typesetting operations are easier to reason about as a linear sequence of instructions (i.e., an imperative model). To see why, consider how you'd handle a page break within a tree model. No matter how deep you were in your typesetting tree, you'd have to jump back to the top level to handle your page break (because it affects the positioning of all subsequent items). Then you'd have to jump back to where you were, deep in the tree. That's unnatural.}}

  @item{Atomic quads are composed into lines using one of two algorithms. (Each line is just another quad, of a certain width, that contains these atomic quads.) The first-fit algorithm puts as many quads onto a line as it can before moving on to the next. The best-fit algorithm minimizes the total looseness of all the lines in a paragraph (also known as the @link["http://defoe.sourceforge.net/folio/knuth-plass.html"]{Knuth–Plass linebreaking algorithm} developed for TeX). Best fit is slower, of course.}

  @item{Once the lines are broken, extra space is distributed within each line according to whether the line should appear centered, left-aligned, justified, etc. The result is a list of quads that fills the full column width.}

  @item{Lines are composed into pages.}

  @item{Before the typeset markup is passed to the renderer, it goes through a simplification phase — a lot of adjacent quads will have the same formatting characteristics, and these can be consolidated into runs of text.}

  @item{The renderer walks through the markup and positions and draws each quad, using information in the markup attributes to determine position, color, font, size, style, etc.}

]


@section{Enough talk — let's rock}

Open DrRacket (or the editor you prefer) and start a new document with @code{#lang quadwriter} as the first line:


@fileblock["test.rkt"
@codeblock|{
#lang quadwriter/markup
Brennan and Dale like fancy sauce.
}|
]

Save the document. Any place, any name is fine. 

@onscreen{Run} the document. You'll get REPL output like this:

@repl-output{
hyphenate: cpu time: 0 real time: 0 gc time: 0
line-wrap: cpu time: 27 real time: 30 gc time: 0
page-wrap: cpu time: 0 real time: 1 gc time: 0
position: cpu time: 1 real time: 0 gc time: 0
draw: cpu time: 77 real time: 76 gc time: 23
wrote PDF to /Desktop/test.pdf
}

Congratulations — you just made your first PDF. If you want to have a look, either open the file manually, or enter this command on the REPL, which will open the PDF in your default viewer:

@terminal{
> (view-result)
}

Next, on the REPL enter this:

@terminal{
> doc
}

You will see the actual input to Quadwriter, which is called a @deftech{Q-expression}:

@repl-output{
'(q ((line-height "17")) (q ((break "paragraph"))) "Brennan and Dale like fancy sauce." (q ((break "paragraph"))))
}

A Q-expression is an @seclink["X-expressions" #:doc '(lib "pollen/scribblings/pollen.scrbl")]{X-expression} with some extra restrictions.

In the demos that follow, the input language will change slightly. But the PDF will be rendered the same way (by running the source file) and you can always look at @racket[doc].


@subsection{Soft rock: Quadwriter & Markdown}

I @link["https://docs.racket-lang.org/pollen/second-tutorial.html#%28part._the-case-against-markdown%29"]{don't recommend} that writers adopt Markdown for serious projects. But for goofing around, why not.

Let's update the first line of @racket["test.rkt"] so it uses the @racket[quadwriter/markdown] dialect instead of the plain @racket[quadwriter] language:

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter/markdown
Brennan and Dale like fancy sauce.
}|
]

Run the file. The PDF result is the same. Why? Because a short line of plain text comes out the same way in both dialects.

Behind the scenes, however, @racket[quadwriter/markdown] is doing more heavy lifting. We can enter text with Markdown notation, and it will automatically be converted to the appropriate Quad formatting commands to make things look right. For instance, this sample combines a Markdown heading, bullet list, code block, and bold and italic formatting.

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter/markdown
# Did you know?

__Brennan__ and **Dale** like:

* *Fancy* sauce
* _Chicken_ fingers

```
And they love to code
```
}|
]

You are welcome to paste in bigger Markdown files that you have laying around and see what happens. As a demo language, I'm sure there are tortured agglomerations of Markdown notation that will confuse to @racket[quadwriter/markdown]. But with vanilla files, even big ones, it should be fine.

A question naturally arises: would it be possible to convert any Markdown file, no matter how sadistic, to PDF? As a practical matter, I'm sure such things exist already. I have no interest in being in the Markdown-conversion business. As a theoretical matter: the problem I foresee is that Markdown — like the HTML that it lightly disguises — can have formatting entities that are nested indefinitely deep. The idea of making a layout engine that can handle that just becomes the equivalent of reinventing a web-browser engine.

Back to the demo. Curious characters can do this:

@terminal{
> doc
}

To see this:

@repl-output{
'(q
  ((line-height "17"))
  (q ((break "paragraph")))
  (q
   ((font-family "fira-sans-light")
    (first-line-indent "0")
    (display "block")
    (font-size "20")
    (line-height "24.0")
    (border-width-top "0.5")
    (border-inset-top "9")
    (inset-bottom "-3")
    (inset-top "6")
    (keep-with-next "true")
    (id "did-you-know"))
   "Did you know?")
   ···
}

This is part of the @tech{Q-expression} that the source file produces. This Q-expression is passed to Quadwriter for layout and rendering.

If you know about the duality of X-expressions and XML, you might wonder if we could create an equivalent text-based markup language for Q-expressions — let's call it QML. Sure, why not:

@repl-output{
  <q line-height="17"><q break="paragraph"></q><q font-family="fira-sans-light" first-line-indent="0" display="block" font-size="20" line-height="24.0" border-width-top="0.5" border-inset-top="9" inset-bottom="-3" inset-top="6" keep-with-next="true" id="did-you-know">Did you know?</q> ···
}

There's nothing interesting about QML — it's just a way of cosmetically encoding a Q-expression as a string. We could also convert our Q-expression to, say, JSON. Thus, having noted that QML can exist, and @racket[quadwriter] could support this input, let's move on.

@subsection{Hard rock: Quadwriter & markup}

Suppose Markdown is just not your thing. You prefer to enter your markup the old-fashioned way — by hand. I hear you. So let's switch to the @racket[quadwriter/markup] dialect. First we try our simple test:

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter/markup
Brennan and Dale like fancy sauce.
}|
]

We get the same PDF result as before, again because a short line of plain text is the same in this dialect as the others.

But if we want to reproduce the result of the Markdown notation, this time we use the equivalent markup tags:

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter/markup
◊h1{Did you know?}

◊strong{Brennan} and ◊strong{Dale} like:

◊ul{
◊li{◊em{Fancy} sauce}
◊li{◊em{Chicken} fingers}
}

◊pre{
◊code{
And they love to code
}
}
}|
]

The special @litchar{◊} character is called a @deftech{lozenge}. It introduces markup tags. @link["https://docs.racket-lang.org/pollen/pollen-command-syntax.html#%28part._the-lozenge%29"]{Instructions for typing it}, but for now it suffices to copy & paste, or use the @onscreen{Insert Command Char} button in the DrRacket toolbar.

Under the hood, the @racket[quadwriter/markdown] dialect is converting the Markdown surface notation into markup tags that look like this. So the @racket[quadwriter/markup] dialect just lets us start with those tags. 

Curious characters can prove that this is so by again typing at the REPL:

@terminal{
> doc
}

This Q-expression is exactly the same as the one that resulted with the @racket[quadwriter/markdown] source file.

@subsection{Heavy metal: Quadwriter & Q-expressions}

@racket[quadwriter/markdown] showed high-level notation (= a generous way of describing Markdown) that generated a Q-expression. Then @racket[quadwriter/markup] showed a mid-level notation that generated another (identical) Q-expression.

If we wish, we can also skip the notational foofaraw and just write Q-expressions directly in our source file. We do this with the basic @racket[quadwriter] language. 

Recall our very first example:

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter/markup
Brennan and Dale like fancy sauce.
}|
]

In the REPL, the @racket[doc] was this Q-expression:

@repl-output{
'(q ((line-height "17")) (q ((break "paragraph"))) "Brennan and Dale like fancy sauce." (q ((break "paragraph"))))
}

Let's copy this Q-expression and use it as our new source code. This time, however, we'll switch to plain @code{#lang quadwriter} (instead of the @racket[markup] or @racket[markdown] dialects):

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter
'(q ((line-height "17")) (q ((break "paragraph"))) 
"Brennan and Dale like fancy sauce." (q ((break "paragraph"))))
}|
]

This produces the same one-line PDF as before.

Likewise, we can pick up the @racket[doc] from our more complex example:


@codeblock|{
#lang quadwriter/markdown
# Did you know?

__Brennan__ and **Dale** like:

* *Fancy* sauce
* _Chicken_ fingers

```
And they love to code
```
}|


And again, use this Q-expression as the source for a new @racket[quadwriter] program:

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter
'(q
  ((line-height "17"))
  (q ((break "paragraph")))
  (q
   ((font-family "fira-sans-light")
    (first-line-indent "0")
    (display "block")
    (font-size "20")
    (line-height "24.0")
    (border-width-top "0.5")
    (border-inset-top "9")
    (inset-bottom "-3")
    (inset-top "6")
    (keep-with-next "true")
    (id "did-you-know"))
   "Did you know?")
  (q ((break "paragraph")))
  (q
   ((keep-first "2") (keep-last "3") (line-align "left") 
   (font-size-adjust "100%") (character-tracking "0") 
   (hyphenate "true") (display "g146739"))
   (q ((font-bold "true") (font-size-adjust "100%")) "Brennan")
   " and "
   (q ((font-bold "true") (font-size-adjust "100%")) "Dale")
   " like:")
  (q ((break "paragraph")))
  (q
   ((inset-left "30.0"))
   (q ((list-index "•")) (q ((font-italic "true") 
   (font-size-adjust "100%")) "Fancy") " sauce")
   (q ((break "paragraph")))
   (q ((list-index "•")) (q ((font-italic "true") 
   (font-size-adjust "100%")) "Chicken") " fingers"))
  (q ((break "paragraph")))
  (q
   ((display "block")
    (background-color "aliceblue")
    (first-line-indent "0")
    (font-family "fira-mono")
    (font-size "11")
    (line-height "14")
    (border-inset-top "10")
    (border-width-left "2")
    (border-color-left "#669")
    (border-inset-left "0")
    (border-inset-bottom "-4")
    (inset-left "12")
    (inset-top "12")
    (inset-bottom "8"))
   (q ((font-family "fira-mono") (font-size "10") 
   (bg "aliceblue")) "And they love to code"))
  (q ((break "paragraph"))))
}|
]

Which yields the same PDF result. (If you've spent any time with ’90s HTML markup, the above probably looks familiar.)

@subsection{Q-expression PS}

In @code{#lang quadwriter}, we enter our Q-expression in the usual Racket list notation. What if we wanted to use the text-based notation of @racket[quadwriter/markup]? Sure — we can convert our Q-expression to that notation, and invoke the @racket[quadwriter/markup] dialect:

@fileblock["test.rkt"
@codeblock|{
#lang quadwriter/markup
◊q[#:line-height "17"]{◊q[#:break "paragraph"]
◊q[#:font-family "fira-sans-light" #:first-line-indent "0" 
#:display "block" #:font-size "20" #:line-height "24.0" 
#:border-width-top "0.5" #:border-inset-top "9" 
#:inset-bottom "-3" #:inset-top "6" #:keep-with-next "true" 
#:id "did-you-know"]{Did you know?}◊q[#:break "paragraph"]
◊q[#:keep-first "2" #:keep-last "3" #:line-align "left" 
#:font-size-adjust "100%" #:character-tracking "0" 
#:hyphenate "true" #:display "g146739"]{
◊q[#:font-bold "true" #:font-size-adjust "100%"]{Brennan} and 
◊q[#:font-bold "true" #:font-size-adjust "100%"]{Dale} like:}
◊q[#:break "paragraph"]◊q[#:inset-left "30.0"]{
◊q[#:list-index "•"]{◊q[#:font-italic "true" 
#:font-size-adjust "100%"]{Fancy} sauce}
◊q[#:break "paragraph"]◊q[#:list-index "•"]{
◊q[#:font-italic "true" #:font-size-adjust "100%"]{Chicken} 
fingers}}◊q[#:break "paragraph"]
◊q[#:display "block" #:background-color "aliceblue" 
#:first-line-indent "0" #:font-family "fira-mono" 
#:font-size "11" #:line-height "14" #:border-inset-top "10" 
#:border-width-left "2" #:border-color-left "#669" 
#:border-inset-left "0" #:border-inset-bottom "-4" 
#:inset-left "12" #:inset-top "12" 
#:inset-bottom "8"]{◊q[#:font-family "fira-mono" 
#:font-size "10" #:bg "aliceblue"]{And they love to 
code}}
◊q[#:break "paragraph"]}
}|
]

Don't panic — you'll never have to actually do this in @racket[quadwriter]. It's just to show that it's possible.

@subsection{Quadwriter: the upshot}

What you should infer from all this is that in the usual Racket tradition, @racket[quadwriter] and its dialects are just compiling a document from a higher-level representation to a lower-level representation. 

If you're a writer, you might prefer to use the high-level representation (like Markdown) so that your experience is optimized for ease of use.

If you're a developer, you might prefer to use the lower-level representation for precision. For instance, a @racketmodname[pollen] author who wanted to generate a PDF could design tag functions that emit Q-expressions, and then pass the result to Quadwriter for conversion to PDF.

@margin-note{Because Q-expressions are a subset of X-expressions, you can apply any tools that work with X-expressions (for instance, the @racketmodname[txexpr] library).}

Or, you can aim somewhere in between. Like everything else in Racket, you can design functions & macros to emit the pieces of a Q-expression using whatever interface you prefer. 

@subsection{``I don't like Quadwriter …''}

It's a demo! Don't panic! @racket[quadwriter] itself is just meant to show how one can build an interface to @racket[quad], which if we're being honest, is basically just a home for all the generic geometric routines and technical fiddly bits (e.g., font parsing and PDF generation) without any true typographic smarts. That's what @racket[quadwriter] adds. 

In the sample above, though you see formatting tags like @racket[background-color] and @racket[font-family], those are defined by @racket[quadwriter], not @racket[quad]. So if you don't like them — no problem! You can still drop down one more layer and program your own interface to @racket[quad].

That said, I imagine that most users & developers are looking for PDF generation along the lines of ``don't make me think too hard.'' So I can foresee that @racket[quadwriter] (or a better version of it) will be the preferred interface.

Why? Decades of experience with HTML and its relations have acclimated us to the model of marking up a text with certain codes that denote layout, and then passing the markup to a program for output. So I think the idea of a Q-expression, with some application-specific vocabulary of markup tags, will probably end up being the most natural and useful interface. 

@margin-note{Historians of desktop word processors may remember that WordPerfect has a @onscreen{Reveal codes} feature which lets you drop into the markup that represents the formatting displayed in the GUI.}

Part of the idea of @racket[quad] is to make typographic layout & PDF generation a service that can be built into other Racket apps and languages. For simple jobs, you might reach for @racket[quadwriter] and make your Q-expressions using its tag vocabulary. For other jobs, you might reach for something else. For instance, I could imagine a @racketidfont{#lang resume} that has a more limited markup vocabulary, optimized for churning out résumés with a simple layout. Or a @racketidfont{#lang tax-form} that has a more complex markup vocabulary that supports more detail and precision. As usual with domain-specific languages, we can create an interface that adjusts the level of control available to the end user, depending on what's suitable for the type of document being created.




@section{Why is it called Quad?}

In letterpress printing, a @italic{quad} was a piece of metal used as spacing material within a line.


@italic{``A way of doing something original is by trying something
so painstaking that nobody else has ever bothered with it.'' — Brian Eno}