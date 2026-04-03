#!/bin/bash


if ! command -v adb &> /dev/null
then
    echo "ADB n'est pas installé. Veuillez installer Android SDK Platform-Tools."
    exit 1
fi


if [ ! -f "frida-server" ]; then
    echo "Le fichier 'frida-server' est introuvable dans le répertoire courant."
    echo "Veuillez le télécharger et le placer ici."
    exit 1
fi


if [ ! -f "InjuredAndroid.apk" ]; then
    echo "Le fichier 'InjuredAndroid.apk' est introuvable dans le répertoire courant."
    echo "Veuillez le télécharger et le placer ici."
    exit 1
fi

echo "Démarrage de l'émulateur Android (si non déjà démarré)..."


echo "Attente de la connexion de l'appareil ADB..."
adb wait-for-device

echo "Push du frida-server sur l'appareil..."
adb push frida-server /data/local/tmp/frida-server

echo "Attribution des permissions d'exécution au frida-server..."
adb shell "chmod 755 /data/local/tmp/frida-server"

echo "Installation de l'APK InjuredAndroid.apk..."
adb install InjuredAndroid.apk

echo "Démarrage du frida-server en arrière-plan sur l'appareil..."
adb shell "/data/local/tmp/frida-server &"

echo "Setup du laboratoire terminé. Vous pouvez maintenant utiliser frida et objection."
