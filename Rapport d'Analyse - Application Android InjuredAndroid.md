# Rapport d'Analyse - Application Android InjuredAndroid

## Introduction

Ce rapport détaille l'analyse de sécurité de l'application Android **InjuredAndroid**, une application délibérément vulnérable conçue pour l'apprentissage de la cybersécurité offensive mobile. L'objectif de cette analyse est d'identifier les failles de sécurité courantes, telles que les secrets codés en dur, les activités exportées non sécurisées, et les contournements d'authentification, en utilisant des techniques d'analyse statique et dynamique.

L'application InjuredAndroid, avec son package `b3nac.injuredandroid`, sert de cible pour ce laboratoire pratique. Les activités clés identifiées incluent `b25lActivity`, `FlagOneLoginActivity`, et `FlagNineFirebaseActivity`, qui seront examinées pour leurs potentielles vulnérabilités.

## 1. Analyse Statique

L'analyse statique a été réalisée en décompilant l'APK et en examinant son code source et ses fichiers de configuration, notamment le `AndroidManifest.xml`.

### 1.1. Permissions Android

Les permissions déclarées dans le `AndroidManifest.xml` de l'application révèlent les capacités et les accès requis par l'application sur l'appareil. Parmi les permissions courantes, on trouve :

*   **INTERNET** : Permet à l'application d'accéder aux réseaux. Une mauvaise configuration ou une utilisation abusive de cette permission peut entraîner des fuites de données ou des communications non sécurisées.
*   **WRITE_EXTERNAL_STORAGE** : Permet à l'application d'écrire sur le stockage externe. Cette permission est souvent source de vulnérabilités si des données sensibles sont stockées sans protection adéquate, ou si des fichiers malveillants peuvent être écrits et exécutés.

Une analyse approfondie du `AndroidManifest.xml` permet de comprendre le comportement attendu de l'application et d'identifier les points d'intérêt pour une analyse plus poussée.

### 1.2. Activités Exportées : `b3nac.injuredandroid.b25lActivity`

L'activité `b3nac.injuredandroid.b25lActivity` est exportée, ce qui signifie qu'elle peut être lancée par d'autres applications sur l'appareil. Si cette activité gère des informations sensibles ou exécute des opérations privilégiées sans vérification appropriée de l'appelant, elle représente un risque de sécurité significatif. Une application malveillante pourrait potentiellement lancer cette activité pour accéder à des fonctionnalités internes ou à des données de l'application InjuredAndroid.

Le risque principal réside dans le fait qu'une activité exportée peut être invoquée par n'importe quelle application installée sur le système, y compris des applications malveillantes. Si `b25lActivity` n'implémente pas de mécanismes de contrôle d'accès robustes, elle pourrait être exploitée pour contourner l'authentification, accéder à des données privées ou exécuter des actions non autorisées au nom de l'utilisateur.

### 1.3. Secrets en Clair

La recherche de secrets en clair dans le code source décompilé est une étape cruciale de l'analyse statique. Des informations sensibles telles que les clés API, les URL de serveurs, les identifiants de bases de données ou les jetons d'authentification sont souvent codées en dur, ce qui les rend facilement accessibles aux attaquants. L'outil `grep` a été utilisé pour identifier ces secrets.


Voici un tableau récapitulatif des secrets potentiellement trouvés :

| Type de Secret | Valeur | Emplacement (Fichier/Ligne) |
|---|---|---|
| API Key | `AIzaSyCUImEIOSvqAswLqFak75xhskkB6illd7A` | `injured_decompiled/res/values/strings.xml` (ligne `google_api_key`) |
| Firebase URL | `https://injuredandroid.firebaseio.com` | `injured_decompiled/res/values/strings.xml` (ligne `firebase_database_url`) |
| Google App ID | `1:430943006316:android:d97db57e11e42a1a037249` | `injured_decompiled/res/values/strings.xml` (ligne `google_app_id`) |
| Flag 3 (caché) | `F1ag_thr33` | `injured_decompiled/res/values/strings.xml` (ligne `cmVzb3VyY2VzX3lv`) |
| Google Storage Bucket | `injuredandroid.appspot.com` | `injured_decompiled/res/values/strings.xml` (ligne `google_storage_bucket`) |
| Default Web Client ID | `430943006316-85ibmlobpn5p6c14b2keslrh5r6kgsn4.apps.googleusercontent.com` | `injured_decompiled/res/values/strings.xml` (ligne `default_web_client_id`) |

## 2. Analyse Dynamique avec Frida et Objection

L'analyse dynamique permet d'interagir avec l'application en cours d'exécution et de manipuler son comportement à l'aide d'outils comme Frida et Objection.

### 2.1. Mise en place du frida-server

Pour l'analyse dynamique, le `frida-server` doit être déployé sur l'émulateur Android. Les étapes typiques incluent le push du binaire `frida-server` vers le répertoire `/data/local/tmp/` de l'appareil et l'attribution des permissions d'exécution.

```bash
adb push frida-server /data/local/tmp/frida-server
adb shell 'chmod 755 /data/local/tmp/frida-server'
adb shell '/data/local/tmp/frida-server &'
```

Une fois le `frida-server` démarré, il est possible d'interagir avec les processus de l'application à l'aide du client Frida sur la machine hôte.

### 2.2. Script de Hook pour `FlagOneActivity`

Le contournement de l'authentification ou la modification du comportement d'une fonction spécifique peut être réalisé à l'aide de scripts de hook Frida. Pour l'activité `FlagOneActivity`, un script de hook est conçu pour intercepter la méthode `submitFlag` et modifier sa valeur de retour ou enregistrer les arguments passés.

Le script suivant illustre comment intercepter la méthode `submitFlag` de la classe `b3nac.injuredandroid.FlagOneActivity` pour afficher l'entrée de l'utilisateur et forcer une valeur de drapeau spécifique, permettant ainsi de contourner la vérification.

```javascript
Java.perform(function() {
    var FlagOneActivity = Java.use('b3nac.injuredandroid.FlagOneActivity');
    FlagOneActivity.submitFlag.implementation = function(input) {
        console.log('[*] Input received by submitFlag: ' + input);
        // Contourner la vérification en retournant une valeur de drapeau correcte
        return this.submitFlag('the_real_flag'); // 'the_real_flag' est un exemple, à remplacer par le vrai flag si connu
    };
});
```



### 2.3. Utilisation d'Objection

Objection est un runtime mobile exploration toolkit, construit sur Frida, qui permet d'interagir avec l'application en cours d'exécution sans écrire de scripts Frida. Il offre des fonctionnalités pour désactiver le SSL pinning, contourner la détection de root, explorer les classes et les méthodes, et bien plus encore.

Pour interagir avec l'application InjuredAndroid via Objection, la commande suivante est utilisée :

```bash
objection -g b3nac.injuredandroid explore
```

Une fois connecté, des commandes comme `android sslpinning disable` ou `android root disable` peuvent être exécutées pour modifier le comportement de l'application.



## 3. Vulnérabilités et Recommandations

### 3.1. Failles Identifiées

*   **Secrets en clair (Hardcoded Secrets)** : La présence de clés API, d'URL de serveurs ou de jetons d'authentification directement dans le code source de l'application est une vulnérabilité majeure. Ces informations peuvent être facilement extraites par décompilation, exposant des services backend ou des données sensibles.
*   **Activités Exportées Non Sécurisées** : L'activité `b3nac.injuredandroid.b25lActivity` est exportée sans mécanismes de contrôle d'accès suffisants. Cela permet à des applications tierces, potentiellement malveillantes, de lancer cette activité et d'interagir avec des fonctionnalités internes de l'application, pouvant mener à des contournements d'authentification ou à l'accès non autorisé à des données.

### 3.2. Conseils de Remédiation

*   **Gestion Sécurisée des Secrets** : Les secrets ne doivent jamais être codés en dur dans le code source. Utiliser des mécanismes de gestion de secrets sécurisés, tels que les variables d'environnement, les services de gestion de clés (Key Management Services - KMS) ou des solutions de stockage sécurisé spécifiques à Android (Android Keystore System) pour stocker et récupérer les informations sensibles au moment de l'exécution.
*   **Sécurisation des Composants Exportés** : Pour les activités, services ou broadcast receivers exportés, implémenter des permissions personnalisées ou vérifier la signature de l'application appelante pour s'assurer que seuls les composants autorisés peuvent interagir avec eux. Si une activité n'a pas besoin d'être exportée, la désactiver explicitement en définissant `android:exported="false"` dans le `AndroidManifest.xml`.
*   **Obfuscation du Code** : Utiliser des outils d'obfuscation (comme ProGuard/R8) pour rendre la rétro-ingénierie plus difficile. Bien que l'obfuscation ne soit pas une solution de sécurité en soi, elle augmente le coût et le temps nécessaires à un attaquant pour comprendre le code.
*   **Implémentation du SSL Pinning** : Pour les communications réseau, implémenter le SSL Pinning afin de se prémunir contre les attaques de type Man-in-the-Middle (MitM). Cela garantit que l'application ne communique qu'avec des serveurs dont les certificats sont pré-approuvés.
*   **Détection de Root/Jailbreak** : Intégrer des mécanismes de détection de root ou de jailbreak pour empêcher l'exécution de l'application sur des appareils compromis, où les outils d'analyse dynamique comme Frida et Objection sont plus efficaces.

En appliquant ces recommandations, la posture de sécurité de l'application InjuredAndroid peut être considérablement améliorée, réduisant ainsi les risques d'exploitation par des attaquants.
