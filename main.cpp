/*
    pqConsole    : interfacing SWI-Prolog and Qt

    Author       : Carlo Capelli
    E-mail       : cc.carlo.cap@gmail.com
    Copyright (C): 2013, Carlo Capelli

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <QApplication>
#include "pqMainWindow.h"
#include <QFile>
#include <QDebug>
#include <QTextStream>

/* Note that QApplication is created using new to avoid destruction
   on program shutdown.  Destroying causes a crash in XCloseDisplay()
   if xpce was started.
*/

int main(int argc, char *argv[]) {

    int rc;
    QApplication *a = new QApplication(argc, argv);
    pqMainWindow w(argc, argv);

    w.show();
    rc = a->exec();
    qDebug() << "main loop finished";
    return rc;
}
