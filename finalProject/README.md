# Final Project
**Due by 1:00pm on Friday, 3/23/2018**

**This assignment will not be demoed**

In this assignment, we'll hook up an LLVM-based backend (and optimizer) to the Python language frontend we've been working on throughout the term to implement a complete end-to-end compiler.  Specifically, your goal will be to use the AST that we built in assignment 3 to generate LLVM IR representing the Python source program.  You'll then run some optimizations on that IR before using it to generate object code for a target machine.

There are a few major parts to this assignment, described below.  To get you started, you are provided with a Flex scanner specification in `scanner.l`, a Bison parser specification in `parser.y`, and an AST implementation in `ast.hpp` and `ast.cpp` that, together with the `main()` function in `main.cpp`, solve the problem defined in assignment 3.  There is also a makefile that specifies compilation for the parser.  Instead of using these files, you may also start with your own solution to assignment 3, if you'd like.

## 1. Use the AST constructed by the parser to generate LLVM IR

For the first task in this assignment, you should modify the AST classes to generate LLVM IR to represent each program construct represented by the AST.  The IR you generate should exactly reproduce the computation specified in the source program.  All generated IR can be contained within a single function.

For full credit, you should implement IR generation for all straight-line (i.e. non-branching) source code constructs currently recognized by the parser.  You may implement branching constructs for extra credit, as described below.  Importantly, note that the following constructs have been removed from the parser to simplify this assignment:
  * AND and OR expressions
  * NOT expressions
  * ELIF blocks for IF statements

The most straightforward way to compute IR for each construct will likely be to mimic the behavior of the `generateGVSpec()` method of each of the classes representing AST nodes.  In particular, this method recursively traverses the AST to generate GraphViz specification for the tree.  A similar recursive traversal would work well to generate LLVM IR.

Once you get your IR generation code working, you should invoke it on the entire AST from the `main()` function, and print the complete resulting IR representation (i.e. the complete LLVM module) to stdout.  You should modify the `Makefile` so that it correctly compiles your new compiler.

## 2. Optionally perform optimizations

Next, modify your compiler to check for the command-line option `-O`.  If the user specifies the `-O` option, you should perform some per-function optimizations on your generated IR before printing it to stdout.  The specific optimizations you choose are up to you, and a list of all available optimizations here: https://llvm.org/docs/Passes.html.  A good place to start would be to use some of the optimizations described in the course notes.

## 3. Generate object code from your generated IR

Finally, generate an object code file from your IR.  You should always save the object code to a file named `output.o`.  The target for the object code should be the architecture of the machine on which your compiler is being run.  To verify that your generated code can be successfully run, write a simple C/C++ program that calls the function you generated, and link `object.o` into your C/C++ program to generate an executable file.

## Extra credit

For 10 points of extra credit each, you may implement one or both of the following features:

  * Generate LLVM IR for if/else statements.  To do this, you may follow the basic pattern described in the course notes.  Your code should be able to handle if/else statements nested to an arbitrary depth, and the else block should always be optional.

  * Generate LLVM IR for while loops and break statements.  While loops may be implemented using a pattern similar to the one used for if/else statements.  Break statements will require some extra effort to determine a) whether the statement appears within a loop; and b) where to branch from the break statement if it does appear within a loop.  For the purposes of this assignment, you may treat a break statement that is not within a loop as a no-op.  One important consideration when implementing break statements is that an `llvm::BasicBlock` object must contain exactly one terminating statement (e.g. a return or a branch), which must be the last statement in the block.

## Testing your code

There are some simple Python programs you may use for testing your compiler included in the `testing_code/` directory.  Example unoptimized LLVM IR output for each of these programs is included in the `example_output/` directory.  The unoptimized IR you generate for each of the testing programs should closely resemble the IR in the `example_output/` directory, though it doesn't need to match it exactly.

## Useful LLVM documentation

Here are links to a few useful pieces of LLVM documentation that might help you with the assignment:

  * LLVM C++ API tutorial: https://llvm.org/docs/tutorial/index.html
  * LLVM IR language reference: https://llvm.org/docs/LangRef.html
  * LLVM programmer's manual: https://llvm.org/docs/ProgrammersManual.html
  * Autogenerated documentation for the complete LLVM API: http://llvm.org/doxygen/

## Submission

We'll be using GitHub Classroom for this assignment, and you will submit your assignment via GitHub.  Make sure your completed files are committed and pushed by the assignment's deadline to the master branch of the GitHub repo that was created for you by GitHub Classroom.  A good way to check whether your files are safely submitted is to look at the master branch your assignment repo on the github.com website (i.e. https://github.com/OSU-CS480-W18/final-project-YourGitHubUsername/). If your changes show up there, you can consider your files submitted.

## Grading criteria

The TAs will grade your assignment by compiling and running it on one of the ENGR servers, e.g. `flip.engr.oregonstate.edu`, so you should make sure your code works as expected there.  `bison`, `flex`, and LLVM are installed on the ENGR servers.  If your code does not compile and run on the ENGR servers, the TAs will deduct at least 25 points from your score.

This assignment is worth 100 points total, broken down as follows:
  * 65 points: compiler generates unoptimized LLVM IR for all straight-line program constructs, as described above
  * 15 points: running the compiler with the `-O` flag generates optimized IR
  * 15 points: the compiler outputs object code in `output.o` encoding the source program
  * 5 points: a C/C++ program is included that calls the function in generated in `output.o`

In addition, you may earn up to 20 points of extra credit for generating LLVM IR for branching program constructs, as described above.
