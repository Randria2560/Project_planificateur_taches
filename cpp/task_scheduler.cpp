#include "task_scheduler.hpp"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QInputDialog>
#include <QMessageBox>
#include <QProcess>

// ── Lecture du crontab 
QStringList getCrontab() {
    QProcess p;
    p.start("crontab", {"-l"});
    p.waitForFinished();

    QString out = p.readAllStandardOutput();
    out = out.trimmed();

    if (out.isEmpty())
        return QStringList();

    QStringList lines = out.split("\n");
    lines.removeAll("");   // ← supprime les lignes vides
    return lines;
}

// ── Écriture du crontab:echo "      " | crontab -
void setCrontab(const QStringList &lines) {
    QProcess p;
    p.start("crontab", {"-"});  //lire depuis stdin
    p.waitForStarted();         //attend que le processus soit pret à recevoir les données
    p.write(lines.join("\n").toUtf8());
    p.closeWriteChannel();
    p.waitForFinished();
}

// ── Constructeur 
Scheduler::Scheduler() {
    setWindowTitle("Task Scheduler");
    resize(400, 400);

    //setupUi:
    list = new QListWidget(this);

    QPushButton *btnAdd     = new QPushButton("Add");
    QPushButton *btnRemove  = new QPushButton("Remove");
    QPushButton *btnRefresh = new QPushButton("Refresh");

    QHBoxLayout *btnLayout = new QHBoxLayout;
    btnLayout->addWidget(btnRefresh);
    btnLayout->addWidget(btnAdd);
    btnLayout->addWidget(btnRemove);

    QVBoxLayout *mainLayout = new QVBoxLayout(this);
    mainLayout->addWidget(list);
    mainLayout->addLayout(btnLayout);

    connect(btnRefresh, &QPushButton::clicked, this, &Scheduler::refresh);

    connect(btnAdd,     &QPushButton::clicked, this, &Scheduler::addTask);

    connect(btnRemove,  &QPushButton::clicked, this, &Scheduler::removeTask);

    refresh();
}

// ── Rafraîchir la list: QListWidget: addItem et QStringList : append()
void Scheduler::refresh() {  //pour voire la liste 
    list->clear();
    QStringList lines = getCrontab();
    for (int i =0 ; i<lines.size() ; i++)
    {
        list->addItem(lines[i]);
    }
}


void Scheduler::addTask() {
    bool ok;

    // 1. Demande la commande à l'utilisateur mais ne vérifie pas la validiter de la commande si elle existe ou pas
    QString cmd = QInputDialog::getText(this, 
                                        "Command", "Command to schedule:", QLineEdit::Normal, "", 
                                        &ok);
    if (!ok || cmd.isEmpty()) 
        return;


    // 2. Demande le type de fréquence
    QStringList freqs = {"Hourly", "Daily", "Weekly", "Monthly", "Custom"};

    QString freq = QInputDialog::getItem(this,
                                     "Frequency", "Scheduling type:", freqs,  //QStringList des Choiw
                                     0, //index séléctionné par défaut
                                     false,  //non éditable
                                     &ok);
    if (!ok) 
        return;

    QString m="*", h="*", dom="*", mon="*", dow="*";

    if (freq == "Hourly") 
    {
        m = QInputDialog::getText(this, "Minute", "Minute (0-59):", QLineEdit::Normal, "0", &ok);
    } else if (freq == "Daily") 
    {
        h = QInputDialog::getText(this, "Hour",   "Hour (0-23):",   QLineEdit::Normal, "0", &ok);
        m = QInputDialog::getText(this, "Minute", "Minute (0-59):", QLineEdit::Normal, "0", &ok);
    } else if (freq == "Weekly") 
    {
        dow = QInputDialog::getText(this, "Day",    "Day of week (0=Sun..6=Sat):", QLineEdit::Normal, "1", &ok);
        h   = QInputDialog::getText(this, "Hour",   "Hour (0-23):",                QLineEdit::Normal, "0", &ok);
        m   = QInputDialog::getText(this, "Minute", "Minute (0-59):",              QLineEdit::Normal, "0", &ok);
    } else if (freq == "Monthly") 
    {
        dom = QInputDialog::getText(this, "Day",    "Day of month (1-31):",        QLineEdit::Normal, "1", &ok);
        h   = QInputDialog::getText(this, "Hour",   "Hour (0-23):",                QLineEdit::Normal, "0", &ok);
        m   = QInputDialog::getText(this, "Minute", "Minute (0-59):",              QLineEdit::Normal, "0", &ok);
    } else 
    {
        m   = QInputDialog::getText(this, "Min",  "Minutes:",      QLineEdit::Normal, "*", &ok);
        h   = QInputDialog::getText(this, "Hour", "Hours:",        QLineEdit::Normal, "*", &ok);
        dom = QInputDialog::getText(this, "DOM",  "Day of month:", QLineEdit::Normal, "*", &ok);
        mon = QInputDialog::getText(this, "Mon",  "Month:",        QLineEdit::Normal, "*", &ok);
        dow = QInputDialog::getText(this, "DOW",  "Day of week:",  QLineEdit::Normal, "*", &ok);
    }

    if (QMessageBox::question(this, "Logs", "Enable logs?") == QMessageBox::Yes)
        cmd += " >> scheduler.log 2>&1"; 

    //Formatage
    QString cronLine = QString("%1 %2 %3 %4 %5 %6").arg(m, h, dom, mon, dow, cmd);

    QStringList current = getCrontab();  

    //vérification des doublons si ils existent
    if (current.contains(cronLine)) 
    {
        QMessageBox::information(this, "Info", "Task already exists.");
        return;
    }

    current.append(cronLine);
    setCrontab(current);
    refresh();
    QMessageBox::information(this, "Done", "Task added:\n" + cronLine);
}

// ── Supprimer une tâche ─
void Scheduler::removeTask() {
    int row = list->currentRow();
    if (row < 0) //pas de séléction
    { 
        QMessageBox::warning(this, "Warning", "Select a task first."); 
        return; 
    }

    QStringList lines = getCrontab();
    lines.removeAt(row);
    setCrontab(lines);
    refresh();
}

