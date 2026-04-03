# InjuredAndroid - Analyse de Sécurité

Ce dépôt contient les résultats de l'analyse de sécurité de l'application Android **InjuredAndroid**, une application délibérément vulnérable utilisée pour l'apprentissage de la cybersécurité offensive mobile. Le projet inclut un rapport d'analyse détaillé, des scripts de hook Frida, et des outils d'automatisation pour la mise en place de l'environnement de laboratoire.

## Table des Matières

- [Introduction](#introduction)
- [Prérequis](#prérequis)
- [Installation du Lab](#installation-du-lab)
- [Analyse Statique](#analyse-statique)
- [Analyse Dynamique (Frida & Objection)](#analyse-dynamique-frida--objection)
- [Rapport d'Analyse](#rapport-danalyse)

## Introduction

InjuredAndroid est une application Android conçue pour présenter diverses vulnérabilités de sécurité. Ce projet vise à démontrer comment identifier et exploiter ces vulnérabilités à l'aide d'outils tels que Jadx, Frida et Objection.

## Prérequis

Avant de commencer, assurez-vous d'avoir les outils suivants installés et configurés sur votre machine :

*   **Android Studio** (pour l'émulateur Android et ADB)
*   **Jadx** (pour la décompilation d'APK)
*   **Frida** (frida-tools et frida-server)
*   **Objection**
*   **Burp Suite** (optionnel, pour l'analyse du trafic réseau)

## Installation du Lab

Ce dépôt inclut un script `setup_lab.sh` pour automatiser la mise en place de l'environnement de laboratoire sur un émulateur Android connecté via ADB.

1.  **Cloner le dépôt :**
    ```bash
    git clone https://github.com/votre_utilisateur/InjuredAndroid-Analysis.git
    cd InjuredAndroid-Analysis
    ```

2.  **Démarrer un émulateur Android :**
    Assurez-vous qu'un émulateur Android est en cours d'exécution et accessible via ADB.
    ```bash
    emulator -avd Pixel_4_API_30 &
    ```
    (Remplacez `Pixel_4_API_30` par le nom de votre AVD si différent).

3.  **Exécuter le script de setup :**
    ```bash
    chmod +x setup_lab.sh
    ./setup_lab.sh
    ```
    Ce script va :
    *   Pousser le `frida-server` sur l'émulateur.
    *   Installer l'APK `InjuredAndroid.apk`.
    *   Démarrer le `frida-server` sur l'émulateur.

## Analyse Statique

L'analyse statique a été réalisée à l'aide de Jadx pour décompiler l'APK et examiner le code source et le `AndroidManifest.xml`. Les étapes clés incluent :

*   **Décompilation :** `jadx -d injured_out/ InjuredAndroid.apk`
*   **Analyse du Manifest :** `cat injured_out/resources/AndroidManifest.xml`
*   **Recherche de secrets :** `grep -r 'api_key|password|secret|token' injured_out/sources/`

## Analyse Dynamique (Frida & Objection)

L'analyse dynamique a été effectuée avec Frida et Objection pour interagir avec l'application en cours d'exécution.

### Frida Hook pour FlagOneActivity

Le script `hook_flag1.js` est fourni pour intercepter la méthode `submitFlag` de `b3nac.injuredandroid.FlagOneActivity` et contourner la vérification du flag.

Pour exécuter le hook :

```bash
frida -U -l hook_flag1.js -f b3nac.injuredandroid --no-pause
```

### Utilisation d'Objection

Objection permet une exploration runtime de l'application. Pour se connecter à l'application :

```bash
objection -g b3nac.injuredandroid explore
```

Des commandes comme `android sslpinning disable` ou `android root disable` peuvent être utilisées pour modifier le comportement de l'application.

## Rapport d'Analyse

Le rapport d'analyse complet, `rapport_analyse.md` (convertible en PDF), est disponible dans ce dépôt. Il détaille les vulnérabilités identifiées et les recommandations de remédiation.

---
