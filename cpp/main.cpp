#include <QApplication>
#include "task_scheduler.hpp"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    Scheduler w;
    w.show();
    return app.exec();
}