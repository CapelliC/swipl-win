#--------------------------------------------------
# swipl-win.pro: SWI-Prolog / QT interface
#--------------------------------------------------
#
# REPL in QTextEdit on a background logic processor
#--------------------------------------------------
# Ing. Capelli Carlo - Brescia 2013

#-------------------------------------------------
# Project created by QtCreator 2013-07-10T10:26:52
#-------------------------------------------------

QT += core gui
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = swipl-win
TEMPLATE = app

# please, not obsolete compiler
QMAKE_CXXFLAGS += -std=c++0x

unix {
    # because SWI-Prolog is built from source
    CONFIG += link_pkgconfig
    PKGCONFIG += swipl
}

SOURCES += main.cpp \
    ../pqConsole/SwiPrologEngine.cpp \
    ../pqConsole/Swipl_IO.cpp \
    ../pqConsole/Preferences.cpp \
    ../pqConsole/pqMainWindow.cpp \
    ../pqConsole/pqConsole.cpp \
    ../pqConsole/FlushOutputEvents.cpp \
    ../pqConsole/ConsoleEdit.cpp \
    ../pqConsole/Completion.cpp

INCLUDEPATH += $$PWD/../pqConsole

RESOURCES += \
    swipl-win.qrc

OTHER_FILES += \
    swipl-win.lp \
    README.md \
    ../pqConsole/swipl.png

HEADERS += \
    ../pqConsole/SwiPrologEngine.h \
    ../pqConsole/Swipl_IO.h \
    ../pqConsole/Preferences.h \
    ../pqConsole/PREDICATE.h \
    ../pqConsole/pqMainWindow.h \
    ../pqConsole/pqConsole_global.h \
    ../pqConsole/pqConsole.h \
    ../pqConsole/FlushOutputEvents.h \
    ../pqConsole/do_events.h \
    ../pqConsole/ConsoleEdit.h \
    ../pqConsole/Completion.h
