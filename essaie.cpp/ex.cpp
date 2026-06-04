#include "ex.hpp"
#include <QStringList>
#include <QString>
#include  <QProcess>

QStringList getCrontab()
{   
    QProcess p;
    p.start("crontab", {"-l"});
    p.waitForFinished();

    QStringList lines;
    QString out= p.readAllStandardOutput();
    out= out.trimmed();

    if(out.isEmpty())
    {
        return lines;
    }
    QStringList lines = out.split("\n");
    return lines;


}
Ex_scheduler::~Ex_scheduler()
{
}