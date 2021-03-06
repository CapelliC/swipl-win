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

#ifndef CONSOLEEDIT_H
#define CONSOLEEDIT_H

#include <QEvent>
#include <QCompleter>

// make this definition available in client projects
#define PQCONSOLE_BROWSER
//#define PQCONSOLE_TEXTEDIT

#if defined(PQCONSOLE_BROWSER)
    #include <QTextBrowser>
    typedef QTextBrowser ConsoleEditBase;
#elif defined(PQCONSOLE_TEXTEDIT)
    #include <QTextEdit>
    typedef QTextEdit ConsoleEditBase;
#else
    #include <QPlainTextEdit>
    typedef QPlainTextEdit ConsoleEditBase;
#endif

#include "SwiPrologEngine.h"
#include "Completion.h"
#include "ParenMatching.h"

class Swipl_IO;

/** client side of command line interface
  * run in GUI thread, sync using SwiPrologEngine interface
  */
class PQCONSOLESHARED_EXPORT ConsoleEdit : public ConsoleEditBase {
    Q_OBJECT
    Q_PROPERTY(int updateRefreshRate READ updateRefreshRate WRITE setUpdateRefreshRate)

public:

    /** build command line interface to SWI Prolog engine */
    ConsoleEdit(int argc, char **argv, QWidget *parent = 0);

    /** create in prolog thread - call win_open_console() */
    ConsoleEdit(Swipl_IO* io, QString Title);

    /** create in prolog thread - from win_open_console(), add to tabbed interface */
    ConsoleEdit(Swipl_IO* io);

    /** handle consoles list */
    virtual ~ConsoleEdit();

    /** push command on queue */
    bool command(QString text);

    /** access low level interface */
    SwiPrologEngine* engine() { return eng; }

    /** a console is associated with a worker Prolog thread
     *  should handle the case of yet-to-be-initialized root console
     */
    bool match_thread(int thread_id) const;

    /** should always match PL_thread_id() ... */
    int thread_id() const { return thids[0]; }
    void add_thread(int id);

    /** remove all text */
    void tty_clear();

    /** make public property, then available on Prolog side */
    int updateRefreshRate() const { return update_refresh_rate; }
    void setUpdateRefreshRate(int v) { update_refresh_rate = v; }

    /** create a new console, bound to calling thread */
    void new_console(Swipl_IO *e, QString title);

    /** closeEvent only called for top level widgets */
    bool can_close();

    /** 4. attempt to run generic code inter threads */
    void exec_func(pfunc f) { emit sig_run_function(f); }

    /** 5. helper syncronization for modal loop */
    struct PQCONSOLESHARED_EXPORT exec_sync {
        exec_sync(int timeout_ms = 100);

        void stop();
        void go();

    private:
        QThread *stop_, *go_;
        QMutex sync;
        int timeout_ms;
    };

    /** give access to rl_... predicates */
    const QStringList& history_lines() const { return history; }
    void add_history_line(QString line);

    /** run interrupt/0 */
    void int_request();

    /** just check the status member */
    bool is_running() const { return status == running; }

    /** the user identifying label is attached somewhere to parents chain */
    QString titleLabel();

    /** route menu / action */
    void addActionPq(QMenu *cmmenu, QString label, QString action);

    /** html_write */
    void html_write(QString html);

    /** can be disabled from ~/.plrc */
    static bool color_term;

protected:

    /** host actual interface object, running in background */
    SwiPrologEngine *eng;

    /** can't get <eng> to work on a foreign thread - initiated from SWI-Prolog */
    Swipl_IO *io;

    /** strict control on keyboard events required */
    virtual void keyPressEvent(QKeyEvent *event);

    /** jump to source location on warning/error messages */
    virtual void mousePressEvent(QMouseEvent *e);

    /** support completion */
    virtual void focusInEvent(QFocusEvent *e);

    /** filter out insertion when cursor is not in editable position */
    virtual void insertFromMimeData(const QMimeData *source);

    /** support SWI... exec thread console creation */
    struct req_new_console : public QEvent {
        Swipl_IO *iop;
        QString title;
        req_new_console(Swipl_IO *iop, QString title) : QEvent(User), iop(iop), title(title) {}
    };
    virtual void customEvent(QEvent *event);

    /** handle tooltip placing */
    virtual bool event(QEvent *event);

    /** sense word under cursor for tooltip display */
    virtual bool eventFilter(QObject *, QEvent *event);

    /** output/input text attributes */
    QTextCharFormat output_text_fmt, input_text_fmt;

    /** start point of engine output insertion */
    /** i.e. keep last user editable position */
    int fixedPosition;

    /** commands to be dispatched to engine thread */
    QStringList commands;

    /** poor man command history */
    QStringList history;
    int history_next;
    QString history_spare;

    /** count output before setting cursor at end */
    int count_output;

    /** interval on count_output, determine how often to force output flushing */
    int update_refresh_rate;

    /** autocompletion - today not context sensitive */
    /** will eventually become with help from the kernel */
    typedef QCompleter t_Completion;
    t_Completion *preds;
    QStringList lmodules;

    /** factorize code, attempt to get visual clue from QCompleter */
    void compinit(QTextCursor c);
    void compinit2(QTextCursor c);

    /** associated thread id (see PL_thread_self()) */
    QList<int> thids;

    /** wiring etc... */
    void setup();
    void setup(Swipl_IO *iop);

    /** tooltips & completion support, from helpidx.pl */
    QString last_word, last_tip;
    void set_cursor_tip(QTextCursor c);

    /** attempt to track *where* to place outpout */
    enum e_status { idle, wait_input, running, closing, eof };
    e_status status;
    int promptPosition;
    bool is_tty;

    // while solving inter threads problems...
    friend class SwiPrologEngine;
    friend class Swipl_IO;

    /** need to sense the processor type to execute code
     *  bypass IO based execution, direct calling
     */
    void query_run(QString call);
    void query_run(QString module, QString call);

    /** check if line content is appropriate, then highlight or open editor on it */
    void clickable_message_line(QTextCursor c, bool highlight);
#ifdef PQCONSOLE_HANDLE_HOOVERING
    int cposition;
    QTextCharFormat fposition;
#endif

    /** sense URL */
    virtual void setSource(const QUrl & name);

    /** handle output reactively */
    int parsedStart;

    /** override QTextBrowser default, to get cursor working in output area */
    void set_editable(bool allow);

    /** replace references to source of error/warning with links */
    void linkto_message_source();

protected:

    /** keep last matched pair */
    ParenMatching::range pmatched;

public slots:

    /** display different cursor where editing available */
    void onCursorPositionChanged();

    /** serve console menus */
    void onConsoleMenuAction();
    void onConsoleMenuActionMap(const QString &action);

    /** 2. attempt to run generic code inter threads */
    void run_function(pfunc f) { f(); }

protected slots:

    /** send text to output */
    void user_output(QString text);

    /** issue an input request */
    void user_prompt(int threadId, bool tty);

    /** push command from queue to Prolog processor */
    void command_do();

    /** push completion request in current command line */
    void insertCompletion(QString completion);

    /** when engine gracefully complete-... */
    void eng_completed();

    /** handle HREF (simpler is query_run(Target) */
    void anchorClicked(const QUrl &link);

    /** highlight related 'symbols' on selection */
    void selectionChanged();

signals:

    /** issued to serve prompt */
    void user_input(QString);

    /** 3. attempt to run generic code inter threads */
    void sig_run_function(pfunc f);

    /** notify SWI-Prolog has been initialized, ready to run */
    void engine_ready();
};

#endif
