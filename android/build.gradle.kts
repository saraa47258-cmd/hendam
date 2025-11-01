// Top-level Gradle build file for the Android part of your Flutter app.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ضع مخرجات البناء في <flutter root>/build بدل <flutter root>/android/build
val rootBuildDir = rootProject.layout.projectDirectory.dir("../build")
rootProject.layout.buildDirectory.set(rootBuildDir)

subprojects {
    // كل موديول يبني في <flutter root>/build/<module-name>
    layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(name))

    // التأكد من تقييم :app أولاً (مثل قالب Flutter)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
