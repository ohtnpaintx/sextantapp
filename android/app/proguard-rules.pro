# Keep all classes and methods in the 'com.example' package
-keep class com.example.** { *; }

# Keep all classes and methods in Flutter package
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; } # If using Firebase
-keep public class * extends io.flutter.embedding.engine.plugins.FlutterPlugin

# Keep the FlutterActivity class (required for Flutter)
-keep class io.flutter.embedding.android.FlutterActivity { *; }

# Kotlin metadata
-keepattributes *Annotation*
-keepattributes RuntimeVisibleAnnotations
-keep class kotlin.Metadata { *; }

# Keep specific classes or methods you don't want to be obfuscated
-keep class com.sextant.weatherapp.** { *; }

# Keep certain annotations (for Flutter plugins or specific libraries)
-keep @interface * { *; }

# Keep Play Core app update classes
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.appupdate.ktx.** { *; }

# Keep Play Asset Delivery classes
-keep class com.google.android.play.core.assetpacks.** { *; }

# Parcelable Classes
-keepclassmembers class ** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# General Recommendations
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Debugging Issues (Remove for production)
-printusage usage.txt

# Keep Play Core split install classes
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep SplitCompatApplication and related classes
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }


# Parcelable rules
-keepclassmembers class ** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep all classes and methods in the fl_chart library
-keep class com.patrykandpatrick.vico.** { *; }
-keep class io.github.flchart.** { *; }
-keepclassmembers class io.github.flchart.** {
    *;
}

# Keep annotations used by the library
-keepattributes *Annotation*

# Keep Parcelable implementations used for data transfer
-keepclassmembers class ** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep specific generated classes for reflection if required
-keepnames class io.github.flchart.** {
    *;
}


