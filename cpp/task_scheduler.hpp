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
signals:
    void refresh();
    
private slots:
    void addTask();
    void removeTask();
    void onRefresh();
    
private:
    QListWidget *list;
};

#endif