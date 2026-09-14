<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    __INTERNET_PERMISSION__
    <application
        android:allowBackup="true"
        android:icon="@drawable/app_icon"
        android:label="__APP_NAME_XML__"
        android:supportsRtl="true"
        android:theme="@style/AppTheme"
        android:usesCleartextTraffic="__ALLOW_CLEARTEXT__">
        <activity
            android:name=".MainActivity"
            android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|screenSize|smallestScreenSize|uiMode"
            android:exported="true"
            android:screenOrientation="__ORIENTATION__">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
