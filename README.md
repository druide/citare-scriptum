# Citare

Citare takes your _documented_ code, and in an admission that people aren't machines,
generates documentation that follows the spirit of literate programming.  Take a look at the
[self-generated documentation](http://druide.github.com/citare-scriptum/), and see if it appeals to you!

It is very heavily influenced by [Jeremy Ashkenas](https://github.com/jashkenas)'
[docco](http://jashkenas.github.com/docco/), and is an attempt to further enhance the idea (thus,
citare can't tout the same quick 'n dirty principles of docco).


## What does it give you?

Citare will:

* Generate documentation from your source code, by displaying your [Marked](https://github.com/chjj/marked) formatted comments next to the code
  fragments that they document.

* Submit your project's documentation to the [github pages](http://pages.github.com/) for your project.

* Generate a searchable table of contents for all documented files and headers within your project.

* Gracefully handle complex hierarchies of source code across multiple folders.

* Read a configuration file so that you don't have to think when you want your documentation built;
  you just type `citare`.

Contains [brief](http://druide.github.com/citare-scriptum/lib/utils/brief.html) function specification highlight (works with github flavored markdown):

```
functionName(Type argument1, Type1/Type2 argument2, Type optionalArgument1?): Type
```

## How?

### Installing citare

Citare depends on [Node.js](http://nodejs.org/). Once you have this installed - and assuming that
your node install came with [npm](http://npmjs.org/) - you can install citare via:

    npm install -g citare-scriptum

You may need to prefix the command with sudo, depending on how you installed node.


### Using citare (CLI)

To generate documentation, just point citare to source files that you want docs for:

    citare *.js

Citare will also handle extended globbing syntax if you quote arguments:

    citare "lib/**/*.coffee" README.md

By default, citare will drop the generated documentation in the `doc/` folder of your project, and it
will treat `README.md` as the index.  Take a look at your generated docs, and see if everything is
in order!

Once you are pleased with the output, you can push your docs to your github pages branch:

    citare --github "lib/**/*.coffee" README.md

Citare will automagically create and push the `gh-pages` branch if it is missing.

There are [additional options](http://druide.github.com/citare-scriptum/lib/cli.html#cli-options) supported by
citare, if you are interested.


### Configuring citare (.citare.json)

Citare supports a simple JSON configuration format once you know the config values that appeal to you.

Create a `.citare.json` file in your project root, where each key maps to an option you would pass to
the `citare` command.  File names and globs are defined as an array with the key `glob`.  For
example, citare's own configuration is:

    {
      "glob": ["lib/**/*.coffee", "lib/**/*.js", "lib/**/*.jade", "lib/**/*.styl", "**/README.md"],
      "except": ["lib/**/jquery.min.js"],
      "repository-url": "https://github.com/druide/citare-scriptum"
    }

From now on, if you call `citare` without any arguments, it will use your pre-defined configuration.

## Difference from groc
Citare is a fork of documentation project [groc](https://github.com/nevir/groc) written by
[Ian MacLeod](https://github.com/nevir). It is backward-compatable with groc (have the same options and
understands `.groc.json`) and have the following changes:

- comments are processed by [marked](https://github.com/chjj/marked) github flavored markdown
- multiline comments are used for documentation too
- code is highlighted by [highlight.js](https://github.com/isagalaev/highlight.js) javascript
  syntax highlighter
- Default light style, Callout style, Groc darken style
- table of contents includes all the files with all the titles from project
- `{{TOC}}` tag to insert auto generated table of contents in your markdown
- `[Any Title]` syntax for auto linking to any title in the project (for now citare does
  not resolve duplicate titles so link will point to the first found duplicate title)

## Literate programming?

[Literate programming](http://en.wikipedia.org/wiki/Literate_programming) is a programming
methodology coined by [Donald Knuth](http://en.wikipedia.org/wiki/Donald_Knuth).  The primary tenet
is that you write a program so that the structure of both the code and documentation align with
your mental model of its behaviors and processes.

Citare aims to provide a happy medium where you can freely write your source files as structured
documents, while not going out of your way to restructure the code to fit the documentation.
Here are some suggested guidelines to follow when writing your code:

* Try to keep the size of each source file down.  It is helpful if each file fulfills a specific
  feature of your application or library.

* Rather than commenting individual lines of code, write comments that explain the _behavior_ of a
  given method or code block.  Take advantage of the fact that comments can span that method.

* Make gratuitous use of lists when explaining processes; step by step explanations are extremely
  easy to follow!

* Break each source file into sections via headers.  Don't be afraid to split source into even
  smaller files if it makes them more readable.

Writing documentation is _hard_; hopefully citare helps to streamline the process for you!

