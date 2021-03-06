---
title: What is Futhark?
---

Futhark is a small programming language designed to be compiled to
highly performant GPU code.  It is a **statically typed,
data-parallel, and purely functional array language**, and comes with
a **heavily optimising ahead-of-time compiler** that generates GPU
code via OpenCL_.  Futhark is not designed for graphics programming,
but instead uses the compute power of the GPU to accelerate
data-parallel array computations.  We support **regular *nested*
data-parallelism**, as well as a form of imperative-style in-place
modification of arrays, while still preserving the overall purity of
the language via the use of a **uniqueness type system**.

The Futhark language and compiler is an **ongoing research project**.
It can compile nontrivial programs which then run on real GPUs at very
high speed.  The Futhark language itself is still very spartan - due
to the basic design criteria requiring the ability to generate
high-performance GPU code, it takes more effort to support language
features that are common in languages with more forgiving compilation
targets.  Nevertheless, **Futhark can already be used for nontrivial
programs**.  We are actively looking for more potential applications
as well as people who are interested in contributing to the language
design.

**Futhark is not intended to replace your existing languages**.  Our
intended use case is that Futhark is only used for relatively small
but compute-intensive parts of an application.  The Futhark compiler
generates code that can be **easily integrated with non-Futhark
code**.  For example, you can compile a Futhark program to a Python
module that internally uses PyOpenCL_ to execute code on the GPU, yet
looks like any other Python module from the outside (`more on this
here`_).  The Futhark compiler will also generate more conventional C
code, which can be accessed from any language with a basic FFI.

For more information, you can look at `code examples`_, details on
performance_, our devblog_, or maybe the docs_, which also contains a
list of our publications_.  You can of course also visit us `on
Github`_.

.. _OpenCL: https://en.wikipedia.org/wiki/OpenCL
.. _`code examples`: /examples.html
.. _performance: /performance.html
.. _devblog: /blog.html
.. _docs: /docs.html
.. _publications: /docs.html#publications
.. _PyOpenCL: https://mathema.tician.de/software/pyopencl/
.. _associative: https://en.wikipedia.org/wiki/Associative_property
.. _commutative: https://en.wikipedia.org/wiki/Commutative_property
.. _`on Github`: https://github.com/HIPERFIT/futhark
.. _`more on this here`: /blog/2016-04-15-futhark-and-pyopencl.html
