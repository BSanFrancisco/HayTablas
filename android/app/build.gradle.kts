import java.util.Properties

plugins {
    id("com.android.application")
    // Volvimos a AGP 8.13 (ver android/settings.gradle.kts), que NO
    // tiene el modo "Kotlin built-in" de AGP 9. Con AGP 8.x hay que
    // aplicar el plugin de Kotlin clásico acá, como siempre se hizo:
    // esto es lo normal y evita el choque con shared_preferences (y
    // con cualquier otro plugin de pub.dev) que AGP 9 todavía tiene
    // sin resolver.
    id("org.jetbrains.kotlin.android")
    // El plugin de Flutter debe aplicarse después.
    id("dev.flutter.flutter-gradle-plugin")
}

// Datos de firma para el release, leídos desde android/key.properties
// (ese archivo NO se sube a git: contiene contraseñas).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())

    // Chequeo temprano y ruidoso: si falta el .jks apuntado desde
    // key.properties, mejor que el build falle acá con un mensaje
    // claro, en vez de caer en silencio a la firma de debug y que el
    // error recién aparezca al subir a Play Console.
    val storeFilePath = keystoreProperties.getProperty("storeFile")
    val storeFileResolved = rootProject.file(storeFilePath)
    if (!storeFileResolved.exists()) {
        throw GradleException(
            "android/key.properties existe pero apunta a un archivo " +
                "que no está: '${storeFileResolved.absolutePath}'. " +
                "Revisá que upload-keystore.jks esté guardado justo " +
                "en la carpeta android/, al lado de key.properties."
        )
    }
} else {
    // Sin key.properties: el build de release NO puede firmarse con
    // la clave real. Se avisa fuerte para que no pase desapercibido
    // (por ejemplo, para que no termines subiendo a Play Console un
    // .aab firmado en modo debug otra vez).
    logger.warn(
        "\n" + "!".repeat(70) + "\n" +
            "⚠️  ADVERTENCIA: no se encontró android/key.properties.\n" +
            "El build de RELEASE se va a firmar con la clave de DEBUG.\n" +
            "Esa build NO sirve para subir a la Play Store.\n" +
            "Copiá upload-keystore.jks y key.properties dentro de la\n" +
            "carpeta android/ (al lado de settings.gradle.kts) antes\n" +
            "de generar el .aab para publicar.\n" +
            "!".repeat(70) + "\n"
    )
}

android {
    namespace = "com.sebalima.tablasmultiplicar"
    // Bajado de 37 a 36: es el máximo que soporta AGP 8.13 (la
    // versión "clásica" de AGP a la que volvimos para esquivar el
    // problema sin resolver de AGP 9 con shared_preferences). Si en
    // el futuro esto vuelve a pedir compileSdk 37 o más (por alguna
    // dependencia nueva), hay que evaluar de nuevo si para ese
    // momento ya se solucionó el tema de AGP 9 + Kotlin built-in.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Identificador único de la aplicación. Podés cambiarlo antes de
        // publicar (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.sebalima.tablasmultiplicar"
        minSdk = maxOf(21, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                // Resuelto relativo a android/ (donde vive key.properties),
                // así el .jks puede guardarse justo al lado.
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Firma con la clave de subida (upload key) si existe
            // android/key.properties; si no, cae a la firma de debug
            // (solo sirve para probar en el celular, no para publicar).
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Sintaxis nueva (DSL de "compilerOptions") para fijar la versión de
// JVM de Kotlin, reemplaza al viejo "android.kotlinOptions".
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
