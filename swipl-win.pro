#-------------------------------------------------
#
# Project created by QtCreator 2013-07-10T10:26:52
#
#-------------------------------------------------

QT += core gui
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = swipl-win
TEMPLATE = app

# please, not obsolete compiler
QMAKE_CXXFLAGS += -std=c++0x

SOURCES += main.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../pqConsole/release/ -lpqConsole
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../pqConsole/debug/ -lpqConsole
else:unix:!symbian: LIBS += -L$$OUT_PWD/../pqConsole/ -lpqConsole

INCLUDEPATH += $$PWD/../pqConsole
DEPENDPATH += $$PWD/../pqConsole

RESOURCES += \
    swipl-win.qrc

OTHER_FILES += \
    swipl-win.lp \
    README.md
