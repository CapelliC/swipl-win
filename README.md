swipl-win:

    a script that setup and run a fairly complete replacement of swipl-win.exe.

features:

    the script, named swipl-win.lp, introduces the *new* Prolog file extension,
    proposed on SWI-Prolog mailing list by Jose F. Morales
    (see <https://lists.iai.uni-bonn.de/pipermail/swi-prolog/2013/010301.html>).

    The text is keept in Qt resource file, and after configuration of QtCreator,
    it can be edited with some elementary syntax coloring, and get embedded
    with latest modifications in seamless way.

history:

    swipl-win has become officially a part of SWI-Prolog git repository,
    and now benefits of the portable build process underling the system
    (see http://www.swi-prolog.org/git/packages/swipl-win.git).
 
    As a consequence, the architecture has changed radically: pqConsole
    sources have been embedded in swipl-win, and the basic user interface
    logic can be found in library(win_menu.pl).

    This repository then is in a transitional stage, just showcasing an
    alternative way to embed a SWI-Prolog user interface.

author:  Carlo Capelli - Brescia 2013
licence: LGPL v2.1
