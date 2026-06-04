#include <QApplication>
#include "ex.hpp"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    Ex_scheduler s;
    s.show();
    return app.exec();
}