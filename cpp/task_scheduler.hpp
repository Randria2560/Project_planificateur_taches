#ifndef TASK_SCHEDULER_HPP
#define TASK_SCHEDULER_HPP

#include <QWidget>
#include <QListWidget>
#include <QStringList>

QStringList getCrontab();
void        setCrontab(const QStringList &lines);

class Scheduler : public QWidget {
    Q_OBJECT
public:
    Scheduler();
private slots:
    void refresh();
    void addTask();
    void removeTask();
    
private:
    QListWidget *list;
};

#endif