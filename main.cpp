#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDirIterator>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    QDirIterator it(":/", QDirIterator::Subdirectories);
    while (it.hasNext()) {
        const QString next = it.next();
        if (next.startsWith(":/QtQuick"))
            continue;
        if (next.startsWith(":/qt-project.org"))
            continue;
        qDebug() << next;
    }

    return app.exec();
}
